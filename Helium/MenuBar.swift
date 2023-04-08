//
//  MenuBar.swift
//  Helium
//
//  Created by khang on 5/4/23.
//

import Cocoa

class MenuBar {
    private let bar: NSStatusItem
    private let helium: Helium
    private var prefsWindowController: NSWindowController?

    private enum Tag: Int {
        case mode = 1
        case bounds = 2
        case prefs = 3
        case quit = 4
    }

    init(helium: Helium) {
        self.helium = helium
        self.bar = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        bar.menu = NSMenu()
        addItem(helium.mode.text, action: #selector(toggleMode), tag: .mode, key: "t")
        addItem(helium.showBounds.get(), action: #selector(toggleBounds), tag: .bounds, key: "b")
        addItem("Preferences", action: #selector(openPreferences), tag: .prefs, key: ",")
        addItem("Quit", action: #selector(quit), tag: .quit, key: "q")
        update()
    }

    /**
     * Update state to match mode. Defaults to fullscreen.
     */
    func update() {
        bar.button?.image = helium.mode.image
        item(.mode)?.title = helium.mode.text
        item(.bounds)?.title = helium.showBounds.get()
    }

    private func item(_ tag: Tag) -> NSMenuItem? { bar.menu?.item(withTag: tag.rawValue) }
    private func addItem(_ title: String, action: Selector?, tag: Tag, key: String) {
        let item = NSMenuItem(title: title, action: action, keyEquivalent: key)
        item.tag = tag.rawValue
        item.target = self
        bar.menu?.addItem(item)
    }

    /** Open the preferences window. */
    @objc func openPreferences() {
        if prefsWindowController == nil {
            prefsWindowController = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "PrefsWindowController") as? NSWindowController
            let svc = prefsWindowController?.contentViewController as? SettingsViewController
            svc?.hydrate(helium: helium)
        }
        NSApp.activate(ignoringOtherApps: true)
        prefsWindowController?.showWindow(self)
    }

    @objc func toggleBounds() { helium.showBounds.toggle(); update() }
    @objc func toggleMode() { helium.toggleMode(); update() }
    @objc func setPrecisionMode() { helium.setPrecisionMode(); update() }
    @objc func setFullScreenMode() { helium.setFullScreenMode(); update() }
    @objc func quit() { helium.reset(); exit(EXIT_SUCCESS) }
}
