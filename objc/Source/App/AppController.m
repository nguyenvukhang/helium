// /////////////////////////////////////////////////////////////////////////////
//
// DESCRIPTION
//		Logs mouse and tablet events.
//
//		Also demonstrates various mapping tricks which may be performed by sending
//		Apple Events to the Wacom driver. These features are available in the
//		application's Fun menu.
//
//		When an application wishes to customize driver settings, it must open a
//		"context" in the driver to contain its custom settings. That context is then
//		active whenever the application is frontmost.
//
// COPYRIGHT
//    Copyright (c) 2010 - 2023 Wacom Co., Ltd.
//    All rights reserved
//
// /////////////////////////////////////////////////////////////////////////////

#import "AppController.h"
#import "WacomTabletDriver.h"

@implementation AppController

@synthesize lastUsedTablet;

// /////////////////////////////////////////////////////////////////////////////
// Initialize this object.

- (id) init
{
    [NSEvent setMouseCoalescingEnabled:NO];
    NSLog(@"Begin execution!");
	self = [super init];
    
    self->mPrecisionOn = NO;
    self->barItem = [NSStatusBar.systemStatusBar statusItemWithLength:NSVariableStatusItemLength];
    [self->barItem.button setTitle:@"Wacom Kit"];
    [self->barItem setMenu:[[NSMenu alloc] init]];
    
    if (@available(macOS 11.0, *)) {
        [self->barItem.button setImage:[NSImage imageWithSystemSymbolName:@"circle" accessibilityDescription:@"focus mode"]];
    }
    
    NSMenuItem *it = [[NSMenuItem alloc] init];
    [it setTitle:@"Toggle"];
    [it setKeyEquivalent:@"t"];
    [it setAction:@selector(toggle)];
    [it setTarget:self];
    
    [self->barItem.menu addItem:it];
    
    NSMenuItem *it2 = [[NSMenuItem alloc] init];
    [it2 setTitle:@"Quit"];
    [it2 setKeyEquivalent:@"q"];
    [it2 setAction:@selector(quit)];
    [it2 setTarget:self];
    
    [self->barItem.menu addItem:it2];
    
    [NSEvent addGlobalMonitorForEventsMatchingMask: NSEventMaskTabletProximity handler:^(NSEvent * event) {
        [self setLastUsedTablet:[event systemTabletID]];
        NSLog(@"Proximity -> %d", (int)[self lastUsedTablet]);
    }];
    
    [NSEvent addGlobalMonitorForEventsMatchingMask: NSEventMaskKeyDown handler:^(NSEvent * event) {
        NSLog(@"Keypress!");
        BOOL cmd = [event modifierFlags] & NSEventModifierFlagCommand ? YES : NO;
        BOOL shift = [event modifierFlags] & NSEventModifierFlagShift ? YES : NO;
        NSLog(cmd ? @"cmd yes" : @"cmd no");
        NSLog(shift ? @"shift yes" :  @"shift no");
        if (!(cmd && shift)) {
            NSLog(@"\\Cmd or \\Shift");
            return;
        };
        if ([event keyCode] != 0x13) {
            NSLog(@"keycode not 2");
            return;
        };
        NSLog(@"Cmd + Shift + 2");
        [self toggle];
    }];
    
    
	lastUsedTablet    = 0;
	mContextID        = 0; // 0 is an invalid context number.
	mTabletOfContext  = 0;
	
	return self;
}

// get a scaled version of the screen's width, at a given aspect ratio.
- (NSRect) getScaled:(float)scale aspectRatio:(float)ar {
    NSRect screen = [NSScreen screens][0].frame;
    NSRect scaled = NSZeroRect;
    scaled.origin.x = 0;
    scaled.origin.y = 0;
    scaled.size.width = screen.size.width * scale;
    scaled.size.height = scaled.size.width / ar;
    return scaled;
}

// Tries to center the focus area at the cursor. Moves it minimally in order to fit in the screen.
- (void) setSmart {
    CGPoint cursor = [NSEvent mouseLocation];
    NSRect screen = [NSScreen screens][0].frame;
    NSRect rect = [self getScaled:0.56 aspectRatio:1.6];
    
    // center rect at cursor
    rect.origin = cursor;
    rect.origin.x -= rect.size.width / 2;
    rect.origin.y -= rect.size.height / 2;
    
    // move minimally
    
    if (NSMinX(rect) < 0) {
        rect.origin.x -= NSMinX(rect);
    } else if (NSMaxX(rect) > NSMaxX(screen)) {
        rect.origin.x -= NSMaxX(rect) - NSMaxX(screen);
    }
    if (NSMinY(rect) < 0) {
        rect.origin.y -= NSMinY(rect);
    } else if (NSMaxY(rect) > NSMaxY(screen)) {
        rect.origin.y -= NSMaxY(rect) - NSMaxY(screen);
    }
    
    [self setPortionOfScreen:rect];
}

