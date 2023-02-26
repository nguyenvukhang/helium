//
//  StatusItemController.swift
//  WacomKit
//
//  Created by khang on 26/2/23.
//

import Cocoa

class StatusItemController {
    let statusItem: NSStatusItem
    
    var title: String {
        get {
            return statusItem.button?.title ?? ""
        }
        set {
            statusItem.button?.title = newValue
        }
    }
    
    init(statusItem: NSStatusItem) {
        self.statusItem = statusItem
    }
    
    convenience init(title: String) {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        self.init(statusItem: item)
        statusItem.button?.title = title
    }
}
