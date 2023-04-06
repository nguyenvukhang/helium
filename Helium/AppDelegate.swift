//
//  AppDelegate.swift
//  Helium
//
//  Created by khang on 5/4/23.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    private var lastUsedTablet: Int
    private var bar: StatusBar
    private var mode: Mode
    private var showBounds: Bool
    private var overlay: Overlay
    private var windowController: NSWindowController
    private var prefsWindowController: NSWindowController?
    private let store: Store
    private var lastRect: NSRect

    override init() {
        self.lastUsedTablet = 0 // 0 is an invalid tablet ID
        self.showBounds = true
        self.mode = .fullscreen
        self.bar = StatusBar()
        self.overlay = Overlay()
        self.windowController = NSWindowController(window: overlay)
        self.store = Store()
        self.lastRect = NSZeroRect
        super.init()
        listenForEvents()
        bar.linkActions(toggleMode: #selector(toggleMode), togglePrecisionBounds: #selector(togglePrecisionBounds), openPrefs: #selector(openPreferences), quit: #selector(quit))
        windowController.showWindow(overlay)
        setFullScreenMode()
    }

    /**
     * Open the preferences window.
     */
    @objc func openPreferences() {
        if prefsWindowController == nil {
            prefsWindowController = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "PrefsWindowController") as? NSWindowController
            let svc = prefsWindowController?.contentViewController as? SettingsViewController
            svc?.hydrate(overlay: overlay, store: store, update: {
                if self.mode == .precision {
                    self.setPrecisionMode(at: NSEvent.mouseLocation)
                }
            })
        }
        NSApp.activate(ignoringOtherApps: true)
        prefsWindowController?.showWindow(self)
    }

    /**
     * Menu bar action: Toggle between modes.
     */
    @objc func toggleMode() {
        mode = mode.next()
        bar.updateMode(mode)
        switch mode {
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
        showBounds = !showBounds
        overlay.setEnabled(to: showBounds)
        bar.setPrecisionBounds(to: showBounds)
        if showBounds {
            overlay.flash()
        } else {
            overlay.hide()
        }
    }

    /**
     * Menu bar action: Quit the app
     */
    @objc func quit() {
        exit(EXIT_SUCCESS)
    }

    /**
     * Acts on a detected keypress.
     *
     * Current list of effective keypresses:
     *   - Cmd + Shift + F2: start precision mode at cursor location
     */
    private func handleKeyDown(_ e: NSEvent) {
        if e.modifierFlags.contains([.command, .shift]) && e.keyCode == KeyCode.f2.rawValue {
            setPrecisionMode(at: NSEvent.mouseLocation)
            mode = .precision
            bar.updateMode(mode)
        }
    }

    /**
     * Handles [.tabletProximity, .keyDown] events for now.
     */
    private func handleEvent(_ event: NSEvent) {
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
        if mode == .precision {
            overlay.show()
        }
    }

    /**
     * This must only be called once.
     */
    private func listenForEvents() {
        NSEvent.addGlobalMonitorForEvents(matching: [.tabletProximity, .keyDown]) { event in
            self.handleEvent(event)
        }
    }

    /**
     * Set focus on the area around the cursor.
     */
    func setPrecisionMode(at: NSPoint) {
        var rect = NSZeroRect
        rect.fillScreen(withAspectRatio: store.getAspectRatio())
        rect.scale(by: store.scale)
        rect.moveWithinScreen(to: at)
        setScreenMapArea(rect)
        overlay.move(to: rect)
        lastRect = rect
        overlay.flash()
    }

    /**
     * Make the tablet cover the whole screen.
     */
    func setFullScreenMode() {
        var rect = NSZeroRect
        rect.fillScreen(withAspectRatio: store.getAspectRatio())
        rect.centerInScreen()
        setScreenMapArea(rect)
        overlay.hide()
    }

    /**
     * API call to Wacom Drivers to set map area.
     */
    private func setScreenMapArea(_ rect: NSRect) {
        Wacom.setScreenMapArea(rect, screen: NSRect.screen(), tabletId: Int32(lastUsedTablet))
    }

    func applicationSupportsSecureRestorableState(_: NSApplication) -> Bool {
        true
    }
}
