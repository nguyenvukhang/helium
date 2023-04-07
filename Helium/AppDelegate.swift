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
    let actions: Actions
    var lastRect: NSRect

    override init() {
        self.lastUsedTablet = 0 // 0 is an invalid tablet ID
        self.mode = Ref(.fullscreen)

        self.bar = MenuBar(mode: mode, pBounds: pBounds)
        self.store = Store()
        self.overlay = Overlay(store, pBounds: pBounds)
        self.overlayWindowController = NSWindowController(window: overlay)
        self.actions = Actions()
        self.lastRect = NSZeroRect

        super.init()

        listenForEvents()
        bar.linkActions(toggleMode: #selector(toggleMode), togglePrecisionBounds: #selector(togglePrecisionBounds), openPrefs: #selector(openPreferences), quit: #selector(quit))
        overlayWindowController.showWindow(overlay)
        setFullScreenMode()
        actions.bind(key: .precision) {
            self.setPrecisionMode(at: NSEvent.mouseLocation)
        }
        actions.bind(key: .fullscreen, action: setFullScreenMode)
        actions.bind(key: .toggle, action: toggleMode)
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
        setFullScreenMode()
        exit(EXIT_SUCCESS)
    }

    /**
     * Handles [.tabletProximity, .keyDown] events for now.
     */
    func handleEvent(_ event: NSEvent) {
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
        NSEvent.addGlobalMonitorForEvents(matching: .tabletProximity) { event in
            self.handleEvent(event)
        }
    }

    /**
     * Set focus on the area around the cursor.
     */
    func setPrecisionMode(at: NSPoint) {
        mode.val = .precision
        let rect = NSRect.precision(at: at, scale: store.scale, aspectRatio: store.getAspectRatio())
        setScreenMapArea(rect)
        overlay.move(to: rect)
        lastRect = rect
        overlay.flash()
        bar.update()
    }

    /**
     * Make the tablet cover the whole screen.
     */
    func setFullScreenMode() {
        mode.val = .fullscreen
        let rect = NSRect.fullscreen(aspectRatio: store.getAspectRatio())
        setScreenMapArea(rect)
        overlay.hide()
        bar.update()
    }

    /**
     * Open the preferences window.
     */
    @objc func openPreferences() {
        if prefsWindowController == nil {
            prefsWindowController = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "PrefsWindowController") as? NSWindowController
            let svc = prefsWindowController?.contentViewController as? SettingsViewController
            svc?.hydrate(overlay: overlay, store: store, actions: actions, update: {
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
        setFullScreenMode()
    }
}
