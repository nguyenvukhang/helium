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
}

class Overlay: NSWindow {
    private var enabled: Bool
    private let padding: Double = 10
    private let store: Store
    private var bounds: NSBezierPath

    init() {
        self.store = Store()
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
        target.origin.x -= padding
        target.origin.y -= padding

        if frame.size.equalTo(to.size) {
            // no re-draw required, since rect is same size
            setFrameOrigin(to.origin)
            return
        }

        target.size.width += 2 * padding
        target.size.height += 2 * padding
        setFrame(target, display: true)
        drawBorder()
    }

    func drawBorder() {
        let bg = NSImage(size: frame.size)
        bg.lockFocus()

        store.lineColor.set()
        bounds.lineWidth = store.lineWidth

        let f = frame, p = padding, l = store.cornerLength
        let x1 = p, x2 = f.size.width - p
        let y1 = p, y2 = f.size.height - p

        bounds.removeAllPoints()

        bounds.moveTo(x1 + l, y1)
        bounds.lineTo(x1, y1)
        bounds.lineTo(x1, y1 + l)
        bounds.moveTo(x1 + l, y2)
        bounds.lineTo(x1, y2)
        bounds.lineTo(x1, y2 - l)
        bounds.moveTo(x2 - l, y1)
        bounds.lineTo(x2, y1)
        bounds.lineTo(x2, y1 + l)
        bounds.moveTo(x2 - l, y2)
        bounds.lineTo(x2, y2)
        bounds.lineTo(x2, y2 - l)

        bounds.stroke()

        bg.unlockFocus()
        backgroundColor = NSColor(patternImage: bg)
    }

    func setEnabled(to: Bool) {
        enabled = to
    }
}
