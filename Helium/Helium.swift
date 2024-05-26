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
    var showBoundsMenubarText: Pair<String>
    var mode: Mode
    let overlay: Overlay
    var lastUsedTablet: Int32 = 0 // initialize with invalid tablet ID

    var penInProximity: Bool = false {
        didSet {
            if penInProximity { showOverlay() } else { hideOverlay() }
        }
    }

    override init() {
        self.showBoundsMenubarText = Pair(on: "Hide Bounds", off: "Show Bounds", true)
        self.mode = .fullscreen
        self.overlay = Overlay()
        super.init()
    }

    func showOverlay() {
        if mode == .precision, showBoundsMenubarText.on {
            overlay.show()
        }
    }

    func hideOverlay() {
        overlay.hide()
    }

    func toggleMode() { mode.next(); refresh() }

    func refresh() {
        switch mode {
        case .precision: setPrecisionMode()
        case .fullscreen: setFullScreenMode()
        }
    }

    /** Make the tablet cover the area around the cursor's current location. */
    func setPrecisionMode() {
        mode = .precision
        let frame = NSScreen.current().frame
        let area = frame.precisionModeFrame(at: NSEvent.mouseLocation, scale: scale, aspectRatio: aspectRatio)
        setTabletMapArea(to: area)
        moveOverlay(to: area)
        if penInProximity {
            overlay.show()
        } else {
            overlay.flash()
        }
    }

    /** Make the tablet cover the whole screen that contains the user's cursor. */
    func setFullScreenMode() {
        mode = .fullscreen
        var frame = NSScreen.current().frame
        if fullscreenKeepAspectRatio {
            frame = frame.centeredSubRect(withAspectRatio: aspectRatio)
        }
        setTabletMapArea(to: frame)
        overlay.fullscreen(to: &frame, lineColor: lineColor, lineWidth: lineWidth, cornerLength: cornerLength)
        overlay.flash()
    }

    /** Rehydrate running state after settings have changed */
    func previewOverlay() {
        let area = NSScreen.current().frame.precisionModeFrame(
            at: NSEvent.mouseLocation,
            scale: scale,
            aspectRatio: aspectRatio)
        moveOverlay(to: area)
        overlay.flash()
    }

    /** Move overlay to cover target NSRect */
    private func moveOverlay(to rect: NSRect) {
        overlay.set(to: rect, lineColor: lineColor, lineWidth: lineWidth, cornerLength: cornerLength)
    }

    /**
     * Sends a WacomTabletDriver API call to override tablet map area.
     * Also makes the overlay follow wherever it goes.
     */
    private func setTabletMapArea(to rect: NSRect) {
        ObjCWacom.setScreenMapArea(rect, tabletId: lastUsedTablet)
    }

    /** Reset screen map area to current screen. For use upon exiting. */
    func reset() {
        ObjCWacom.setScreenMapArea(NSScreen.current().frame, tabletId: lastUsedTablet)
    }
}
