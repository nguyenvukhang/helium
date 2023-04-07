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
    var overlay: Overlay
    var overlayWindowController: NSWindowController
    var prefsWindowController: NSWindowController?
    var lastRect: NSRect
    let helium: Helium

    override init() {
        self.helium = Helium()
        self.overlay = Overlay(helium: helium)
        self.bar = MenuBar(helium: helium, overlay: overlay)
        self.overlayWindowController = NSWindowController(window: overlay)
        self.lastRect = NSZeroRect

        super.init()

        NSEvent.addGlobalMonitorForEvents(matching: .tabletProximity) { event in self.handleEvent(event) }
        overlayWindowController.showWindow(overlay)
        let _ = helium.setFullScreenMode()
        bar.linkOpenPreferencesAction(#selector(openPreferences), target: self)

        Actions.bind(.fullscreen) {
            self.overlay.move(to: self.helium.setFullScreenMode())
            self.bar.update()
        }

        Actions.bind(.precision) {
            self.overlay.move(to: self.helium.setPrecisionMode())
            self.bar.update()
            self.overlay.flash()
        }

        Actions.bind(.toggle) {
            self.overlay.move(to: self.helium.toggleMode())
            self.bar.update()
        }
    }

    /**
     * When tablet pen enters proximity
     */
    func handleProximityEntry(_ event: NSEvent) {
        helium.lastUsedTablet.val = event.systemTabletID
        if helium.mode == .precision {
            overlay.show()
        }
    }

    /**
     * When tablet pen exits proximity
     */
    func handleProximityExit(_ event: NSEvent) {
        let cursor = NSEvent.mouseLocation
        if helium.store.moveOnEdgeTouch && lastRect.nearEdge(point: cursor, tolerance: 10) {
            overlay.move(to: helium.setPrecisionMode(at: cursor))
        }
        overlay.hide()
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
            svc?.hydrate(overlay: overlay, helium: helium, update: {
                if self.helium.mode == .precision {
                    self.overlay.move(to: self.helium.setPrecisionMode())
                }
            })
        }
        NSApp.activate(ignoringOtherApps: true)
        prefsWindowController?.showWindow(self)
    }

    func applicationSupportsSecureRestorableState(_: NSApplication) -> Bool { true }
    private func applicationWillTerminate(_: NSApplication) { helium.reset() }
}
