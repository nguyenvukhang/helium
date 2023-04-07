//
//  Wacom.swift
//  Helium
//
//  Created by khang on 7/4/23.
//

import Foundation

class Wacom {
    private var screen: NSRect
    private var lastUsedTablet: Ref<Int>

    init() {
        self.screen = NSZeroRect
        self.lastUsedTablet = Ref(0) // invalid tablet ID
    }

    func setLastUsedTablet(_ id: Int) {
        lastUsedTablet.val = id
    }

    /**
     * Set focus on the area around the cursor.
     */
    func setPrecisionMode(at: NSPoint, scale: Double, aspectRatio: Double) -> NSRect {
        updateCurrentScreen()
        var rect = NSZeroRect
        rect.fill(screen, withAspectRatio: aspectRatio)
        rect.scale(by: scale)
        rect.move(to: at, within: screen)
        setBounds(to: rect)
        return rect
    }

    /**
     * Make the tablet cover the whole screen.
     */
    func setFullScreenMode(withAspectRatio: Double) -> NSRect {
        updateCurrentScreen()
        var rect = NSZeroRect
        rect.fill(screen, withAspectRatio: withAspectRatio)
        rect.center(within: screen)
        setBounds(to: rect)
        return rect
    }
    
    /**
     * Reset to the entire screen, with aspect ratio out the window.
     * To use when the app terminates.
     */
    func reset() {
        updateCurrentScreen()
        setBounds(to: screen)
    }

    private func updateCurrentScreen() {
        screen = NSScreen.screens[0].frame
    }

    private func setBounds(to: NSRect) {
        ObjCWacom.setScreenMapArea(to, screen: screen, tabletId: Int32(lastUsedTablet.val))
    }
}
