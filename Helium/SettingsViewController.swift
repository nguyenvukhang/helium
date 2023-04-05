//
//  ViewController.swift
//  Helium
//
//  Created by khang on 5/4/23.
//

import Cocoa

class Store {
    private let x = UserDefaults.standard

    var aspectRatio: (Double, Double) {
        get {
            let w = x.double(forKey: "aspect-ratio-width")
            let h = x.double(forKey: "aspect-ratio-height")
            return (w, h)
        }
        set(v) {
            let (w, h) = v
            x.set(w, forKey: "aspect-ratio-width")
            x.set(h, forKey: "aspect-ratio-height")
        }
    }

    func setAspectRatioWidth(_ w: CGFloat) {
        x.set(w, forKey: "aspect-ratio-width")
    }

    func setAspectRatioHeight(_ h: CGFloat) {
        x.set(h, forKey: "aspect-ratio-height")
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
}

class SettingsViewController: NSViewController {
    @IBOutlet var scaleValue: NSTextField!
    @IBOutlet var cornerLength: NSTextField!
    @IBOutlet var scaleSlider: NSSliderCell!
    @IBOutlet var lineColor: NSColorWell!
    @IBOutlet weak var lineWidth: NSTextField!
    @IBOutlet weak var aspectRatioWidth: NSTextField!
    @IBOutlet weak var aspectRatioHeight: NSTextField!
    
    private let store = Store()

    override func viewDidLoad() {
        super.viewDidLoad()
        setScale(store.scale)
        lineColor.color = store.lineColor
        lineWidth.stringValue = round2(store.lineWidth)
        cornerLength.stringValue = round2(store.cornerLength)
        let (w,h) = store.aspectRatio
        aspectRatioWidth.stringValue = round2(w)
        aspectRatioHeight.stringValue = round2(h)
    }

    private func initializeDefaults() {
        store.scale = 1.6
        lineColor.color = NSColor(red: 0.925, green: 0.282, blue: 0.600, alpha: 0.5)
    }

    override func awakeFromNib() {}
    
    private func round2(_ x: Double) -> String {
        String(format: "%0.2f", x)
    }

    private func setScale(_ s: CGFloat) {
        scaleValue.stringValue = round2(s)
        scaleSlider.doubleValue = s
        store.scale = s
    }

    @IBAction func scaleDidChange(_ sender: AnyObject) {
        setScale(sender.doubleValue)
    }

    @IBAction func colorDidChange(_ sender: NSColorWell) {
        NSLog(sender.color.debugDescription)
        store.lineColor = sender.color
    }

    @IBAction func lineWidthDidChange(_ sender: NSTextField) {
        store.lineWidth = sender.doubleValue
    }

    @IBAction func aspectRatioWidthDidChange(_ sender: NSTextField) {
        store.setAspectRatioWidth(sender.doubleValue)
    }

    @IBAction func aspectRatioHeightDidChange(_ sender: NSTextField) {
        store.setAspectRatioHeight(sender.doubleValue)
    }

    @IBAction func cornerLengthDidChange(_ sender: NSTextField) {
        store.cornerLength = sender.doubleValue
    }
}
