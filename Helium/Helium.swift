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

    /** Set focus on the area around the specified point. */
    func setPrecisionMode(at: NSPoint) {
        mode = .precision
        overlay.move(to: setPrecisionBounds(at: at, scale: store.scale, aspectRatio: store.getAspectRatio()))
        overlay.flash()
    }

    /** Set focus on the area around the cursor's current location. */
    func setPrecisionMode() { setPrecisionMode(at: NSEvent.mouseLocation) }

    /** Make the tablet cover the whole screen. */
    func setFullScreenMode() {
        mode = .fullscreen
        overlay.move(to: setFullScreenBounds(withAspectRatio: store.getAspectRatio()))
    }

    func reloadSettings() {
        let prev = mode
        setPrecisionMode() // flash updates
        if prev == .fullscreen { setFullScreenMode() } // restore state
    }
}
