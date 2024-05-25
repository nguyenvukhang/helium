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
    var lastRect = NSZeroRect

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
        Shortcuts.bind(.setFullscreen) {
            self.helium.setFullScreenMode()
            self.bar.update()
        }
        Shortcuts.bind(.setPrecision) {
            self.helium.setPrecisionMode()
            self.bar.update()
        }
        Shortcuts.bind(.toggleMode) {
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
        if helium.moveOnEdgeTouch {
            if NSEvent.mouseLocation.nearEdge(of: lastRect, by: 10) {
                helium.setPrecisionMode()
            }
        }
        helium.hideOverlay()
    }

    /** Handles .tabletProximity events. */
    func handleProximityEvent(_ event: NSEvent) {
        event.isEnteringProximity ? handleProximityEntry(event) : handleProximityExit(event)
    }

    private func applicationWillTerminate(_: NSApplication) { helium.reset() }
}
