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
class Helium {
    var showBounds: Pair<String>
    var mode: Mode
    var store: Store
    var lastUsedTablet = Ref(0) // invalid tablet ID
    private let overlay: Overlay

    init() {
        self.showBounds = Pair(on: "Hide Bounds", off: "Show Bounds", true)
        self.mode = .fullscreen
        self.store = Store()
        self.overlay = Overlay(store: store)
    }

    func overlayWindow() -> Overlay { overlay }
    func showOverlay() { if mode == .precision && showBounds.on { overlay.show() } }
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

    func reset() {
        ObjCWacom.setScreenMapArea(NSRect.screen(), tabletId: Int32(lastUsedTablet.val))
    }

    private func setTablet(to: NSRect) {
        ObjCWacom.setScreenMapArea(to, tabletId: Int32(lastUsedTablet.val))
        overlay.move(to: to)
    }
}
