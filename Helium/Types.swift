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

    mutating func next() {
        self = self == .precision
            ? .fullscreen
            : .precision
    }

    var menubarText: String { switch self {
    case .fullscreen: "Use Precision Mode" // when the mode is currently fullscreen, we want the button to show this
    case .precision: "Use Fullscreen Mode"
    } }

    /** Icon named used to index `Assets.xcassets` */
    private var iconName: String { switch self {
    case .precision: "Precision"
    case .fullscreen: "Fullscreen"
    } }

    var image: NSImage? {
        NSImage(named: iconName)
    }
}

/** Bind a data pair that is likely to be toggled. */
final class Pair<T> {
    private let v: (T, T)
    var on: Bool
    init(on: T, off: T, _ x: Bool) { self.v = (on, off); self.on = x }
    func toggle() { on = !on }
    func get() -> T { on ? v.0 : v.1 }
}

extension NSPoint {
    /** Checks if point is within a distance from edge of NSRect. */
    func nearEdge(of rect: NSRect, by x: Double) -> Bool {
        min(abs(x - rect.minX), abs(x - rect.maxX)) <= x || min(abs(y - rect.minY), abs(y - rect.maxY)) <= x
    }
}

extension NSScreen {
    /**
     * Gets the screen that contains the user's cursor.
     */
    static func current() -> NSScreen {
        NSScreen.screens.first { s in NSPointInRect(NSEvent.mouseLocation, s.frame) }!
    }
}
