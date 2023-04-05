//
//  Store.swift
//  Helium
//
//  Created by khang on 5/4/23.
//

import Foundation

class Store {
    private let x = UserDefaults.standard

    var firstTime: Bool {
        get {
            x.bool(forKey: "init")

        } set {
            x.set(true, forKey: "init")
        }
    }

    var aspectRatioWidth: Double {
        get {
            x.double(forKey: "aspect-ratio-width")
        }
        set(w) {
            x.set(w, forKey: "aspect-ratio-width")
        }
    }

    var moveOnEdgeTouch: Bool {
        get {
            x.bool(forKey: "move-on-edge-touch")

        } set(v) {
            x.set(v, forKey: "move-on-edge-touch")
        }
    }

    var aspectRatioHeight: Double {
        get {
            x.double(forKey: "aspect-ratio-height")
        }
        set(h) {
            x.set(h, forKey: "aspect-ratio-height")
        }
    }

    var aspectRatio: Double {
        let w = x.double(forKey: "aspect-ratio-width")
        let h = x.double(forKey: "aspect-ratio-height")
        return w / h
    }

    var scale: Double {
        get {
            x.double(forKey: "scale")
        }
        set(v) {
            x.set(v, forKey: "scale")
        }
    }

    var cornerLength: Double {
        get {
            x.double(forKey: "corner-length")
        }
        set(v) {
            x.set(v, forKey: "corner-length")
        }
    }

    var lineWidth: Double {
        get {
            x.double(forKey: "line-width")
        }
        set(v) {
            x.set(v, forKey: "line-width")
        }
    }

    var lineColor: NSColor {
        get {
            let r = x.double(forKey: "line-color-R")
            let g = x.double(forKey: "line-color-G")
            let b = x.double(forKey: "line-color-B")
            let a = x.double(forKey: "line-color-A")
            return NSColor(red: r, green: g, blue: b, alpha: a)
        }
        set(v) {
            x.set(v.redComponent, forKey: "line-color-R")
            x.set(v.greenComponent, forKey: "line-color-G")
            x.set(v.blueComponent, forKey: "line-color-B")
            x.set(v.alphaComponent, forKey: "line-color-A")
        }
    }

    func initializeDefaults() {
        scale = 0.48
        lineColor = NSColor(red: 0.925, green: 0.282, blue: 0.600, alpha: 0.5)
        aspectRatioWidth = 16
        aspectRatioHeight = 10
        cornerLength = 100
        lineWidth = 5
    }
}
