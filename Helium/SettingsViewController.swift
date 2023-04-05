//
//  ViewController.swift
//  Helium
//
//  Created by khang on 5/4/23.
//

import Cocoa

class SettingsViewController: NSViewController {
    @IBOutlet var scaleValue: NSTextField!
    @IBOutlet var cornerLength: NSTextField!
    @IBOutlet var scaleSlider: NSSliderCell!
    @IBOutlet var lineColor: NSColorWell!
    @IBOutlet var lineWidth: NSTextField!
    @IBOutlet var aspectRatioWidth: NSTextField!
    @IBOutlet var aspectRatioHeight: NSTextField!
    @IBOutlet var resetAll: NSButton!
    private var overlay: Overlay?
    private var store: Store?

    private var readyToReset = false

    override func viewDidLoad() {
        super.viewDidLoad()
        NSColor.ignoresAlpha = false
    }

    private func loadAllFromStore() {
        guard let store = store else {
            return
        }
        setScale(store.scale)
        lineColor.color = store.lineColor
        lineWidth.stringValue = round2(store.lineWidth)
        cornerLength.stringValue = round2(store.cornerLength)
        aspectRatioWidth.stringValue = round2(store.aspectRatioWidth)
        aspectRatioHeight.stringValue = round2(store.aspectRatioHeight)
    }

    override func awakeFromNib() {}

    private func round2(_ x: Double) -> String {
        String(format: "%0.2f", x)
    }

    private func setScale(_ s: Double) {
        scaleValue.stringValue = round2(s * 100)
        scaleSlider.doubleValue = s
        store?.scale = s
    }

    func hydrate(overlay: Overlay, store: Store) {
        self.overlay = overlay
        self.store = store
        if store.firstTime {
            store.initializeDefaults()
        }
        loadAllFromStore()
    }

    private func preview() {
        var r = NSZeroRect
        r.fillScreen(withAspectRatio: store!.aspectRatio)
        r.scale(by: store!.scale)
        r.centerInScreen()
        overlay?.move(to: r)
        overlay?.flash(force: true)
    }

    @IBAction func scaleSliderDidChange(_ sender: AnyObject) {
        setScale(sender.doubleValue)
        preview()
    }

    @IBAction func scaleTextDidChange(_ sender: AnyObject) {
        setScale(sender.doubleValue / 100)
        preview()
    }

    @IBAction func colorDidChange(_ sender: NSColorWell) {
        store?.lineColor = sender.color
        preview()
    }

    @IBAction func lineWidthDidChange(_ sender: NSTextField) {
        store?.lineWidth = sender.doubleValue
        preview()
    }

    @IBAction func aspectRatioWidthDidChange(_ sender: NSTextField) {
        store?.aspectRatioWidth = sender.doubleValue
        preview()
    }

    @IBAction func aspectRatioHeightDidChange(_ sender: NSTextField) {
        store?.aspectRatioHeight = sender.doubleValue
        preview()
    }

    @IBAction func cornerLengthDidChange(_ sender: NSTextField) {
        store?.cornerLength = sender.doubleValue
        preview()
    }

    @IBAction func resetDidRequest(_ sender: NSButton) {
        if !readyToReset {
            readyToReset = true
            sender.bezelColor = .red
            sender.stringValue = "Confirm Reset"
            sender.title = "Confirm Reset"
        } else {
            store?.initializeDefaults()
            loadAllFromStore()
            sender.bezelColor = nil
            readyToReset = false
            sender.title = "Reset All Preferences"
        }
    }
}
