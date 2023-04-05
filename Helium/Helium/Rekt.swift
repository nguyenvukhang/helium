//
//  Rekt.swift
//  Helium
//
//  Created by khang on 5/4/23.
//

import Foundation

extension NSRect {
    static func screen() -> Self {
        NSScreen.screens[0].frame
    }

    /**
     * Scales a rect. Note that the origin (bottom-left corner)
     * is the invariant of this transformation, not the center.
     */
    mutating func scale(by: CGFloat) -> Self {
        size.width *= by
        size.height *= by
        return self
    }

    /**
     * Moves the rect such that its center is as close as possible to the
     * cursor while still being in the bounds.
     */
    mutating func move(to: NSPoint, within: NSRect) -> Self {
        let lx = size.width / 2, ly = size.height / 2
        let rx = within.size.width - lx, ry = within.size.height - lx
        origin.x = min(max(lx, to.x), rx) - lx
        origin.y = min(max(ly, to.y), ry) - ly
        return self
    }

    /**
     * Moves the rect such that its center is as close as possible to the
     * cursor while still being in the screen.
     */
    mutating func moveWithinScreen(to: NSPoint) -> Self {
        move(to: to, within: NSRect.screen())
    }

    /**
     * Fills a parent rect, given an aspect ratio constraint
     */
    mutating func fill(_ parent: NSRect, withAspectRatio: CGFloat) -> Self {
        size.width = min(parent.size.height * withAspectRatio, parent.size.width)
        size.height = size.width / withAspectRatio
        return self
    }

    /**
     * Fills the current screen, given an aspect ratio constraint
     */
    mutating func fillScreen(withAspectRatio: CGFloat) -> Self {
        fill(NSRect.screen(), withAspectRatio: withAspectRatio)
    }

    /**
     * Center a child rect in a parent rect.
     * Parent's origin is The origin.
     */
    mutating func center(within: NSRect) -> Self {
        origin.x = (within.size.width - size.width) / 2
        origin.y = (within.size.height - size.height) / 2
        return self
    }

    /**
     * Center a rect in the current screen.
     */
    mutating func centerInScreen() -> Self {
        center(within: NSRect.screen())
    }
}
