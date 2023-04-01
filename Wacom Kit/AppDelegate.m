//
//  AppDelegate.m
//  Wacom Kit
//
//  Created by khang on 27/2/23.
//

#import "AppDelegate.h"

#import "WacomTabletDriver.h"

@implementation AppDelegate

const double SCALE = 0.48;

// /////////////////////////////////////////////////////////////////////////////
// Initialize this object.

- (id)init {
  self = [super init];

  // initialize menu bar
  self->bar = [[WKStatusItem alloc] initWithParent:self];
  [self->bar addMenuItem:@"Toggle" keyEquivalent:@"t" action:@selector(toggle)];
  [self->bar addMenuItem:@"Quit" keyEquivalent:@"q" action:@selector(quit)];

  // track tablet proximity sensor to grab latest tablet used
  // track keystrokes to listen for toggle key combination
  [self track:NSEventMaskTabletProximity | NSEventMaskKeyDown
      handler:^(NSEvent *event) {
          if ([event type] == NSEventTypeTabletProximity && event.isEnteringProximity) {

            self->lastUsedTablet = [event systemTabletID];
            /* [self log:[NSString stringWithFormat:@"NSEventMaskTabletProximity -> %lu",
             * self->lastUsedTablet]]; */

          } else if (event.type == NSEventTypeKeyDown) {
            [self handleKeyDown:event];
          }
      }];

  // track frontmost application to refresh context when it changes
  [NSWorkspace.sharedWorkspace addObserver:self
                                forKeyPath:@"frontmostApplication"
                                   options:0
                                   context:nil];
  lastUsedTablet = 0;
  mContextID = 0; // 0 is an invalid context number.
  mPrecisionOn = NO;

  return self;
}

// Called everytime the frontmost application changes
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
  [self destroyContext];
  [self setMode:self->cursorAtToggle];
}

/// Trigger a toggle on Cmd + Shift + 2
- (void)handleKeyDown:(NSEvent *)event {
  BOOL cmd = [event modifierFlags] & NSEventModifierFlagCommand;
  BOOL shift = [event modifierFlags] & NSEventModifierFlagShift;
  // 0x13 is '2'
  if (!(cmd && shift) || [event keyCode] != 0x13)
    return;
  NSLog(@"Key down toggle!");
  [self toggle];
}

/// get a scaled version of the screen's width, at a given aspect ratio.
- (NSRect)getScaled:(float)scale aspectRatio:(float)aspectRatio {
  NSRect screen = [NSScreen screens][0].frame;
  NSRect scaled = NSZeroRect;
  scaled.origin.x = 0;
  scaled.origin.y = 0;
  scaled.size.width = screen.size.width * scale;
  scaled.size.height = scaled.size.width / aspectRatio;
  return scaled;
}

/// center the child with respect to the parent
- (NSRect)center:(NSRect)parent child:(NSRect)child {
  child.origin.x = (parent.size.width / 2) - (child.size.width / 2);
  child.origin.y = (parent.size.height / 2) - (child.size.height / 2);
  return child;
}

/// Tries to center the precision area at the cursor. Moves it minimally in order
/// to fit in the screen.
- (void)setSmart:(NSPoint)cursor {
  NSRect screen = [NSScreen screens][0].frame;
  NSRect rect = [self getScaled:SCALE aspectRatio:1.6];

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
  self->cursorAtToggle = cursor;
}

/**
 * Toggle between full-screen coverage and precision mode
 */
- (void)toggle {
  self->mPrecisionOn = !self->mPrecisionOn;
  [self setMode:[NSEvent mouseLocation]];
}

- (void)setMode:(NSPoint)cursor {
  if (self->mPrecisionOn) {
    [self setSmart:cursor];
    [self->bar setOn];
  } else {
    NSRect full = [self getScaled:1 aspectRatio:1.6];
    full = [self center:([NSScreen screens][0].frame) child:full];
    [self setPortionOfScreen:full];
    [self->bar setOff];
  }
}

- (void)quit {
  NSLog(@"End of execution!");
  [WacomTabletDriver destroyContext:mContextID];
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

- (void)destroyContext {
  [self log:@"try to destroy context..."];
  if (mContextID != 0) {
    [self log:[NSString stringWithFormat:@"DESTROY: %d", mContextID]];
    [WacomTabletDriver destroyContext:mContextID];
    mContextID = 0;
    [self log:@"context destroyed!"];
  } else {

    [self log:@"context already zero"];
  }
}

- (void)makeContext {
  [self log:@"try to make new context..."];

  // If no context, create one.
  if (mContextID == 0) {
    mContextID = [WacomTabletDriver createContextForTablet:(UInt32)lastUsedTablet
                                                      type:pContextTypeDefault];

    [self log:[NSString stringWithFormat:@"NEW_CONTEXT: %d", mContextID]];
    [self log:@"made new context!"];
  } else {
    [self log:@"context already exists"];
  }
}

// /////////////////////////////////////////////////////////////////////////////
// Sets the portion of the desktop the current tablet context maps to.

- (void)setPortionOfScreen:(NSRect)screenPortion_I {
  [self makeContext];
  if (mContextID != 0) {
    [self log:@"Setting portion of screen!"];
    NSRect rectPrimary = [NSScreen screens][0].frame;
    NSAppleEventDescriptor *routingDesc = [WacomTabletDriver routingTableForContext:mContextID];
    Rect screenArea = {0};

    // Convert Cocoa rect to old QuickDraw rect.
    screenArea.left = NSMinX(screenPortion_I);
    screenArea.top = NSMaxY(rectPrimary) - NSMaxY(screenPortion_I) + 1;
    screenArea.right = NSMaxX(screenPortion_I);
    screenArea.bottom = NSMaxY(rectPrimary) - NSMinY(screenPortion_I) + 1;

    [WacomTabletDriver setBytes:&screenArea
                         ofSize:sizeof(Rect)
                         ofType:typeQDRectangle
                   forAttribute:pContextMapScreenArea
                   routingTable:routingDesc];
  }
}

- (void)track:(NSEventMask)mask handler:(nonnull void (^)(NSEvent *_Nonnull))handler {
  [NSEvent addGlobalMonitorForEventsMatchingMask:mask handler:handler];
}

- (void)log:(NSString *)text {
  NSString *path = @"/Users/khang/.cache/wacom/log.txt";
  NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:path];
  /* [text writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:NULL]; */
  [fileHandle seekToEndOfFile];
  [fileHandle writeData:[text dataUsingEncoding:NSUTF8StringEncoding]];
  [fileHandle writeData:[@"\n" dataUsingEncoding:NSUTF8StringEncoding]];
  [fileHandle closeFile];
}

@end
