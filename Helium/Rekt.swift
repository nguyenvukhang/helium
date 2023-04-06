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
    mutating func scale(by: Double) {
        size.width *= by
        size.height *= by
    }

    /**
     * Moves the rect such that its center is as close as possible to the
     * cursor while still being in the bounds.
     */
    mutating func move(to: NSPoint, within: NSRect) {
        let lx = width / 2, ly = height / 2
        let rx = within.width - lx, ry = within.height - ly
        origin.x = min(max(lx, to.x), rx) - lx
        origin.y = min(max(ly, to.y), ry) - ly
    }

    /**
     * Moves the rect such that its center is as close as possible to the
     * cursor while still being in the screen.
     */
    mutating func moveWithinScreen(to: NSPoint) {
        move(to: to, within: NSRect.screen())
    }

    /**
     * Fills a parent rect, given an aspect ratio constraint
     */
    mutating func fill(_ parent: NSRect, withAspectRatio: Double) {
        size.width = min(parent.height * withAspectRatio, parent.width)
        size.height = width / withAspectRatio
    }

    /**
     * Fills the current screen, given an aspect ratio constraint
     */
    mutating func fillScreen(withAspectRatio: Double) {
        fill(NSRect.screen(), withAspectRatio: withAspectRatio)
    }

    /**
     * Center a child rect in a parent rect.
     * Parent's origin is The origin.
     */
    mutating func center(within: NSRect) {
        origin.x = (within.width - width) / 2
        origin.y = (within.height - height) / 2
    }

    /**
     * Center a rect in the current screen.
     */
    mutating func centerInScreen() {
        center(within: NSRect.screen())
    }

    /**
     * Checks if point is within a distance from edge.
     */
    func nearEdge(point: NSPoint, tolerance: Double) -> Bool {
        if min(abs(point.x - minX), abs(point.x - maxX)) <= tolerance {
            return true
        }
        if min(abs(point.y - minY), abs(point.y - maxY)) <= tolerance {
            return true
        }
        return false
    }

    static func precision(at: NSPoint, scale: Double, aspectRatio: Double) -> NSRect {
        var rect = NSZeroRect
        rect.fillScreen(withAspectRatio: aspectRatio)
        rect.scale(by: scale)
        rect.moveWithinScreen(to: at)
        return rect
    }

    static func fullscreen(aspectRatio: Double) -> NSRect {
        var rect = NSZeroRect
        rect.fillScreen(withAspectRatio: aspectRatio)
        rect.centerInScreen()
        return rect
    }
}
