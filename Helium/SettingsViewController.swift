//
//  ViewController.swift
//  Helium
//
//  Created by khang on 5/4/23.
//

import Cocoa
import MASShortcut

/**
 * A whole bunch of pointing-and-clicking is required to build and
 * make sense of this. Best to open in XCode and view this together
 * with ./Base.lproj/Main.storyboard
 */
class SettingsViewController: NSViewController {
    @IBOutlet var scaleValue: NSTextField!
    @IBOutlet var cornerLength: NSTextField!
    @IBOutlet var scaleSlider: NSSliderCell!
    @IBOutlet var lineColor: NSColorWell!
    @IBOutlet var lineWidth: NSTextField!
    @IBOutlet var aspectRatioWidth: NSTextField!
    @IBOutlet var aspectRatioHeight: NSTextField!
    @IBOutlet var resetAll: NSButton!
    @IBOutlet var moveOnEdgeTouch: NSButton!
    @IBOutlet var precisionModeAction: MASShortcutView!
    @IBOutlet var fullscreenModeAction: MASShortcutView!
    @IBOutlet var toggleModeAction: MASShortcutView!

    private var helium: Helium?
    private var reset = Pair(on: "Confirm Restore", off: "Restore Defaults", false)

    override func viewDidLoad() {
        super.viewDidLoad()

        // so that the color picker will have alpha
        NSColor.ignoresAlpha = false
        resetAll.title = reset.get()

        Actions.associateView(toggleModeAction, toKey: .toggle)
        Actions.associateView(precisionModeAction, toKey: .precision)
        Actions.associateView(fullscreenModeAction, toKey: .fullscreen)
    }

    private func loadAllFromStore() {
        let helium = helium!
        setScale(helium.scale)
        lineColor.color = helium.lineColor
        lineWidth.stringValue = round2(helium.lineWidth)
        cornerLength.stringValue = round2(helium.cornerLength)
        aspectRatioWidth.stringValue = round2(helium.aspectRatio.width)
        aspectRatioHeight.stringValue = round2(helium.aspectRatio.height)
        moveOnEdgeTouch.state = helium.moveOnEdgeTouch ? .on : .off
    }

    override func awakeFromNib() {}
    private func round2(_ x: Double) -> String { String(format: "%0.2f", x) }
    private func preview() { helium?.reloadSettings() }
    private func setScale(_ s: Double) {
        scaleValue.stringValue = round2(s * 100)
        scaleSlider.doubleValue = s
        helium?.scale = s
    }

    func hydrate(helium: Helium) {
        self.helium = helium
        if !helium.setupExists {
            helium.initializeDefaults()
        }
        loadAllFromStore()
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
        helium?.lineColor = sender.color
        preview()
    }

    @IBAction func lineWidthDidChange(_ sender: NSTextField) {
        helium?.lineWidth = sender.doubleValue
        preview()
    }

    @IBAction func aspectRatioWidthDidChange(_ sender: NSTextField) {
        helium?.aspectRatio.width = sender.doubleValue
        preview()
    }

    @IBAction func aspectRatioHeightDidChange(_ sender: NSTextField) {
        helium?.aspectRatio.height = sender.doubleValue
        preview()
    }

    @IBAction func cornerLengthDidChange(_ sender: NSTextField) {
        helium?.cornerLength = sender.doubleValue
        preview()
    }

    @IBAction func moveOnEdgeTouchDidChange(_ sender: NSButton) {
        helium?.moveOnEdgeTouch = sender.state == .on
        preview()
    }

    @IBAction func resetDidRequest(_ sender: NSButton) {
        reset.toggle()
        sender.title = reset.get()
        if reset.on {
            sender.bezelColor = .red
            return
        }
        sender.bezelColor = nil
        helium?.initializeDefaults()
        loadAllFromStore()
        [toggleModeAction, precisionModeAction, fullscreenModeAction].forEach { v in
            UserDefaults.standard.removeObject(forKey: v?.associatedUserDefaultsKey ?? "")
        }
        helium?.refresh()
    }
}
