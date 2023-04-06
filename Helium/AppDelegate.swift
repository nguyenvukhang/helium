//
//  AppDelegate.swift
//  Helium
//
//  Created by khang on 5/4/23.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    var lastUsedTablet: Int
    var mode: Ref<Mode>
    var pBounds = Pair(on: "Hide Bounds", off: "Show Bounds", state: .on)

    var bar: MenuBar
    let store: Store
    var overlay: Overlay
    var overlayWindowController: NSWindowController
    var prefsWindowController: NSWindowController?
    var lastRect: NSRect

    override init() {
        self.lastUsedTablet = 0 // 0 is an invalid tablet ID
        self.mode = Ref(.fullscreen)

        self.bar = MenuBar(mode: mode, pBounds: pBounds)
        self.store = Store()
        self.overlay = Overlay(store, pBounds: pBounds)
        self.overlayWindowController = NSWindowController(window: overlay)
        self.lastRect = NSZeroRect

        super.init()

        listenForEvents()
        bar.linkActions(toggleMode: #selector(toggleMode), togglePrecisionBounds: #selector(togglePrecisionBounds), openPrefs: #selector(openPreferences), quit: #selector(quit))
        overlayWindowController.showWindow(overlay)
        setFullScreenMode()
    }

    /**
     * Menu bar action: Toggle between modes.
     */
    @objc func toggleMode() {
        mode.val.next()
        bar.update()
        switch mode.val {
        case .fullscreen:
            setFullScreenMode()
        case .precision:
            setPrecisionMode(at: NSEvent.mouseLocation)
        }
    }

    /**
     * Menu bar action: Toggle show/hide precision bounds
     */
    @objc func togglePrecisionBounds() {
        pBounds.toggle()
        bar.update()
        if pBounds.on {
            overlay.flash()
        } else {
            overlay.hide()
        }
    }

    /**
     * Menu bar action: Quit the app
     */
    @objc func quit() {
        self.setFullScreenMode()
        exit(EXIT_SUCCESS)
    }

    /**
     * Acts on a detected keypress.
     *
     * Current list of effective keypresses:
     *   - Cmd + Shift + F2: start precision mode at cursor location
     */
    func handleKeyDown(_ e: NSEvent) {
        if e.modifierFlags.contains([.command, .shift]) && e.keyCode == KeyCode.f2.rawValue {
            setPrecisionMode(at: NSEvent.mouseLocation)
            mode.val = .precision
            bar.update()
        }
    }

    /**
     * Handles [.tabletProximity, .keyDown] events for now.
     */
    func handleEvent(_ event: NSEvent) {
        if event.type == .keyDown {
            handleKeyDown(event)
            return
        }
        // at this point, event.type is guaranteed to be .tabletProximity, based on the matcher
        if !event.isEnteringProximity {
            let cursor = NSEvent.mouseLocation
            if store.moveOnEdgeTouch && lastRect.nearEdge(point: cursor, tolerance: 10) {
                setPrecisionMode(at: cursor)
            } else {
                overlay.hide()
            }
            return
        }
        // event.isEnteringProximity == true
        lastUsedTablet = event.systemTabletID
        if mode.val == .precision {
            overlay.show()
        }
    }

    /**
     * This must only be called once.
     */
    func listenForEvents() {
        NSEvent.addGlobalMonitorForEvents(matching: [.tabletProximity, .keyDown]) { event in
            self.handleEvent(event)
        }
    }

    /**
     * Set focus on the area around the cursor.
     */
    func setPrecisionMode(at: NSPoint) {
        let rect = NSRect.precision(at: at, scale: store.scale, aspectRatio: store.getAspectRatio())
        setScreenMapArea(rect)
        overlay.move(to: rect)
        lastRect = rect
        overlay.flash()
    }

    /**
     * Make the tablet cover the whole screen.
     */
    func setFullScreenMode() {
        let rect = NSRect.fullscreen(aspectRatio: store.getAspectRatio())
        setScreenMapArea(rect)
        overlay.hide()
    }

    /**
     * Open the preferences window.
     */
    @objc func openPreferences() {
        if prefsWindowController == nil {
            prefsWindowController = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "PrefsWindowController") as? NSWindowController
            let svc = prefsWindowController?.contentViewController as? SettingsViewController
            svc?.hydrate(overlay: overlay, store: store, update: {
                if self.mode.val == .precision {
                    self.setPrecisionMode(at: NSEvent.mouseLocation)
                }
            })
        }
        NSApp.activate(ignoringOtherApps: true)
        prefsWindowController?.showWindow(self)
    }

    /**
     * API call to Wacom Drivers to set map area.
     */
    func setScreenMapArea(_ rect: NSRect) {
        Wacom.setScreenMapArea(rect, screen: NSRect.screen(), tabletId: Int32(lastUsedTablet))
    }

    func applicationSupportsSecureRestorableState(_: NSApplication) -> Bool {
        true
    }
    
    private func applicationWillTerminate(_: NSApplication) {
        self.setFullScreenMode()
    }
}
