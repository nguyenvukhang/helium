//
//  MenuBar.swift
//  Helium
//
//  Created by khang on 5/4/23.
//

import Cocoa

class MenuBar {
    private let bar: NSStatusItem
    private let mode: Ref<Mode>
    private let pBounds: Pair<String>
    private enum Tag: Int {
        case mode = 1
        case bounds = 2
        case prefs = 3
        case quit = 4
    }

    init(mode: Ref<Mode>, pBounds: Pair<String>) {
        self.mode = mode
        self.pBounds = pBounds
        self.bar = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        let menu = NSMenu()
        menu.addItem(item(title: mode.val.text(), key: "t", tag: .mode))
        menu.addItem(item(title: pBounds.get(), key: "b", tag: .bounds))
        menu.addItem(item(title: "Preferences", key: ",", tag: .prefs))
        menu.addItem(item(title: "Quit Helium", key: "q", tag: .quit))
        bar.menu = menu

        update()
    }

    /**
     * Update state to match mode. Defaults to fullscreen.
     */
    func update() {
        bar.button?.image = mode.val.image()
        item(.mode)?.title = mode.val.text()
        item(.bounds)?.title = pBounds.get()
    }

    /**
     * Link selectors to menubar buttons.
     */
    func linkActions(toggleMode: Selector, togglePrecisionBounds: Selector, openPrefs: Selector, quit: Selector) {
        item(.mode)?.action = toggleMode
        item(.bounds)?.action = togglePrecisionBounds
        item(.prefs)?.action = openPrefs
        item(.quit)?.action = quit
    }

    /**
     * Get the tagged item from the menubar list
     */
    private func item(_ tag: Tag) -> NSMenuItem? {
        bar.menu?.item(withTag: tag.rawValue)
    }

    /**
     * Create a new NSMenuItem.
     */
    private func item(title: String, key: String, tag: Tag) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: nil, keyEquivalent: key)
        item.tag = tag.rawValue
        return item
    }
}
