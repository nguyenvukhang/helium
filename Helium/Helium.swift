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
        self.store = Store()
        self.mode = .fullscreen
        self.overlay = Overlay()
        self.showBounds = Pair(on: "Hide Bounds", off: "Show Bounds", true)
        super.init()
    }

    func overlayWindow() -> Overlay { overlay }
    func showOverlay() { if showBounds.on { overlay.show() } }
    func hideOverlay() { overlay.hide() }

    /**
     * Toggles the mode and enters that new mode
     */
    func toggleMode() {
        mode.next() == .fullscreen ? setFullScreenMode() : setPrecisionMode()
    }

    func refresh() {
        mode == .fullscreen ? setFullScreenMode() : setPrecisionMode()
    }

    /**
     * Set focus on the area around the specified point.
     */
    func setPrecisionMode(at: NSPoint) {
        mode = .precision
        overlay.move(to: super.setPrecisionMode(at: at, scale: store.scale, aspectRatio: store.getAspectRatio()), store: store)
        overlay.flash()
    }

    /**
     * Set focus on the area around the cursor's current location.
     */
    func setPrecisionMode() {
        setPrecisionMode(at: NSEvent.mouseLocation)
    }

    /**
     * Make the tablet cover the whole screen.
     */
    func setFullScreenMode() {
        mode = .fullscreen
        overlay.move(to: super.setFullScreenMode(withAspectRatio: store.getAspectRatio()), store: store)
    }
}
