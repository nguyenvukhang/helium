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

    private var overlay: Overlay?
    private var helium: Helium?
    private var update: (() -> Void)?

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
        let store = helium!.store
        setScale(store.scale)
        lineColor.color = store.lineColor
        lineWidth.stringValue = round2(store.lineWidth)
        cornerLength.stringValue = round2(store.cornerLength)
        aspectRatioWidth.stringValue = round2(store.aspectRatio.width)
        aspectRatioHeight.stringValue = round2(store.aspectRatio.height)
        moveOnEdgeTouch.state = store.moveOnEdgeTouch ? .on : .off
    }

    override func awakeFromNib() {}

    private func round2(_ x: Double) -> String {
        String(format: "%0.2f", x)
    }

    private func setScale(_ s: Double) {
        scaleValue.stringValue = round2(s * 100)
        scaleSlider.doubleValue = s
        helium?.store.scale = s
    }

    func hydrate(overlay: Overlay, helium: Helium, update: @escaping () -> Void) {
        self.overlay = overlay
        self.helium = helium
        self.update = update
        if !helium.store.setupExists {
            helium.store.initializeDefaults()
        }
        loadAllFromStore()
    }

    private func preview() {
        var r = NSZeroRect
        let screen = NSRect.screen()
        r.fill(screen, withAspectRatio: helium!.store.getAspectRatio())
        r.scale(by: helium!.store.scale)
        r.center(within: screen)
        overlay?.move(to: r)
        overlay?.flash(force: true)
        update?()
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
        helium?.store.lineColor = sender.color
        preview()
    }

    @IBAction func lineWidthDidChange(_ sender: NSTextField) {
        helium?.store.lineWidth = sender.doubleValue
        preview()
    }

    @IBAction func aspectRatioWidthDidChange(_ sender: NSTextField) {
        helium?.store.aspectRatio.width = sender.doubleValue
        preview()
    }

    @IBAction func aspectRatioHeightDidChange(_ sender: NSTextField) {
        helium?.store.aspectRatio.height = sender.doubleValue
        preview()
    }

    @IBAction func cornerLengthDidChange(_ sender: NSTextField) {
        helium?.store.cornerLength = sender.doubleValue
        preview()
    }

    @IBAction func moveOnEdgeTouchDidChange(_ sender: NSButton) {
        helium?.store.moveOnEdgeTouch = sender.state == .on
        preview()
    }

    @IBAction func resetDidRequest(_ sender: NSButton) {
        if reset.on {
            sender.bezelColor = nil
            helium?.store.initializeDefaults()
            loadAllFromStore()
            let d = UserDefaults.standard
            [toggleModeAction, precisionModeAction, fullscreenModeAction].forEach { view in
                d.removeObject(forKey: view?.associatedUserDefaultsKey ?? "")
            }
        } else {
            sender.bezelColor = .red
        }
        reset.toggle()
        sender.title = reset.get()
    }
}