- (void) toggle {
    [self makeContextForCurrentTablet];
    if (self->mPrecisionOn) {
        NSLog(@"toggle -> smart");
        if (@available(macOS 11.0, *)) {
            [self->barItem.button setImage:[NSImage imageWithSystemSymbolName:@"circle" accessibilityDescription:@"focus mode"]];
        }
        [self setSmart];
    } else {
        NSLog(@"toggle -> full screen");
        if (@available(macOS 11.0, *)) {
            [self->barItem.button setImage:[NSImage imageWithSystemSymbolName:@"square" accessibilityDescription:@"full screen"]];
        }
        [self setPortionOfScreen:[self getScaled:1 aspectRatio:1.6]];
    }
    self->mPrecisionOn = !self->mPrecisionOn;
}

- (void) quit {
    NSLog(@"End of execution!");
    [[NSApplication sharedApplication] terminate:nil];
}

#pragma mark - ACTIONS -

#pragma mark - DELEGATES -

// /////////////////////////////////////////////////////////////////////////////
// Contexts should be destroyed, otherwise they will live on in the
//	driver unnecessarily.

- (void) applicationWillTerminate:(NSNotification *)notification_I
{
	if (mContextID != 0)
	{
		[WacomTabletDriver destroyContext:mContextID];
	}
}

#pragma mark - UTILITIES -

// /////////////////////////////////////////////////////////////////////////////
// Returns the union of all screen rectangles.

- (NSRect) desktopRect
{
	NSRect         desktop           = NSZeroRect;
	NSEnumerator   *screenIterator   = [[NSScreen screens] objectEnumerator];
	NSScreen       *screen           = NULL;
	
	// Make the menu window (and the menu control!) cover the entire desktop.
	// This allows us to track clicks "outside" the menu.
	while ((screen = [screenIterator nextObject]))
	{
		desktop = NSUnionRect(desktop, [screen frame]);
	}
	
	return desktop;
}

// /////////////////////////////////////////////////////////////////////////////
// Updates the Wacom driver context to be associated with the
//	current tablet, discarding the old context if necessary.

- (void) makeContextForCurrentTablet
{
    if (mContextID != 0) {
        [WacomTabletDriver destroyContext:mContextID];
        mContextID = 0;
    }
	
	// If no context, create one.
	if (mContextID == 0)
	{
		mContextID        = [WacomTabletDriver createContextForTablet:(UInt32)lastUsedTablet type:pContextTypeDefault];
		mTabletOfContext  = (UInt32)lastUsedTablet;
	}
}

// /////////////////////////////////////////////////////////////////////////////
// Returns the display name of the pen with the given serial number.
// This method will ONLY return an answer when the pen was the last
//	used transducer of its type. Consequently, you should ONLY call
//	this method immediately after receiving a proximity event.

- (NSString *) nameOfPen:(NSUInteger)serialNumber_I
{
	UInt32                  transducerCount   = [WacomTabletDriver transducerCountForTablet:(UInt32)lastUsedTablet];
	NSAppleEventDescriptor  *routingTable     = nil;
	NSAppleEventDescriptor	*nameDesc			= nil;
	NSAppleEventDescriptor	*serialNumberDesc	= nil;
	UInt32                  counter           = 0;
	NSString						*name					= nil;
	
	// Search the transducers for the matching serial number.
	for (counter = 1; counter <= transducerCount && name == nil; ++counter)
	{
		// Retrieve pen info. 
		// Note:	Transducer data is not available through a context. We access the 
		//			data directly from the tablet. 
		routingTable      = [WacomTabletDriver routingTableForTablet:(UInt32)lastUsedTablet transducer:counter];
		nameDesc          = [WacomTabletDriver dataForAttribute:pName ofType:typeUTF8Text routingTable:routingTable];
		serialNumberDesc  = [WacomTabletDriver dataForAttribute:pSerialNumber ofType:typeUInt32 routingTable:routingTable];
		
		if ((UInt32)[serialNumberDesc int32Value] == serialNumber_I)
		{
			name = [nameDesc stringValue];
		}
	}
	
	return name;
}

// /////////////////////////////////////////////////////////////////////////////
// Sets the portion of the desktop the current tablet context maps to.

- (void) setPortionOfScreen:(NSRect)screenPortion_I
{
	if (mContextID != 0)
	{
		NSRect rectPrimary = [NSScreen screens][0].frame;
		NSAppleEventDescriptor  *routingDesc   = [WacomTabletDriver routingTableForContext:mContextID];
		Rect                    screenArea     = {0};
		
		// Convert Cocoa rect to old QuickDraw rect.
		screenArea.left   = NSMinX(screenPortion_I);
		screenArea.top    = NSMaxY(rectPrimary) - NSMaxY(screenPortion_I) + 1;
		screenArea.right  = NSMaxX(screenPortion_I);
		screenArea.bottom = NSMaxY(rectPrimary) - NSMinY(screenPortion_I) + 1;
		
        NSLog(@"tell the driver!");
		[WacomTabletDriver setBytes:&screenArea
									ofSize:sizeof(Rect)
									ofType:typeQDRectangle
							forAttribute:pContextMapScreenArea
							routingTable:routingDesc];
	}
}

@end
