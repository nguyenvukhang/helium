//
//  Store.swift
//  Helium
//
//  Created by khang on 5/4/23.
//

import Foundation

class Store {
    private let x: UserDefaults
    var aspectRatio: AspectRatio

    init() {
        self.x = UserDefaults.standard
        self.aspectRatio = AspectRatio(x)
    }

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

    var lineColor: NSColor {
        get {
            guard
                let s = x.data(forKey: "line-color"),
                let u = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSColor.self, from: s),
                let color = u as NSColor?
            else {
                return NSColor.black
            }
            return color
        }
        set(color) {
            if let data = try? NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: false) {
                x.set(data, forKey: "line-color")
            }
        }
    }

    func initializeDefaults() {
        setupExists = true
        scale = 0.48
        lineColor = NSColor(red: 0.925, green: 0.282, blue: 0.600, alpha: 0.5)
        aspectRatio.width = 16
        aspectRatio.height = 10
        cornerLength = 50
        lineWidth = 5
    }

    func getAspectRatio() -> Double {
        aspectRatio.width / aspectRatio.height
    }

    struct AspectRatio {
        private let x: UserDefaults

        init(_ x: UserDefaults) { self.x = x }

        var height: Double {
            get { x.double(forKey: "aspect-ratio-height") }
            set(h) { x.set(h, forKey: "aspect-ratio-height") }
        }

        var width: Double {
            get { x.double(forKey: "aspect-ratio-width") }
            set(w) { x.set(w, forKey: "aspect-ratio-width") }
        }
    }
}
