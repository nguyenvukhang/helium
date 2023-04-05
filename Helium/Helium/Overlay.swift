//
//  Overlay.swift
//  Helium
//
//  Created by khang on 5/4/23.
//

import Foundation

extension NSBezierPath {
    func moveTo(_ x: CGFloat, _ y: CGFloat) {
        move(to: NSMakePoint(x, y))
    }

    func lineTo(_ x: CGFloat, _ y: CGFloat) {
        line(to: NSMakePoint(x, y))
    }
}

class Overlay: NSWindow {
    private var enabled: Bool
    private let padding: CGFloat = 10

    init() {
        self.enabled = true
        super.init(contentRect: NSMakeRect(0, 0, 1, 1), styleMask: .borderless, backing: .buffered, defer: true)
        ignoresMouseEvents = true
        level = .floating
        alphaValue = 0
    }

    private func animateAlpha(to: CGFloat, over: TimeInterval) {
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
        if !enabled {
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

    private func drawCorners(_ bz: NSBezierPath, length: CGFloat, padding: CGFloat) {
        let f = frame, p = padding, l = length
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
        let bg = NSImage.init(size: frame.size)
        bg.lockFocus()

        let color = NSColor(red: 0.925, green: 0.282, blue: 0.600, alpha: 0.5)
        color.set()

        let bz = NSBezierPath()
        bz.lineWidth = 5.0
        drawCorners(bz, length: 32, padding: padding - bz.lineWidth / 2)
        bz.stroke()

        bg.unlockFocus()
        backgroundColor = NSColor(patternImage: bg)
    }
}
