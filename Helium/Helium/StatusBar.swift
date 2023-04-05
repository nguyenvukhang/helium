//
//  StatusBar.swift
//  Helium
//
//  Created by khang on 5/4/23.
//

import Cocoa

extension NSMenu {
    func addItem(title: String, key: String, tag: Int) {
        let item = NSMenuItem(title: title, action: nil, keyEquivalent: key)
        item.tag = tag
        addItem(item)
    }
}

class StatusBar: NSObject {
    private let PRECISION_ICON = "plus.rectangle.fill"
    private let PRECISION_DESC = "Precision mode"
    private let FULLSCREEN_ICON = "plus.rectangle"
    private let FULLSCREEN_DESC = "Fullscreen mode"
    private let BOUNDS_HIDE_DESC = "Hide bounds"
    private let BOUNDS_SHOW_DESC = "Show bounds"

    private let TAG_TOGGLE_PRECISION = 1
    private let TAG_TOGGLE_BOUNDS = 2
    private let TAG_QUIT = 3

    private let bar: NSStatusItem

    override init() {
        self.bar = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        let menu = NSMenu()

        menu.addItem(withTitle: "Helium", action: nil, keyEquivalent: "")
        menu.addItem(NSMenuItem.separator())
        menu.addItem(title: "Toggle", key: "t", tag: TAG_TOGGLE_PRECISION)
        menu.addItem(title: "Hide precision bounds", key: "b", tag: TAG_TOGGLE_BOUNDS)
        menu.addItem(title: "Quit", key: "q", tag: TAG_QUIT)
        bar.menu = menu
        super.init()
        setFullscreenMode()
    }

    private func setButton(_ icon: String, _ desc: String) {
        bar.button?.image =
            NSImage(systemSymbolName: icon, accessibilityDescription: desc)
    }

    private func setPrecisionMode() {
        setButton(PRECISION_ICON, PRECISION_DESC)
    }

    private func setFullscreenMode() {
        setButton(FULLSCREEN_ICON, FULLSCREEN_DESC)
    }

    func linkActions(togglePrecision: Selector, togglePrecisionBounds: Selector, quit: Selector) {
        let menu = bar.menu!
        menu.item(withTag: TAG_TOGGLE_PRECISION)?.action = togglePrecision
        menu.item(withTag: TAG_TOGGLE_BOUNDS)?.action = togglePrecisionBounds
        menu.item(withTag: TAG_QUIT)?.action = quit
    }
}
