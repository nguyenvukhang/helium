//
//  KeyboardShortcuts.swift
//  Helium
//
//  Created by khang on 7/4/23.
//

import MASShortcut

final class Shortcuts {
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
}
