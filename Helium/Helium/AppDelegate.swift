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
    private var statusBarItem: NSStatusItem!
    private var mode: Mode

    override init() {
        self.lastUsedTablet = 0 // 0 is an invalid tablet ID
        self.bar = StatusBar()
        self.mode = .fullscreen
        super.init()
        listenForEvents()
        bar.linkActions(togglePrecision: #selector(togglePrecision), togglePrecisionBounds: #selector(togglePrecisionBounds), quit: #selector(quit))
    }

    @objc func togglePrecision() {
        mode = mode.next()
        NSLog(mode.debug())
    }

    @objc func togglePrecisionBounds() {
        NSLog("Toggle precision bounds!")
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
        }
    }

    /**
     * This must only be called once.
     */
    private func listenForEvents() {
        NSEvent.addGlobalMonitorForEvents(matching: [.tabletProximity, .keyDown]) { event in
            if event.type == .tabletProximity && event.isEnteringProximity {
                self.lastUsedTablet = event.systemTabletID
            } else if event.type == .keyDown {
                self.handleKeyDown(event)
            }
        }
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
