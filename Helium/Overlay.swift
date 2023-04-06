//
//  Overlay.swift
//  Helium
//
//  Created by khang on 5/4/23.
//

import Foundation

extension NSBezierPath {
    func moveTo(_ x: Double, _ y: Double) {
        move(to: NSPoint(x: x, y: y))
    }

    func lineTo(_ x: Double, _ y: Double) {
        line(to: NSPoint(x: x, y: y))
    }

    func drawBounds(rect: NSRect, length: Double, extraPadding: Double) {
        let padding = self.lineWidth / 2 + extraPadding
        let l = length
        let x1 = padding, x2 = rect.width - padding
        let y1 = padding, y2 = rect.height - padding
        removeAllPoints()
        moveTo(x1 + l, y1)
        lineTo(x1, y1)
        lineTo(x1, y1 + l)
        moveTo(x1 + l, y2)
        lineTo(x1, y2)
        lineTo(x1, y2 - l)
        moveTo(x2 - l, y1)
        lineTo(x2, y1)
        lineTo(x2, y1 + l)
        moveTo(x2 - l, y2)
        lineTo(x2, y2)
        lineTo(x2, y2 - l)
    }
}

class Overlay: NSWindow {
    private let store: Store
    private var enabled: Bool
    private var bounds: NSBezierPath

    init(_ store: Store) {
        self.store = store
        self.enabled = true
        self.bounds = NSBezierPath()
        super.init(contentRect: NSMakeRect(0, 0, 1, 1), styleMask: .borderless, backing: .buffered, defer: true)
        drawBorder()
        ignoresMouseEvents = true
        level = .screenSaver
        alphaValue = 0
    }

    private func animateAlpha(to: Double, over: TimeInterval) {
        NSAnimationContext.beginGrouping()
        NSAnimationContext.current.duration = over
        animator().alphaValue = to
        NSAnimationContext.endGrouping()
    }

    func show() {
        if !enabled {
            return
        }
        alphaValue = 1
    }

    func hide() {
        animateAlpha(to: 0, over: 1.0)
    }

    func flash() {
        flash(force: false)
    }

    func flash(force: Bool) {
        if !force && !enabled {
            return
        }
        alphaValue = 1
        animateAlpha(to: 0, over: 1.0)
    }

    func move(to: NSRect) {
        var target = to
        let padding = bounds.lineWidth + 2
        target.origin.x -= padding / 2
        target.origin.y -= padding / 2

        if frame.size.equalTo(to.size) {
            // no re-draw required, since rect is same size
            setFrameOrigin(to.origin)
            return
        }

        target.size.width += padding
        target.size.height += padding
        setFrame(target, display: true)
        drawBorder()
    }

    // debugging function to add real bounds to the actual NSWindow boundary rect
    func addTrueBounds(color: NSColor) {
        let bz = NSBezierPath(rect: NSRect(origin: NSZeroPoint, size: frame.size))
        bz.lineWidth = 1
        color.setStroke()
        bz.stroke()
    }

    func drawBorder() {
        let bg = NSImage(size: frame.size)
        bg.lockFocus()

        store.lineColor.set()
        bounds.lineWidth = store.lineWidth
        bounds.drawBounds(rect: self.frame, length: store.cornerLength, extraPadding: 2)
        bounds.stroke()
        
        // addTrueBounds(color: .blue)

        bg.unlockFocus()
        backgroundColor = NSColor(patternImage: bg)
    }

    func setEnabled(to: Bool) {
        enabled = to
    }
}
