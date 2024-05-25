//
//  Overlay.swift
//  Helium
//
//  Created by khang on 5/4/23.
//

import Cocoa

extension NSBezierPath {
    /**
     * take a (bottom-left) path and add it 4 times in all 4 flipped states
     *                        ┌─       ─┐
     *
     *      · (0,0)       →        · (0,0)
     *
     * └─                     └─       ─┘
     */
    func addAll4Orientations(path u: NSBezierPath) {
        let v = u.copy() as! NSBezierPath
        v.transform(using: AffineTransform(scaleByX: -1, byY: 1))
        u.append(v)
        append(u)
        u.transform(using: AffineTransform(scaleByX: 1, byY: -1))
        append(u)
    }

    /**
     * Draws 4 Ls at each corner of the rect.
     */
    func drawBounds(rect: NSRect, length: Double, margin: Double) {
        // px that the drawing will exceed the frame
        let exceed = lineWidth / 2
        let pad = margin - exceed
        let originToCenter = AffineTransform(translationByX: rect.width / 2, byY: rect.height / 2)
        let length = min(length, (rect.width - margin) / 2, (rect.height - margin) / 2)

        // Draw an L
        let l = NSBezierPath()
        l.move(to: NSPoint(x: 0, y: length))
        l.line(to: NSPoint(x: 0, y: 0))
        l.line(to: NSPoint(x: length, y: 0))
        l.transform(using: AffineTransform(translationByX: pad, byY: pad))

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
        collectionBehavior = .canJoinAllSpaces
        ignoresMouseEvents = true
        level = .screenSaver
        alphaValue = 0
    }

    /**
     * Shows the overlay window (instant).
     */
    func show() {
        alphaValue = 1
    }

    /**
     * Hides the overlay window with a fade.
     */
    func hide() {
        animateAlpha(to: 0, over: 1.0)
    }

    /**
     * Shows then hides the overlay window.
     */
    func flash() {
        show(); hide()
    }

    /**
     * Sets all important parameters of the overlay
     */
    func set(to rect: NSRect, lineColor: NSColor, lineWidth: Double, cornerLength: Double) {
        var target = rect
        target.origin.x -= margin
        target.origin.y -= margin

        if frame.size.equalTo(rect.size) {
            // no re-draw required, since rect is same size
            setFrameOrigin(rect.origin)
            return
        }

        target.size.width += margin * 2
        target.size.height += margin * 2
        setFrame(target, display: true)
        drawBounds(lineColor: lineColor, lineWidth: lineWidth, cornerLength: cornerLength)
    }

    func fullscreen(to rect: inout NSRect, lineColor: NSColor, lineWidth: Double, cornerLength _: Double) {
        setFrame(rect, display: true)
        rect.origin = .zero
        // draw a circle in the middle of the screen being full-screened.
        let bg = NSImage(size: rect.size)
        bg.lockFocus()
        lineColor.set()
        var circRect = rect.centeredSubRect(withAspectRatio: 1)
        circRect.scale(by: 0.1)
        circRect.center(within: rect)
        let circ = NSBezierPath(ovalIn: circRect)
        circ.lineWidth = lineWidth
        circ.stroke()
        bg.unlockFocus()
        backgroundColor = NSColor(patternImage: bg)
    }

    // debugging function to add real bounds to the actual NSWindow boundary rect
    func addWindowBounds(color: NSColor) {
        let bz = NSBezierPath(rect: NSRect(origin: NSZeroPoint, size: frame.size))
        bz.lineWidth = 1
        color.setStroke()
        bz.stroke()
    }

    /**
     * Draws the 4 Ls around the window.
     */
    func drawBounds(lineColor: NSColor, lineWidth: Double, cornerLength: Double) {
        let bg = NSImage(size: frame.size)
        bg.lockFocus()
        lineColor.set()
        let bounds = NSBezierPath()
        bounds.lineJoinStyle = .round
        bounds.lineWidth = lineWidth
        bounds.drawBounds(rect: frame, length: cornerLength, margin: margin)
        bounds.stroke()
        bg.unlockFocus()
        backgroundColor = NSColor(patternImage: bg)
    }

    /**
     * Changes transparency of the overlay window, with an endpoint of `alpha`
     * and over a time interval `interval`.
     */
    private func animateAlpha(to alpha: Double, over interval: TimeInterval) {
        NSAnimationContext.beginGrouping()
        NSAnimationContext.current.duration = interval
        animator().alphaValue = alpha
        NSAnimationContext.endGrouping()
    }
}
