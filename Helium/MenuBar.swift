//
//  MenuBar.swift
//  Helium
//
//  Created by khang on 5/4/23.
//

import Cocoa

class MenuBar {
    private var mode: Mode
    private var pBounds = Pair(on: "Hide Bounds", off: "Show Bounds", state: .on)

    private enum Tag: Int {
        case mode = 1
        case bounds = 2
        case prefs = 3
        case quit = 4
    }

    private func item(title: String, key: String, tag: Tag) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: nil, keyEquivalent: key)
        item.tag = tag.rawValue
        return item
    }

    private let bar: NSStatusItem

    init(mode: Mode) {
        self.mode = mode
        self.bar = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        let menu = NSMenu()
        menu.addItem(withTitle: "Helium", action: nil, keyEquivalent: "")
        menu.addItem(NSMenuItem.separator())
        menu.addItem(item(title: mode.text(), key: "t", tag: .mode))
        menu.addItem(item(title: pBounds.get(), key: "b", tag: .bounds))
        menu.addItem(item(title: "Preferences", key: ",", tag: .prefs))
        menu.addItem(item(title: "Quit", key: "q", tag: .quit))
        bar.menu = menu

        updateMode(self.mode)
    }

    /**
     * Update state to match mode. Defaults to fullscreen.
     */
    func updateMode(_ mode: Mode) {
        self.mode = mode
        bar.button?.image = mode.image()
        item(.mode)?.title = mode.text()
    }

    /**
     * Update state (show/hide) for precision bounds.
     */
    func setPrecisionBounds(to: Bool) {
        pBounds.set(to)
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
}
