//
//  AppDelegate.swift
//  WacomKit
//
//  Created by khang on 26/2/23.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    let statusItemController = StatusItemController(title: "Click Me")
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
}

