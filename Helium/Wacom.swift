//
//  Wacom.swift
//  Helium
//
//  Created by khang on 7/4/23.
//

import Foundation

class Wacom {
    private var screen: NSRect
    var lastUsedTablet: Ref<Int>

    init() {
        self.screen = NSZeroRect
        self.lastUsedTablet = Ref(0) // invalid tablet ID
    }

    /** Set focus on the area around the cursor. */
    func setPrecisionMode(at: NSPoint, scale: Double, aspectRatio: Double) -> NSRect {
        updateCurrentScreen()
        var rect = NSRect(parent: screen, withAspectRatio: aspectRatio)
        rect.scale(by: scale)
        rect.move(to: at, within: screen)
        setTablet(to: rect)
        return rect
    }

    /** Make the tablet cover the whole screen. */
    func setFullScreenMode(withAspectRatio: Double) -> NSRect {
        updateCurrentScreen()
        var rect = NSRect(parent: screen, withAspectRatio: withAspectRatio)
        rect.center(within: screen)
        setTablet(to: rect)
        return rect
    }

    func reset() { updateCurrentScreen(); setTablet(to: screen) }
    private func updateCurrentScreen() { screen = NSScreen.screens[0].frame }
    private func setTablet(to: NSRect) {
        ObjCWacom.setScreenMapArea(to, screen: screen, tabletId: Int32(lastUsedTablet.val))
    }
}
