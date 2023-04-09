//
//  Rekt.swift
//  Helium
//
//  Created by khang on 5/4/23.
//

import Foundation

extension NSRect {
    static func screen() -> Self { NSScreen.screens[0].frame }

    /** Fills a parent rect, given an aspect ratio constraint */
    init(parent: NSRect, withAspectRatio: Double) {
        self.init()
        size.width = min(parent.height * withAspectRatio, parent.width)
        size.height = width / withAspectRatio
    }

    /** Scales a rect. Origin is invariant. */
    mutating func scale(by: Double) { size.width *= by; size.height *= by }

    /**
     * Constrained inside of NSRect `within`, minimize the distance
     * from the center of the rect to NSPoint `to`.
     */
    mutating func move(to: NSPoint, within: NSRect) {
        origin.x = min(max(0, to.x - width / 2), within.width - width)
        origin.y = min(max(0, to.y - height / 2), within.height - height)
    }

    /** Center a in a parent rect. Parent's origin is The origin. */
    mutating func center(within: NSRect) {
        origin.x = (within.width - width) / 2
        origin.y = (within.height - height) / 2
    }

    func fill(withAspectRatio: Double) -> NSRect {
        var rect = NSRect(parent: self, withAspectRatio: withAspectRatio)
        rect.center(within: self)
        return rect
    }

    func precision(at: NSPoint, scale: Double, aspectRatio: Double) -> NSRect {
        var rect = NSRect(parent: self, withAspectRatio: aspectRatio)
        rect.scale(by: scale)
        rect.move(to: at, within: self)
        return rect
    }
}
