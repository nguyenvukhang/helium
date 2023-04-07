//
//  Helium.swift
//  Helium
//
//  Created by khang on 7/4/23.
//

import Foundation

/**
 * Wraps Wacom with Helium's app state.
 * This includes preferences and running-state variables such as last-used tablet.
 */
class Helium: Wacom {
    var showBounds: Pair<String>
    var mode: Mode
    var store: Store
    private let overlay: Overlay

    override init() {
        self.showBounds = Pair(on: "Hide Bounds", off: "Show Bounds", true)
        self.mode = .fullscreen
        self.store = Store()
        self.overlay = Overlay(store: store)
        super.init()
    }

    func overlayWindow() -> Overlay { overlay }
    func showOverlay() { if showBounds.on { overlay.show() } }
    func hideOverlay() { overlay.hide() }
    func toggleMode() { mode.next(); refresh() }
    func refresh() { mode == .precision ? setPrecisionMode() : setFullScreenMode() }

    /** Set focus on the area around the cursor's current location. */
    func setPrecisionMode() { setPrecisionMode(at: NSEvent.mouseLocation) }

    /** Set focus on the area around the specified point. */
    func setPrecisionMode(at: NSPoint) {
        mode = .precision
        let screen = NSRect.screen()
        let area = screen.precision(at: at, scale: store.scale, aspectRatio: store.getAspectRatio())
        setTablet(to: area)
        overlay.flash()
    }

    /** Make the tablet cover the whole screen. */
    func setFullScreenMode() {
        mode = .fullscreen
        let screen = NSRect.screen()
        let area = screen.fullscreen(withAspectRatio: store.getAspectRatio())
        setTablet(to: area)
    }

    func reloadSettings() {
        let screen = NSRect.screen()
        let cursor = NSEvent.mouseLocation
        let area = screen.precision(at: cursor, scale: store.scale, aspectRatio: store.getAspectRatio())
        overlay.move(to: area)
        overlay.flash()
    }

    override func setTablet(to: NSRect) { super.setTablet(to: to); overlay.move(to: to) }
}
