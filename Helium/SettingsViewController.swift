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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func awakeFromNib() {
        
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
        scaleValue.stringValue = String(format: "%0.2f", sender.doubleValue)
    }
    
    @IBAction func scaleTextDidChange(_ sender: NSTextFieldCell) {
        scaleSlider.doubleValue = sender.doubleValue
    }
}

