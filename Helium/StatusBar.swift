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

    private let TAG_TOGGLE_MODE = 1
    private let TAG_TOGGLE_BOUNDS = 2
    private let TAG_OPEN_PREFERENCES = 3
    private let TAG_QUIT = 4

    private let bar: NSStatusItem

    override init() {
        self.bar = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        let menu = NSMenu()
        menu.addItem(withTitle: "Helium", action: nil, keyEquivalent: "")
        menu.addItem(NSMenuItem.separator())
        menu.addItem(title: "Toggle", key: "t", tag: TAG_TOGGLE_MODE)
        menu.addItem(title: BOUNDS_SHOW_DESC, key: "b", tag: TAG_TOGGLE_BOUNDS)
        menu.addItem(title: "Preferences", key: ",", tag: TAG_OPEN_PREFERENCES)
        menu.addItem(title: "Quit", key: "q", tag: TAG_QUIT)
        bar.menu = menu
        super.init()
        updateMode(nil)
    }

    /**
     * Update state to match mode. Defaults to fullscreen.
     */
    func updateMode(_ mode: Mode?) {
        let mode = mode ?? .fullscreen
        switch mode {
        case .fullscreen:
            setButton(FULLSCREEN_ICON, FULLSCREEN_DESC)
        case .precision:
            setButton(PRECISION_ICON, PRECISION_DESC)
        }
    }

    /**
     * Update state (show/hide) for precision bounds.
     */
    func setPrecisionBounds(to: Bool) {
        let item = bar.menu?.item(withTag: TAG_TOGGLE_BOUNDS)
        item?.title = to ? BOUNDS_HIDE_DESC : BOUNDS_SHOW_DESC
    }

    /**
     * Link selectors to menubar buttons.
     */
    func linkActions(toggleMode: Selector, togglePrecisionBounds: Selector, openPrefs: Selector, quit: Selector) {
        let menu = bar.menu!
        menu.item(withTag: TAG_TOGGLE_MODE)?.action = toggleMode
        menu.item(withTag: TAG_TOGGLE_BOUNDS)?.action = togglePrecisionBounds
        menu.item(withTag: TAG_OPEN_PREFERENCES)?.action = openPrefs
        menu.item(withTag: TAG_QUIT)?.action = quit
    }

    /**
     * Convenience routine to update the state of a button
     */
    private func setButton(_ icon: String, _ desc: String) {
        bar.button?.image =
            NSImage(systemSymbolName: icon, accessibilityDescription: desc)
    }
}
