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

    func take(_ path: NSBezierPath) {
        removeAllPoints()
        append(path)
    }

    // take a path and append it 4 times in all 4 flipped states
    func addAll4Orientations(path: NSBezierPath) {
        let u = NSBezierPath(), v = NSBezierPath()
        u.take(path)
        v.take(u)
        v.transform(using: AffineTransform(scaleByX: -1, byY: 1))
        u.append(v)
        v.take(u)
        v.transform(using: AffineTransform(scaleByX: 1, byY: -1))
        append(v)
        append(u)
    }

    func drawBounds(rect: NSRect, length: Double, padding: Double) {
        let p = lineWidth / 2 + padding
        let pad = AffineTransform(translationByX: p, byY: p)
        let originToCenter = AffineTransform(translationByX: rect.width / 2, byY: rect.height / 2)

        // Draw an L
        let l = NSBezierPath()
        l.moveTo(0, length)
        l.lineTo(0, 0)
        l.lineTo(length, 0)
        l.transform(using: pad)

        // Draw all 4 orientations
        l.transform(using: originToCenter.inverted()!)
        addAll4Orientations(path: l)
        transform(using: originToCenter)
    }
}

class Overlay: NSWindow {
    private let store: Store
    private var enabled: Bool
    private var bounds: NSBezierPath
    private let padding = 1.0

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
        let padding = store.lineWidth + padding
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
        bounds.removeAllPoints()
        bounds.drawBounds(rect: frame, length: store.cornerLength, padding: padding)
        bounds.stroke()

        // addTrueBounds(color: .blue)

        bg.unlockFocus()
        backgroundColor = NSColor(patternImage: bg)
    }

    func setEnabled(to: Bool) {
        enabled = to
    }
}
