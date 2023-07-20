//
//  Rekt.swift
//  Helium
//
//  Created by khang on 5/4/23.
//

import Cocoa

extension NSRect {
    static func screen() -> Self {
        let mouseLocation = NSEvent.mouseLocation
        let screens = NSScreen.screens
        return (screens.first { NSMouseInRect(mouseLocation, $0.frame, false) })!.frame
    }

    /** Fills a parent rect, given an aspect ratio constraint */
    init(parent: NSRect, withAspectRatio ratio: Double) {
        self.init()
        size.width = min(parent.height * ratio, parent.width)
        size.height = width / ratio
        origin = NSPoint(x: parent.midX, y: parent.midY)
    }

    /** Scales a rect. Origin is invariant. */
    mutating func scale(by x: Double) { size.width *= x; size.height *= x }

    /**
     * Constrained inside of NSRect `within`, minimize the distance
     * from the center of the rect to NSPoint `to`.
     */
    mutating func move(to point: NSPoint, within screen: NSRect) {
        origin.x = min(
            max(screen.origin.x, point.x - width / 2),
            screen.maxX - width
        )
        origin.y = min(
            max(screen.origin.y, point.y - height / 2),
            screen.maxY - height
        )
    }

    /** Center a in a parent rect. Parent's origin is The origin. */
    mutating func center(within parent: NSRect) {
        origin = NSPoint(x: parent.midX, y: parent.midY)
    }

    func fill(withAspectRatio ratio: Double) -> NSRect {
        var rect = NSRect(parent: self, withAspectRatio: ratio)
        rect.center(within: self)
        return rect
    }

    /**
     * self is the screen that precision is set in
     */
    func precision(at point: NSPoint, scale: Double, aspectRatio: Double) -> NSRect {
        var rect = NSRect(parent: self, withAspectRatio: aspectRatio)
        rect.scale(by: scale)
        rect.move(to: point, within: self)
        return rect
    }
}
