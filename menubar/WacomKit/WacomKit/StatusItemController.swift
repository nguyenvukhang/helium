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
    
    private func changeStatusBarButton(number: Int) {
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "\(number).circle", accessibilityDescription: number.description)
        }
    }
    
    @objc func didTapOne() {
        NSLog("Tapped one!")
        changeStatusBarButton(number: 1)
    }
    
    init(statusItem: NSStatusItem) {
        self.statusItem = statusItem
        let menu = NSMenu()
        menu.autoenablesItems = true
        let one = NSMenuItem(title: "One", action: #selector(didTapOne), keyEquivalent: "1")
        one.target = self
        menu.addItem(one)
        
        
        self.statusItem.menu = menu
    }
    
    convenience init(title: String) {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        self.init(statusItem: item)
        statusItem.button?.title = title
    }
}
