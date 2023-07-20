//
//  Types.swift
//  intuous
//
//  Created by khang on 5/4/23.
//

import Cocoa

/**
 * A binary enum that just has better readability
 */
enum Mode {
    case precision
    case fullscreen
    mutating func next() { self = self == .precision ? .fullscreen : .precision }
    var text: String { self == .precision ? "Use Fullscreen Mode" : "Use Precision Mode" }
    var icon: String { self == .precision ? "Precision" : "Fullscreen" }
    var image: NSImage? { NSImage(named: icon) }
}

/** Bind a data pair that is likely to be toggled. */
final class Pair<T> {
    private let v: (T, T)
    var on: Bool
    init(on: T, off: T, _ x: Bool) { self.v = (on, off); self.on = x }
    func toggle() { on = !on }
    func get() -> T { on ? v.0 : v.1 }
}

/** A simple reference class to store references to primitives */
final class Ref<T> { var val: T; init(_ v: T) { self.val = v } }

extension NSPoint {
    /** Checks if point is within a distance from edge of NSRect. */
    func nearEdge(of rect: NSRect, by x: Double) -> Bool {
        min(abs(x - rect.minX), abs(x - rect.maxX)) <= x || min(abs(y - rect.minY), abs(y - rect.maxY)) <= x
    }
}
