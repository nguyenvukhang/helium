//
//  KeyboardShortcuts.swift
//  Helium
//
//  Created by khang on 7/4/23.
//

import Cocoa
import MASShortcut

enum Action: Int {
    case toggleMode = 1
    case toggleBounds = 2
    case setFullscreen = 3
    case setPrecision = 4
    case openPreferences = 5
    case quit = 6

    var name: String {
        switch self {
        case .toggleMode: return "toggleMode"
        case .toggleBounds: return "toggleBounds"
        case .setFullscreen: return "setFullscreen"
        case .setPrecision: return "setPrecision"
        case .openPreferences: return "openPreferences"
        case .quit: return "quit"
        }
    }

    var displayName: String {
        switch self {
        case .toggleMode: return "Toggle Mode"
        case .toggleBounds: return "Toggle Bounds"
        case .setFullscreen: return "Use Fullscreen Mode"
        case .setPrecision: return "Use Precision Mode"
        case .openPreferences: return "Preferences…"
        case .quit: return "Quit Helium"
        }
    }
}

enum Shortcuts {
    enum Key: String {
        case toggle = "key-toggle"
        case precision = "key-precision"
        case fullscreen = "key-fullscreen"
    }

    static func bind(_ key: Key, to: @escaping () -> Void) {
        MASShortcutBinder.shared().bindShortcut(withDefaultsKey: key.rawValue, toAction: to)
    }

    static func associateView(_ view: MASShortcutView, toKey: Key) {
        view.associatedUserDefaultsKey = toKey.rawValue
    }

    static func getKeyEquivalent(_ key: Key) -> (String?, NSEvent.ModifierFlags)? {
        guard let m = MASShortcutBinder.shared()?.value(forKey: key.rawValue) as? MASShortcut else { return nil }
        return (m.keyCodeStringForKeyEquivalent, m.modifierFlags)
    }
}
