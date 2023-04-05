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
    private var pwc: NSWindowController?
    private let store: Store

    override init() {
        self.lastUsedTablet = 0 // 0 is an invalid tablet ID
        self.showBounds = true
        self.mode = .fullscreen
        self.bar = StatusBar()
        self.overlay = Overlay()
        self.windowController = NSWindowController(window: overlay)
        self.store = Store()
        super.init()
        listenForEvents()
        bar.linkActions(togglePrecision: #selector(togglePrecision), togglePrecisionBounds: #selector(togglePrecisionBounds), openPrefs: #selector(openPreferences), quit: #selector(quit))
        windowController.showWindow(overlay)
        setFullScreenMode()
    }

    @objc func openPreferences() {
        if pwc == nil {
            let board = NSStoryboard(name: "Main", bundle: nil)
            pwc = board.instantiateController(withIdentifier: "PrefsWindowController") as? NSWindowController
            let svc = pwc?.contentViewController as? SettingsViewController
            svc?.hydrate(overlay: overlay, store: store, update: {
                if self.mode == .precision {
                    self.setPrecisionMode(at: NSEvent.mouseLocation)
                }
            })
        }
        NSApp.activate(ignoringOtherApps: true)
        pwc?.showWindow(self)
    }

    @objc func togglePrecision() {
        mode = mode.next()
        bar.updateMode(mode)
        switch mode {
        case .fullscreen:
            setFullScreenMode()
        case .precision:
            setPrecisionMode(at: NSEvent.mouseLocation)
        }
    }

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
            NSLog("[keypress] Command + Shift + F2")
            setPrecisionMode(at: NSEvent.mouseLocation)
            mode = .precision
            bar.updateMode(mode)
        }
    }

    /**
     * This must only be called once.
     */
    private func listenForEvents() {
        NSEvent.addGlobalMonitorForEvents(matching: [.tabletProximity, .keyDown]) { event in
            if event.type == .keyDown {
                self.handleKeyDown(event)
                return
            }
            // at this point, event.type is guaranteed to be .tabletProximity, based on the matcher
            if !event.isEnteringProximity {
                self.overlay.hide()
                return
            }
            // event.isEnteringProximity == true
            self.lastUsedTablet = event.systemTabletID
            if self.mode == .precision {
                self.overlay.show()
            }
        }
    }

    private func setScreenMapArea(_ rect: NSRect) {
        HRect.setScreenMapArea(rect, screen: NSRect.screen(), forTablet: Int32(lastUsedTablet))
    }

    func setPrecisionMode(at: NSPoint) {
        var rect = NSZeroRect
        rect.fillScreen(withAspectRatio: store.aspectRatio)
        rect.scale(by: store.scale)
        rect.moveWithinScreen(to: at)
        setScreenMapArea(rect)
        overlay.move(to: rect)
        overlay.flash()
    }

    func setFullScreenMode() {
        var rect = NSZeroRect
        rect.fillScreen(withAspectRatio: store.aspectRatio)
        rect.centerInScreen()
        setScreenMapArea(rect)
        overlay.hide()
    }

    func applicationDidFinishLaunching(_: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_: NSApplication) -> Bool {
        true
    }
}
