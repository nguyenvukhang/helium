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

    override init() {
        self.store = Store()
        self.mode = .fullscreen
        self.showBounds = Pair(on: "Hide Bounds", off: "Show Bounds", true)
        super.init()
    }

    /**
     * Toggles the mode and enters that new mode
     */
    func toggleMode() -> NSRect {
        mode.next() == .fullscreen ? setFullScreenMode() : setPrecisionMode()
    }

    /**
     * Set focus on the area around the specified point.
     */
    func setPrecisionMode(at: NSPoint) -> NSRect {
        mode = .precision
        return super.setPrecisionMode(at: at, scale: store.scale, aspectRatio: store.getAspectRatio())
    }

    /**
     * Set focus on the area around the cursor's current location.
     */
    func setPrecisionMode() -> NSRect {
        setPrecisionMode(at: NSEvent.mouseLocation)
    }

    /**
     * Make the tablet cover the whole screen.
     */
    func setFullScreenMode() -> NSRect {
        mode = .fullscreen
        return super.setFullScreenMode(withAspectRatio: store.getAspectRatio())
    }
}
