//
//  Helium.swift
//  Helium
//
//  Created by khang on 7/4/23.
//

import Cocoa

/**
 * Wraps Wacom with Helium's app state.
 * This includes preferences and running-state variables such as last-used tablet.
 */
class Helium: Store {
    var showBounds: Pair<String>
    var mode: Mode
    var lastUsedTablet = Ref(0) // initialize with invalid tablet ID
    private let overlay: Overlay
    var penIsProximate: Bool = false

    override init() {
        self.showBounds = Pair(on: "Hide Bounds", off: "Show Bounds", true)
        self.mode = .fullscreen
        self.overlay = Overlay()
        super.init()
    }

    func overlayWindow() -> Overlay { overlay }
    func showOverlay() { if mode == .precision && showBounds.on { overlay.show() } }
    func hideOverlay() { overlay.hide() }
    func toggleMode() { mode.next(); refresh() }
    func refresh() { mode == .precision ? setPrecisionMode() : setFullScreenMode() }
    func toggleBounds() { self.showBounds.toggle(); hideOverlay(); showOverlay(); }

    /** Make the tablet cover the area around the cursor's current location. */
    func setPrecisionMode() { setPrecisionMode(at: NSEvent.mouseLocation) }

    /** Make the tablet cover the area around the specified point. */
    func setPrecisionMode(at point: NSPoint) {
        mode = .precision
        let screen = NSRect.screen()
        let area = screen.precision(at: point, scale: scale, aspectRatio: aspectRatio)
        setTablet(to: area)
        moveOverlay(to: area)
        
        if penIsProximate {
            overlay.show()
        } else {
            overlay.flash()
        }
    }

    /** Make the tablet cover the whole screen. */
    func setFullScreenMode() {
        mode = .fullscreen
        let area = NSRect.primaryScreen()
        setTablet(to: area)
        overlay.fullscreen(to: area, lineColor: lineColor, lineWidth: lineWidth, cornerLength: cornerLength)
        overlay.flash()
    }

    /** Rehydrate running state after settings have changed */
    func reloadSettings() {
        let screen = NSRect.screen()
        let cursor = NSEvent.mouseLocation
        let area = screen.precision(at: cursor, scale: scale, aspectRatio: aspectRatio)
        moveOverlay(to: area)
        overlay.flash()
    }

    /** Move overlay to cover target NSRect */
    private func moveOverlay(to rect: NSRect) {
        overlay.move(to: rect, lineColor: lineColor, lineWidth: lineWidth, cornerLength: cornerLength)
    }

    /**
     * Sends a WacomTabletDriver API call to override tablet map area.
     * Also makes the overlay follow wherever it goes.
     */
    private func setTablet(to rect: NSRect) {
        ObjCWacom.setScreenMapArea(rect, tabletId: Int32(lastUsedTablet.val))
    }

    /** Reset screen map area to current screen. For use upon exiting. */
    func reset() {
        ObjCWacom.setScreenMapArea(NSRect.screen(), tabletId: Int32(lastUsedTablet.val))
    }
}
