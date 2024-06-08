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
        NSEvent.addLocalMonitorForEvents(matching: .tabletProximity) { event in
            self.handleProximityEvent(event)
            return nil
        }
        NSEvent.addGlobalMonitorForEvents(matching: .tabletProximity, handler: self.handleProximityEvent)
        overlayWindowController.showWindow(helium.overlay)
        helium.setFullScreenMode()
        helium.display()
        KeyboardShortcuts.onKeyDown(for: .setFullscreenMode) {
            self.helium.mode = .fullscreen
            self.helium.display()
            self.bar.update()
        }
        KeyboardShortcuts.onKeyDown(for: .setPrecisionMode) {
            self.helium.mode = .precision
            self.helium.display()
            self.bar.update()
        }
        KeyboardShortcuts.onKeyDown(for: .toggleMode) {
            self.helium.mode.next()
            self.helium.display()
            self.bar.update()
        }
        bar.update()
    }

    /** Handles .tabletProximity events. */
    func handleProximityEvent(_ event: NSEvent) {
        helium.penInProximity = event.isEnteringProximity
        helium.lastUsedTablet = Int32(event.systemTabletID)
    }

    private func applicationWillTerminate(_: NSApplication) {
        helium.reset()
    }
}
