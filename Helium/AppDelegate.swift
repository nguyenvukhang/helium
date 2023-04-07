//
//  AppDelegate.swift
//  Helium
//
//  Created by khang on 5/4/23.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    let helium: Helium
    var bar: MenuBar
    var overlayWindowController: NSWindowController
    var lastRect: NSRect

    override init() {
        self.helium = Helium()
        self.bar = MenuBar(helium: helium)
        self.overlayWindowController = NSWindowController(window: helium.overlayWindow())
        self.lastRect = NSZeroRect
        super.init()
        postInit()
    }

    func postInit() {
        NSEvent.addGlobalMonitorForEvents(matching: .tabletProximity) { event in self.handleProximityEvent(event) }
        overlayWindowController.showWindow(helium.overlayWindow())
        helium.setFullScreenMode()

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

    /** When tablet pen enters proximity */
    func handleProximityEntry(_ event: NSEvent) {
        helium.lastUsedTablet.val = event.systemTabletID
        helium.showOverlay()
    }

    /** When tablet pen exits proximity */
    func handleProximityExit(_ event: NSEvent) {
        if helium.store.moveOnEdgeTouch {
            let cursor = NSEvent.mouseLocation
            if cursor.nearEdge(of: lastRect, by: 10) {
                helium.setPrecisionMode(at: cursor)
            }
        }
        helium.hideOverlay()
    }

    /** Handles .tabletProximity events. */
    func handleProximityEvent(_ event: NSEvent) {
        event.isEnteringProximity ? handleProximityEntry(event) : handleProximityExit(event)
    }

    func applicationSupportsSecureRestorableState(_: NSApplication) -> Bool { true }
    private func applicationWillTerminate(_: NSApplication) { helium.reset() }
}
