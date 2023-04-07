//
//  KeyboardShortcuts.swift
//  Helium
//
//  Created by khang on 7/4/23.
//

import Foundation
import MASShortcut

class Actions {
    enum Key: String {
        case toggle = "key-toggle"
        case precision = "key-precision"
        case fullscreen = "key-fullscreen"
    }

    private var aToggle: (() -> Void)?
    private var aPrecision: (() -> Void)?
    private var aFullscreen: (() -> Void)?

    private func action(_ key: Key) -> Ref<(() -> Void)?> {
        switch key {
        case .toggle: return Ref(aToggle)
        case .precision: return Ref(aPrecision)
        case .fullscreen: return Ref(aFullscreen)
        }
    }

    func link(key: Key, action: @escaping () -> Void) {
        let a = self.action(key)
        a.val = action
        MASShortcutBinder().bindShortcut(withDefaultsKey: key.rawValue, toAction: a.val)
    }

    func call(key: Key) {
        action(key).val?()
    }
}
