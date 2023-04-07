//
//  AppDelegate.swift
//  Helium
//
//  Created by khang on 5/4/23.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    var bar: MenuBar
    var overlayWindowController: NSWindowController
    var prefsWindowController: NSWindowController?
    var lastRect: NSRect
    let helium: Helium

    override init() {
        self.helium = Helium()
        self.bar = MenuBar(helium: helium)
        self.overlayWindowController = NSWindowController(window: helium.overlayWindow())
        self.lastRect = NSZeroRect

        super.init()

        NSEvent.addGlobalMonitorForEvents(matching: .tabletProximity) { event in self.handleEvent(event) }
        overlayWindowController.showWindow(helium.overlayWindow())
        helium.setFullScreenMode()
        bar.linkOpenPreferencesAction(#selector(openPreferences), target: self)

        Actions.bind(.fullscreen) {
            self.helium.setFullScreenMode()
            self.bar.update()
        }

        Actions.bind(.precision) {
            self.helium.setPrecisionMode()
            self.bar.update()
        }

        Actions.bind(.toggle) {
            self.helium.toggleMode()
            self.bar.update()
        }
    }

    /**
     * When tablet pen enters proximity
     */
    func handleProximityEntry(_ event: NSEvent) {
        helium.lastUsedTablet.val = event.systemTabletID
        if helium.mode == .precision {
            helium.showOverlay()
        }
    }

    /**
     * When tablet pen exits proximity
     */
    func handleProximityExit(_ event: NSEvent) {
        if helium.store.moveOnEdgeTouch {
            let cursor = NSEvent.mouseLocation
            if cursor.nearEdge(of: lastRect, by: 10) {
                helium.setPrecisionMode(at: cursor)
            }
        }
        helium.hideOverlay()
    }

    /**
     * Handles [.tabletProximity] events for now.
     */
    func handleEvent(_ event: NSEvent) {
        if event.isEnteringProximity {
            handleProximityEntry(event)
        } else {
            handleProximityExit(event)
        }
    }

    /**
     * Open the preferences window.
     */
    @objc func openPreferences() {
        if prefsWindowController == nil {
            prefsWindowController = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "PrefsWindowController") as? NSWindowController
            let svc = prefsWindowController?.contentViewController as? SettingsViewController
            svc?.hydrate(helium: helium)
        }
        NSApp.activate(ignoringOtherApps: true)
        prefsWindowController?.showWindow(self)
    }

    func applicationSupportsSecureRestorableState(_: NSApplication) -> Bool { true }
    private func applicationWillTerminate(_: NSApplication) { helium.reset() }
}
