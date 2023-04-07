//
//  Overlay.swift
//  Helium
//
//  Created by khang on 5/4/23.
//

import Foundation

extension NSBezierPath {
    func take(_ path: NSBezierPath) {
        removeAllPoints()
        append(path)
    }

    // take a path and append it 4 times in all 4 flipped states
    func addAll4Orientations(path: NSBezierPath) {
        let u = path, v = NSBezierPath()
        v.take(u)
        v.transform(using: AffineTransform(scaleByX: -1, byY: 1))
        u.append(v)
        v.take(u)
        v.transform(using: AffineTransform(scaleByX: 1, byY: -1))
        append(v)
        append(u)
    }

    func drawBounds(rect: NSRect, length: Double, margin: Double) {
        // px that the drawing will exceed the frame
        let exceed = lineWidth / 2
        let p = margin - exceed
        let pad = AffineTransform(translationByX: p, byY: p)
        let originToCenter = AffineTransform(translationByX: rect.width / 2, byY: rect.height / 2)

        // Draw an L
        let l = NSBezierPath()
        l.move(to: NSPoint(x: 0, y: length))
        l.line(to: NSPoint(x: 0, y: 0))
        l.line(to: NSPoint(x: length, y: 0))
        l.transform(using: pad)

        // Draw all 4 orientations
        l.transform(using: originToCenter.inverted()!)
        addAll4Orientations(path: l)
        transform(using: originToCenter)
    }
}

class Overlay: NSWindow {
    private let margin = 16.0

    init() {
        super.init(contentRect: NSMakeRect(0, 0, 0, 1), styleMask: .borderless, backing: .buffered, defer: true)
        ignoresMouseEvents = true
        level = .screenSaver
        alphaValue = 0
    }

    func show() { alphaValue = 1 }
    func hide() { animateAlpha(to: 0, over: 1.0) }
    func flash() { show(); hide() }

    func move(to: NSRect, store: Store) {
        var target = to
        target.origin.x -= margin
        target.origin.y -= margin

        if frame.size.equalTo(to.size) {
            // no re-draw required, since rect is same size
            setFrameOrigin(to.origin)
            return
        }

        target.size.width += margin * 2
        target.size.height += margin * 2
        setFrame(target, display: true)
        drawBorder(store: store)
    }

    // debugging function to add real bounds to the actual NSWindow boundary rect
    func addWindowBounds(color: NSColor) {
        let bz = NSBezierPath(rect: NSRect(origin: NSZeroPoint, size: frame.size))
        bz.lineWidth = 1
        color.setStroke()
        bz.stroke()
    }

    func drawBorder(store: Store) {
        let bg = NSImage(size: frame.size)
        bg.lockFocus()

        store.lineColor.set()

        let bounds = NSBezierPath()
        bounds.lineJoinStyle = .round

        bounds.lineWidth = store.lineWidth
        bounds.removeAllPoints()
        bounds.drawBounds(rect: frame, length: store.cornerLength, margin: margin)
        bounds.stroke()

        // addWindowBounds(color: .blue)

        bg.unlockFocus()
        backgroundColor = NSColor(patternImage: bg)
    }

    private func animateAlpha(to: Double, over: TimeInterval) {
        NSAnimationContext.beginGrouping()
        NSAnimationContext.current.duration = over
        animator().alphaValue = to
        NSAnimationContext.endGrouping()
    }
}
