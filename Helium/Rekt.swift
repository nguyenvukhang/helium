//
//  Rekt.swift
//  Helium
//
//  Created by khang on 5/4/23.
//

import Cocoa

extension NSRect {
    /** Fills a parent rect, given an aspect ratio constraint */
    init(parent: NSRect, withAspectRatio ratio: Double) {
        self.init()
        size.width = min(parent.height * ratio, parent.width)
        size.height = width / ratio
        origin = NSPoint(x: parent.midX, y: parent.midY)
    }

    /** Scales a rect. Origin is invariant. */
    mutating func scale(by x: Double) {
        size.width *= x
        size.height *= x
    }

    /**
     * Constrained inside of NSRect `within`, minimize the distance
     * from the center of the rect to NSPoint `to`.
     */
    mutating func moveCenter(to point: NSPoint, within screen: NSRect) {
        origin.x = min(
            max(screen.origin.x, point.x - width / 2),
            screen.maxX - width)
        origin.y = min(
            max(screen.origin.y, point.y - height / 2),
            screen.maxY - height)
    }

    /** Center self within a `parent` rect. */
    mutating func center(within parent: NSRect) {
        origin.x = parent.midX - width / 2
        origin.y = parent.midY - height / 2
    }

    /**
     * Creates a new `NSRect` smaller than `self`, centered within `self`,
     * and is of a particular aspect ratio.
     */
    func centeredSubRect(withAspectRatio ratio: Double) -> NSRect {
        var rect = NSRect(parent: self, withAspectRatio: ratio)
        rect.center(within: self)
        return rect
    }

    /**
     * Creates the `NSRect` which precision mode will be set to.
     */
    func precisionModeFrame(at point: NSPoint, scale: Double, aspectRatio: Double) -> NSRect {
        var rect = NSRect(parent: self, withAspectRatio: aspectRatio)
        rect.scale(by: scale)
        rect.moveCenter(to: point, within: self)
        return rect
    }
}
