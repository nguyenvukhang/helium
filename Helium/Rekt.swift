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
        origin.x = min(max(0, to.x - width / 2), within.width - width)
        origin.y = min(max(0, to.y - height / 2), within.height - height)
    }

    /**
     * Fills a parent rect, given an aspect ratio constraint
     */
    mutating func fill(_ parent: NSRect, withAspectRatio: Double) {
        size.width = min(parent.height * withAspectRatio, parent.width)
        size.height = width / withAspectRatio
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

    /**
     * Generates a NSRect that precision mode should start at, given
     * current cursor position and current screen.
     *
     * Constrained by scale and aspect ratio
     */
    static func precision(at: NSPoint, scale: Double, aspectRatio: Double) -> NSRect {
        var rect = NSZeroRect
        let screen = NSRect.screen()
        rect.fill(screen, withAspectRatio: aspectRatio)
        rect.scale(by: scale)
        rect.move(to: at, within: screen)
        return rect
    }

    /**
     * Generates a NSRect that fills the current screen.

     * Constrained by scale and aspect ratio
     */
    static func fullscreen(aspectRatio: Double) -> NSRect {
        var rect = NSZeroRect
        let screen = NSRect.screen()
        rect.fill(screen, withAspectRatio: aspectRatio)
        rect.center(within: screen)
        return rect
    }
}
