//
//  StatusItemController.swift
//  WacomKit
//
//  Created by khang on 26/2/23.
//

import Cocoa

struct Rect {
    var top, left, bottom, right: Int16
}

enum KeyCode: UInt16 {
    case zero = 0x1D
    case one = 0x12
    case two = 0x13
    case three = 0x14
    case four = 0x15
    case five = 0x17
    case six = 0x16
    case seven = 0x1A
    case eight = 0x1C
    case nine = 0x19
}


class StatusItemController {
    let statusItem: NSStatusItem
    private var mContextId: UInt32 = 0
    private var mTabletOfContext: UInt32 = 0
    private var lastUsedTablet: UInt32 = 0
    private var isFullScreen = false

    @objc func makeContextForCurrentTablet() {
        if self.mContextId != 0 {
            WacomTabletDriver.destroyContext(self.mContextId)
            self.mContextId = 0
        }

        if self.mContextId == 0 {
            NSLog("Creating context for %d", self.lastUsedTablet)
            self.mContextId = WacomTabletDriver.createContext(forTablet: self.lastUsedTablet, type: pContextTypeDefault)
            NSLog("=> %d", self.mContextId)
            self.mTabletOfContext = self.lastUsedTablet
        }
    }

    var title: String {
        get {
            self.statusItem.button?.title ?? ""
        }
        set {
            self.statusItem.button?.title = newValue
        }
    }

    private func MaxY(_ r: NSRect) -> Int16 {
        Int16(NSMaxY(r))
    }

    private func MinY(_ r: NSRect) -> Int16 {
        Int16(NSMinY(r))
    }

    private func MaxX(_ r: NSRect) -> Int16 {
        Int16(NSMaxX(r))
    }

    private func MinX(_ r: NSRect) -> Int16 {
        Int16(NSMinX(r))
    }

    private func setPortionOfScreen(_ portion: NSRect) {
        self.makeContextForCurrentTablet()
        NSLog("setting with context -> %d", mContextId)
        let screen = NSScreen.screens[0].frame
        let routingDesc = WacomTabletDriver.routingTable(forContext: self.mContextId)
        var r = Rect(top: MaxY(screen) - MaxY(portion) + 1, left: MinX(portion), bottom: MaxY(screen) - MinY(portion) + 1, right: MaxX(portion))
        WacomTabletDriver.setBytes(&r, ofSize: UInt32(MemoryLayout.size(ofValue: r)), ofType: typeQDRectangle, forAttribute: pDank.rawValue, routingTable: routingDesc)
    }
    
    // Tries to center the focus area at the cursor. Moves it minimally in order to fit in the screen.
    private func setSmart() {
        let ptr: CGPoint = NSEvent.mouseLocation
        let screen = NSScreen.screens[0].frame
        var rect = getScaledScreen(scale: 0.56)
        
        // center rect at ptr
        rect.origin = ptr
        rect.origin.x -= rect.width / 2
        rect.origin.y -= rect.height / 2
        
        if (NSMinX(rect) < 0) {
            rect.origin.x -= NSMinX(rect)
        } else if (NSMaxX(rect) > screen.maxX) {
            rect.origin.x -= NSMaxX(rect) - screen.maxX
        }
        
        if (NSMinY(rect) < 0) {
            rect.origin.y -= NSMinY(rect)
        } else if (NSMaxY(rect) > screen.maxY) {
            rect.origin.y -= NSMaxY(rect) - screen.maxY
        }
        
        setPortionOfScreen(rect)
    }
    
    
    private func getScaledScreen(scale: CGFloat, aspectRatio: CGFloat = 1.6) -> NSRect {
        let s = NSScreen.screens[0].frame
        return NSRect(x: 0, y: 0, width: s.width * scale, height: s.width * scale / aspectRatio)
    }
    
    // Ratio is width / height. Wacom Intuous has a ratio of 16:10
    private func setMaxWithRatio(ratio: CGFloat) {
        let screen = NSScreen.screens[0].frame
        let width = screen.width
        let height = width / ratio
        let originY = max((screen.height - height) / 2, 0.0)
        let rect = NSRect(x: 0, y: originY, width: width, height: height)
        setPortionOfScreen(rect)
    }
    
    @objc func didTapToggle() {
        NSLog("Tapped Toggle!")
        self.toggle()
    }
    
    private func addItem(title: String, action: Selector?, keyEquivalent: String) {
        let item = NSMenuItem(title: title, action: action, keyEquivalent: keyEquivalent)
        item.target = self
        self.statusItem.menu?.addItem(item)
    }
    
    private func toggle() {
        if (isFullScreen) {
            self.setSmart()
            statusItem.button?.image = NSImage(systemSymbolName: "circle", accessibilityDescription: "Focus")
        } else {
            self.setMaxWithRatio(ratio: 1.6)
            statusItem.button?.image = NSImage(systemSymbolName: "square", accessibilityDescription: "Full Screen")
        }
        isFullScreen = !isFullScreen
    }
    
    private func keyDown(_ event: NSEvent) {
        print(event)
        let flags = event.modifierFlags
        print("has command", flags.contains(.command), " has shift", flags.contains(.shift))
        if !(flags.contains(.command) && flags.contains(.shift)) {
            NSLog("No command or shift. need both. ")
            return
        }
        if event.keyCode != KeyCode.two.rawValue {
            NSLog("Not 2")
            return
        }
        toggle()
        
    }

    init(statusItem: NSStatusItem) {
        self.statusItem = statusItem
        self.statusItem.menu = NSMenu()
        self.statusItem.menu?.autoenablesItems = true
        self.addItem(title: "Toggle", action: #selector(self.didTapToggle), keyEquivalent: "t")
        self.addItem(title: "Quit", action: #selector(self.quit), keyEquivalent: "q")

        NSEvent.addGlobalMonitorForEvents(matching: .tabletProximity, handler: { event in
            self.lastUsedTablet = UInt32(event.systemTabletID)
            NSLog("Proximity => %d!", self.lastUsedTablet)
        })
        
        NSEvent.addGlobalMonitorForEvents(matching: .keyDown, handler: { self.keyDown($0) })
    }

    convenience init(title: String) {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        self.init(statusItem: item)
        self.statusItem.button?.title = title
    }
    
    func close() {
        if self.mContextId != 0 {
            NSLog("destroy context!")
            WacomTabletDriver.destroyContext(self.mContextId)
        }
    }
    
    @objc private func quit() {
        self.close()
        exit(0)
    }
}
