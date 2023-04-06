//
//  Overlay.swift
//  Helium
//
//  Created by khang on 5/4/23.
//

import Foundation

extension NSBezierPath {
    func moveTo(_ x: Double, _ y: Double) {
        move(to: NSMakePoint(x, y))
    }

    func lineTo(_ x: Double, _ y: Double) {
        line(to: NSMakePoint(x, y))
    }
}

class Overlay: NSWindow {
    private var enabled: Bool
    private let padding: Double = 10
    private let store: Store

    init() {
        self.store = Store()
        self.enabled = true
        super.init(contentRect: NSMakeRect(0, 0, 1, 1), styleMask: .borderless, backing: .buffered, defer: true)
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
        let frame = NSMakeRect(to.origin.x - padding, to.origin.y - padding, to.size.width + 2 * padding, to.size.height + 2 * padding)
        setFrame(frame, display: true)
        drawBorder()
    }

    private func drawCorners(_ bz: NSBezierPath, length: Double, padding: Double) {
        let f = frame, p = padding, l = store.cornerLength
        let x1 = p, x2 = f.size.width - p, y1 = p, y2 = f.size.height - p
        bz.moveTo(x1 + l, y1)
        bz.lineTo(x1, y1)
        bz.lineTo(x1, y1 + l)
        bz.moveTo(x1 + l, y2)
        bz.lineTo(x1, y2)
        bz.lineTo(x1, y2 - l)
        bz.moveTo(x2 - l, y1)
        bz.lineTo(x2, y1)
        bz.lineTo(x2, y1 + l)
        bz.moveTo(x2 - l, y2)
        bz.lineTo(x2, y2)
        bz.lineTo(x2, y2 - l)
    }

    private func drawBorder() {
        let bg = NSImage(size: frame.size)
        bg.lockFocus()

        store.lineColor.set()

        let bz = NSBezierPath()
        bz.lineWidth = store.lineWidth
        drawCorners(bz, length: 32, padding: padding - bz.lineWidth / 2)
        bz.stroke()

        bg.unlockFocus()
        backgroundColor = NSColor(patternImage: bg)
    }

    func setEnabled(to: Bool) {
        enabled = to
    }
}
