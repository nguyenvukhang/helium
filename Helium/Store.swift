//
//  Store.swift
//  Helium
//
//  Created by khang on 5/4/23.
//

import Cocoa

class Store {
    private let x = UserDefaults.standard
    init() { if !setupExists { initializeDefaults() } }

    var setupExists: Bool {
        get { x.bool(forKey: "init") }
        set(v) { x.set(v, forKey: "init") }
    }

    var moveOnEdgeTouch: Bool {
        get { x.bool(forKey: "move-on-edge-touch") }
        set(v) { x.set(v, forKey: "move-on-edge-touch") }
    }

    var scale: Double {
        get { x.double(forKey: "scale") }
        set(v) { x.set(v, forKey: "scale") }
    }

    var cornerLength: Double {
        get { x.double(forKey: "corner-length") }
        set(v) { x.set(v, forKey: "corner-length") }
    }

    var lineWidth: Double {
        get { x.double(forKey: "line-width") }
        set(v) { x.set(v, forKey: "line-width") }
    }

    var aspectRatioHeight: Int {
        get { x.integer(forKey: "aspect-ratio-height") }
        set(v) { x.set(v, forKey: "aspect-ratio-height") }
    }

    var aspectRatioWidth: Int {
        get { x.integer(forKey: "aspect-ratio-width") }
        set(v) { x.set(v, forKey: "aspect-ratio-width") }
    }

    var aspectRatio: Double { Double(aspectRatioWidth) / Double(aspectRatioHeight) }

    var lineColor: NSColor {
        get {
            let r = x.double(forKey: "line-color-r")
            let g = x.double(forKey: "line-color-g")
            let b = x.double(forKey: "line-color-b")
            let a = x.double(forKey: "line-color-a")
            return NSColor(red: r, green: g, blue: b, alpha: a)
        }
        set(color) {
            x.set(color.redComponent, forKey: "line-color-r")
            x.set(color.greenComponent, forKey: "line-color-g")
            x.set(color.blueComponent, forKey: "line-color-b")
            x.set(color.alphaComponent, forKey: "line-color-a")
        }
    }

    func initializeDefaults() {
        setupExists = true
        scale = 0.48
        lineColor = NSColor(red: 0.925, green: 0.282, blue: 0.600, alpha: 0.5)
        aspectRatioWidth = 16
        aspectRatioHeight = 10
        cornerLength = 50
        lineWidth = 5
    }
}
