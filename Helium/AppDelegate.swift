//
//  AppDelegate.swift
//  Helium
//
//  Created by khang on 5/4/23.
//

import Cocoa
import KeyboardShortcuts

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    let helium: Helium
    var bar: MenuBar
    var overlayWindowController: NSWindowController

    override init() {
        self.helium = Helium()
        self.bar = MenuBar(helium: helium)
        self.overlayWindowController = NSWindowController(window: helium.overlay)
        super.init()
        postInit()
    }

    func postInit() {
        NSEvent.addGlobalMonitorForEvents(matching: .tabletProximity) {
            event in self.handleProximityEvent(event)
        }
        overlayWindowController.showWindow(helium.overlay)
        helium.setFullScreenMode()
        KeyboardShortcuts.onKeyDown(for: .setFullscreenMode) {
            self.helium.setFullScreenMode()
            self.bar.update()
        }
        KeyboardShortcuts.onKeyDown(for: .setPrecisionMode) {
            self.helium.setPrecisionMode()
            self.bar.update()
        }
        KeyboardShortcuts.onKeyDown(for: .toggleMode) {
            self.helium.toggleMode()
            self.bar.update()
        }
        bar.update()
    }

    /** When tablet pen enters proximity */
    func handleProximityEntry(_ event: NSEvent) {
        helium.lastUsedTablet = Int32(event.systemTabletID)
        helium.showOverlay()
    }

    /** When tablet pen exits proximity */
    func handleProximityExit(_: NSEvent) {
        helium.hideOverlay()
    }

    /** Handles .tabletProximity events. */
    func handleProximityEvent(_ event: NSEvent) {
        event.isEnteringProximity ? handleProximityEntry(event) : handleProximityExit(event)
    }

    private func applicationWillTerminate(_: NSApplication) {
        helium.reset()
    }
}
