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

    /** Checks if point is within a distance from edge. */
    func nearEdge(pt: NSPoint, dist: Double) -> Bool {
        min(abs(pt.x - minX), abs(pt.x - maxX)) <= dist || min(abs(pt.y - minY), abs(pt.y - maxY)) <= dist
    }
}
