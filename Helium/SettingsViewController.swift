//
//  SettingsViewController.swift
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
    @IBOutlet var lineColor: NSColorWell!
    @IBOutlet var lineWidth: NSTextField!
    @IBOutlet var cornerLength: NSTextField!
    @IBOutlet var aspectRatioWidth: NSTextField!
    @IBOutlet var aspectRatioHeight: NSTextField!
    @IBOutlet var scaleSlider: NSSlider!
    @IBOutlet var scaleValue: NSTextField!
    @IBOutlet var moveOnEdgeTouch: NSButton!
    @IBOutlet var precisionModeAction: MASShortcutView!
    @IBOutlet var fullscreenModeAction: MASShortcutView!
    @IBOutlet var toggleModeAction: MASShortcutView!
    @IBOutlet var resetAll: NSButton!

    private var helium: Helium?
    private var updateBar: (() -> Void)?
    private var reset = Pair(on: "Confirm Restore", off: "Restore Defaults", false)

    override func viewDidLoad() {
        super.viewDidLoad()

        // so that the color picker will have alpha
        NSColor.ignoresAlpha = false
        resetAll.title = reset.get()

        Shortcuts.associateView(toggleModeAction, to: .toggleMode)
        Shortcuts.associateView(precisionModeAction, to: .setPrecision)
        Shortcuts.associateView(fullscreenModeAction, to: .setFullscreen)
    }

    override func awakeFromNib() {}
    private func round2(_ x: Double) -> String { String(format: "%0.2f", x) }

    private func preview() {
        helium?.previewOverlay()
        updateBar?()
    }

    private func setScale(_ s: Double) {
        scaleValue.stringValue = round2(s * 100)
        scaleSlider.doubleValue = s
        helium?.scale = s
    }

    private func loadAllSettings() {
        guard let helium = helium else { return }
        setScale(helium.scale)
        lineColor.color = helium.lineColor
        lineWidth.stringValue = round2(helium.lineWidth)
        cornerLength.stringValue = round2(helium.cornerLength)
        aspectRatioWidth.stringValue = String(helium.aspectRatioWidth)
        aspectRatioHeight.stringValue = String(helium.aspectRatioHeight)
        moveOnEdgeTouch.state = helium.moveOnEdgeTouch ? .on : .off
    }

    func hydrate(helium: Helium, updateBar: @escaping () -> Void) {
        self.helium = helium
        self.updateBar = updateBar
        loadAllSettings()
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
        helium?.aspectRatioWidth = sender.integerValue
        preview()
    }

    @IBAction func aspectRatioHeightDidChange(_ sender: NSTextField) {
        helium?.aspectRatioHeight = sender.integerValue
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
        loadAllSettings()
        for v in [toggleModeAction, precisionModeAction, fullscreenModeAction] {
            UserDefaults.standard.removeObject(forKey: v?.associatedUserDefaultsKey ?? "")
        }
        helium?.refresh()
    }
}
