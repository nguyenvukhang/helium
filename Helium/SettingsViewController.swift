//
//  ViewController.swift
//  Helium
//
//  Created by khang on 5/4/23.
//

import Cocoa

class SettingsViewController: NSViewController {
    @IBOutlet weak var butt: NSButtonCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func awakeFromNib() {
        butt.title = "le button"
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func pressed(_ sender: Any) {
        NSLog("GOTTEM HAHAHAHA")
    }
    
}

