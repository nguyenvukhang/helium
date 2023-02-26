//
//  AppDelegate.m
//  Wacom Kit
//
//  Created by khang on 27/2/23.
//

#import "AppDelegate.h"
#import "WacomTabletDriver.h"

@implementation AppDelegate

// /////////////////////////////////////////////////////////////////////////////
// Initialize this object.

- (void)setButton:(NSString *)icon description:(NSString *)description {
  if (@available(macOS 11.0, *)) {
    [self->barItem.button
        setImage:[NSImage imageWithSystemSymbolName:icon
                           accessibilityDescription:description]];
  }
}

- (void)addMenuItem:(NSString *)title
      keyEquivalent:(NSString *)key
             action:(SEL _Nullable)action {
  NSMenuItem *it = [[NSMenuItem alloc] init];
  [it setTitle:title];
  [it setKeyEquivalent:key];
  [it setAction:action];
  [it setTarget:self];
  [self->barItem.menu addItem:it];
}

- (id)init {
  [NSEvent setMouseCoalescingEnabled:NO];
  NSLog(@"Begin execution!");
  self = [super init];

  self->mPrecisionOn = NO;
  self->barItem = [NSStatusBar.systemStatusBar
      statusItemWithLength:NSVariableStatusItemLength];

  [self->barItem.button setTitle:@"Wacom Kit"];
  [self->barItem setMenu:[[NSMenu alloc] init]];

  [self setButton:@"square" description:@"full screen"];

  [self addMenuItem:@"Toggle" keyEquivalent:@"t" action:@selector(toggle)];
  [self addMenuItem:@"Quit" keyEquivalent:@"q" action:@selector(quit)];

  [NSEvent addGlobalMonitorForEventsMatchingMask:NSEventMaskTabletProximity
                                         handler:^(NSEvent *event) {
                                           self->lastUsedTablet =
                                               [event systemTabletID];
                                         }];

  [NSEvent addGlobalMonitorForEventsMatchingMask:NSEventMaskKeyDown
                                         handler:^(NSEvent *e) {
                                           [self handleKeyDown:e];
                                         }];

  lastUsedTablet = 0;
  mContextID = 0; // 0 is an invalid context number.

  return self;
}

/**
 * Trigger a toggle on Cmd + Shift + 2
 */
- (void)handleKeyDown:(NSEvent *)event {
  BOOL cmd = [event modifierFlags] & NSEventModifierFlagCommand;
  BOOL shift = [event modifierFlags] & NSEventModifierFlagShift;
  // 0x13 is '2'
  if (!(cmd && shift) || [event keyCode] != 0x13)
    return;
  [self toggle];
}

// get a scaled version of the screen's width, at a given aspect ratio.
- (NSRect)getScaled:(float)scale aspectRatio:(float)aspectRatio {
  NSRect screen = [NSScreen screens][0].frame;
  NSRect scaled = NSZeroRect;
  scaled.origin.x = 0;
  scaled.origin.y = 0;
  scaled.size.width = screen.size.width * scale;
  scaled.size.height = scaled.size.width / aspectRatio;
  return scaled;
}

- (NSRect)center:(NSRect)parent child:(NSRect)child {
  child.origin.x = (parent.size.width / 2) - (child.size.width / 2);
  child.origin.y = (parent.size.height / 2) - (child.size.height / 2);
  return child;
}

// Tries to center the precision area at the cursor. Moves it minimally in order
// to fit in the screen.
- (void)setSmart {
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

/**
 * Toggle between full-screen coverage and precision mode
 */
- (void)toggle {
  [self makeContextForCurrentTablet];

  if (self->mPrecisionOn) {
    NSRect full = [self getScaled:1 aspectRatio:1.6];
    full = [self center:([NSScreen screens][0].frame) child:full];
    [self setPortionOfScreen:full];
    [self setButton:@"square" description:@"full screen"];
  } else {
    [self setSmart];
    [self setButton:@"circle" description:@"precision mode"];
  }

  self->mPrecisionOn = !self->mPrecisionOn;
}

- (void)quit {
  NSLog(@"End of execution!");
  [[NSApplication sharedApplication] terminate:nil];
}

// /////////////////////////////////////////////////////////////////////////////
// Contexts should be destroyed, otherwise they will live on in the
//    driver unnecessarily.

- (void)applicationWillTerminate:(NSNotification *)notification_I {
  if (mContextID != 0) {
    [WacomTabletDriver destroyContext:mContextID];
  }
}

// /////////////////////////////////////////////////////////////////////////////
// Updates the Wacom driver context to be associated with the
//    current tablet, discarding the old context if necessary.

- (void)makeContextForCurrentTablet {
  if (mContextID != 0) {
    [WacomTabletDriver destroyContext:mContextID];
    mContextID = 0;
  }

  // If no context, create one.
  if (mContextID == 0) {
    mContextID =
        [WacomTabletDriver createContextForTablet:(UInt32)lastUsedTablet
                                             type:pContextTypeDefault];
  }
}

// /////////////////////////////////////////////////////////////////////////////
// Sets the portion of the desktop the current tablet context maps to.

- (void)setPortionOfScreen:(NSRect)screenPortion_I {
  if (mContextID != 0) {
    NSRect rectPrimary = [NSScreen screens][0].frame;
    NSAppleEventDescriptor *routingDesc =
        [WacomTabletDriver routingTableForContext:mContextID];
    Rect screenArea = {0};

    // Convert Cocoa rect to old QuickDraw rect.
    screenArea.left = NSMinX(screenPortion_I);
    screenArea.top = NSMaxY(rectPrimary) - NSMaxY(screenPortion_I) + 1;
    screenArea.right = NSMaxX(screenPortion_I);
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
