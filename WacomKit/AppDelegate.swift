//
//  AppDelegate.swift
//  WacomKit
//
//  Created by khang on 26/2/23.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    let statusItemController = StatusItemController(title: "Wacom Kit")

    func applicationDidFinishLaunching(_ aNotification: Notification) {}

    func applicationWillTerminate(_ aNotification: Notification) {
        self.statusItemController.close()
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        true
    }
}
