//
//  Wacom.swift
//  Helium
//
//  Created by khang on 7/4/23.
//

import Foundation

class Wacom {
    var lastUsedTablet = Ref(0) // invalid tablet ID

    /** Set focus on the area around the cursor. */
    func setPrecisionBounds(at: NSPoint, scale: Double, aspectRatio: Double) -> NSRect {
        let rect = NSRect.screen().precision(at: at, scale: scale, aspectRatio: aspectRatio)
        setTablet(to: rect)
        return rect
    }

    /** Make the tablet cover the whole screen. */
    func setFullScreenBounds(withAspectRatio: Double) -> NSRect {
        let rect = NSRect.screen().fullscreen(withAspectRatio: withAspectRatio)
        setTablet(to: rect)
        return rect
    }

    func reset() { setTablet(to: NSRect.screen()) }
    func setTablet(to: NSRect) {
        ObjCWacom.setScreenMapArea(to, tabletId: Int32(lastUsedTablet.val))
    }
}
