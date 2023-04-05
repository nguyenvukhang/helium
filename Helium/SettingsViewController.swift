//
//  ViewController.swift
//  Helium
//
//  Created by khang on 5/4/23.
//

import Cocoa

class SettingsViewController: NSViewController {
    @IBOutlet weak var scaleValue: NSTextField!
    @IBOutlet weak var scaleSlider: NSSliderCell!
    private let store = UserDefaults.standard
    
    private let SCALE_KEY = "scale"
    private let ASPECT_RATIO_KEY = "aspect-ratio"
    private let COLOR_KEY = "color"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setScale(store.double(forKey: SCALE_KEY))
    }
    
    override func awakeFromNib() {
        
    }
    
    private func setScale(_ s: CGFloat) {
        scaleValue.stringValue = String(format: "%0.2f", s)
        scaleSlider.doubleValue = s
        store.setValue(s, forKey: SCALE_KEY)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func pressed(_ sender: Any) {
        NSLog("GOTTEM HAHAHAHA")
    }
    
    @IBAction func scaleSliderDidChange(_ sender: NSSlider) {
        setScale(sender.doubleValue)
    }
    
    @IBAction func scaleTextDidChange(_ sender: NSTextFieldCell) {
        setScale(sender.doubleValue)
    }
}

