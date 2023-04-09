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

    init(helium: Helium) {
        self.helium = helium
        self.bar = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        bar.menu = NSMenu()
        addItem(helium.mode.text, action: #selector(toggleMode), tag: .toggleMode, key: "")
        addItem(helium.showBounds.get(), action: #selector(toggleBounds), tag: .toggleBounds, key: "")
        addItem(Action.openPreferences.displayName, action: #selector(openPreferences), tag: .openPreferences, key: "")
        addItem(Action.quit.displayName, action: #selector(quit), tag: .quit, key: "q")

        bar.button?.image = helium.mode.image
        item(.toggleMode)?.title = helium.mode.text
        item(.toggleBounds)?.title = helium.showBounds.get()
    }

    /**
     * Update state to match mode. Defaults to fullscreen.
     */
    func update() {
        bar.button?.image = helium.mode.image
        item(.toggleMode)?.title = helium.mode.text
        NSLog("update bar!")
        item(.toggleBounds)?.title = helium.showBounds.get()
        if let x = Shortcuts.get(.toggleMode), let key = x.0 {
            item(.toggleMode)?.keyEquivalent = key
            item(.toggleMode)?.keyEquivalentModifierMask = x.1
        }
    }

    private func item(_ tag: Action) -> NSMenuItem? { bar.menu?.item(withTag: tag.rawValue) }
    private func addItem(_ title: String, action: Selector?, tag: Action, key: String) {
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
            svc?.hydrate(helium: helium, updateBar: update)
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
