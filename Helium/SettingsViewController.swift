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
    private var store: Store?
    private var update: (() -> Void)?
    private var actions: Actions?

    private var reset = Pair(on: "Confirm Reset", off: "Reset All Preferences", state: .off)

    override func viewDidLoad() {
        super.viewDidLoad()

        // so that the color picker will have alpha
        NSColor.ignoresAlpha = false
    }

    private func loadAllFromStore() {
        let store = store!
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
        store?.scale = s
    }

    func hydrate(overlay: Overlay, store: Store, actions: Actions, update: @escaping () -> Void) {
        self.overlay = overlay
        self.store = store
        self.update = update
        self.actions = actions
        actions.associateView(toggleModeAction, toKey: .toggle)
        actions.associateView(precisionModeAction, toKey: .precision)
        actions.associateView(fullscreenModeAction, toKey: .fullscreen)
        if !store.setupExists {
            store.initializeDefaults()
        }
        loadAllFromStore()
    }

    private func preview() {
        var r = NSZeroRect
        let screen = NSRect.screen()
        r.fill(screen, withAspectRatio: store!.getAspectRatio())
        r.scale(by: store!.scale)
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
        store?.lineColor = sender.color
        preview()
    }

    @IBAction func lineWidthDidChange(_ sender: NSTextField) {
        store?.lineWidth = sender.doubleValue
        preview()
    }

    @IBAction func aspectRatioWidthDidChange(_ sender: NSTextField) {
        store?.aspectRatio.width = sender.doubleValue
        preview()
    }

    @IBAction func aspectRatioHeightDidChange(_ sender: NSTextField) {
        store?.aspectRatio.height = sender.doubleValue
        preview()
    }

    @IBAction func cornerLengthDidChange(_ sender: NSTextField) {
        store?.cornerLength = sender.doubleValue
        preview()
    }

    @IBAction func moveOnEdgeTouchDidChange(_ sender: NSButton) {
        store?.moveOnEdgeTouch = sender.state == .on
        preview()
    }

    @IBAction func resetDidRequest(_ sender: NSButton) {
        if reset.on {
            sender.bezelColor = nil
            store?.initializeDefaults()
            loadAllFromStore()
        } else {
            sender.bezelColor = .red
        }
        reset.toggle()
        sender.title = reset.get()
    }
}
