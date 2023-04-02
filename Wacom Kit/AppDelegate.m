//
//  AppDelegate.m
//  Wacom Kit
//
//  Created by khang on 27/2/23.
//

#import "AppDelegate.h"
#import "Rect.h"

#import "Wacom/WacomTabletDriver.h"

@implementation AppDelegate

const double SCALE = 0.48;
NSString *_Nonnull logfilePath = @"/Users/khang/.cache/wacom/log.txt";

- (id)init {
  self = [super init];
  [self startLog:@"--- start ---\n"];

  // initialize menu bar
  self->bar = [[WKStatusItem alloc] initWithParent:self];
  [self->bar addMenuItem:@"Toggle" keyEquivalent:@"t" action:@selector(toggle)];
  [self->bar addMenuItem:@"Quit" keyEquivalent:@"q" action:@selector(quit)];

  // track tablet proximity sensor to grab latest tablet used
  // track keystrokes to listen for toggle key combination
  [self track:NSEventMaskTabletProximity | NSEventMaskKeyDown
      handler:^(NSEvent *event) {
          if (event.type == NSEventTypeTabletProximity && event.isEnteringProximity) {
            self->lastUsedTablet = [event systemTabletID];
          } else if (event.type == NSEventTypeKeyDown) {
            [self handleKeyDown:event];
          }
      }];

  lastUsedTablet = 0;
  mContextID = 0; // 0 is an invalid context number.
  mPrecisionOn = NO;

  return self;
}

/**
 * Trigger a toggle on Cmd + Shift + F2
 */
- (void)handleKeyDown:(NSEvent *)event {
  BOOL cmd = [event modifierFlags] & NSEventModifierFlagCommand;
  BOOL shift = [event modifierFlags] & NSEventModifierFlagShift;
  // 0x78 is 'f2'
  if (!(cmd && shift) || [event keyCode] != 0x78)
    return;
  NSLog(@"Key down toggle!");
  [self toggle];
}

/**
 * Tries to center the precision area at the cursor. Moves it
 * minimally in order to fit in the screen.
 */
- (void)setSmart:(NSPoint)cursor {
  NSRect rect = [WRect scaled:SCALE aspectRatio:1.6];
  NSRect smart = [WRect smart:cursor rect:rect];
  [self setPortionOfScreen:smart];
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
    NSRect full = [WRect scaled:1 aspectRatio:1.6];
    full = [WRect center:([NSScreen screens][0].frame) child:full];
    [self setPortionOfScreen:full];
    [self->bar setOff];
  }
}

/**
 * Makes a new context. Does not override existing context.
 */
- (void)makeContext {
  [self log:@"[makeContext]"];
  [self log:mContextID == 0 ? @"made new context!" : @"context already exists"];
  if (mContextID != 0)
    return;

  mContextID = [WacomTabletDriver createContextForTablet:(UInt32)lastUsedTablet
                                                    type:pContextTypeDefault];
  [self log:[NSString stringWithFormat:@"NEW_CONTEXT: %d", mContextID]];
}

/**
 * Destroys existing context.
 */
- (void)destroyContext {
  [self log:@"[destroyContext]"];
  [self log:mContextID == 0 ? @"context already zero" : @"context destroyed!"];
  if (mContextID == 0)
    return;

  [WacomTabletDriver destroyContext:mContextID];
  [self log:[NSString stringWithFormat:@"DESTROY: %d", mContextID]];
  mContextID = 0;
}

- (void)resetContext {
  [self destroyContext];
  [self makeContext];
}

- (void)setPortionOfScreen:(NSRect)screenPortion_I {
  [self log:@"Setting portion of screen!"];
  NSRect rectPrimary = [NSScreen screens][0].frame;
  [self log:[NSString stringWithFormat:@"routing table for: %lu", lastUsedTablet]];

  bool useGlobal = false;
  NSAppleEventDescriptor *routingDesc;
  if (useGlobal) {
    routingDesc = [WacomTabletDriver routingTableForTablet:lastUsedTablet];
  } else {
    [self resetContext];
    routingDesc = [WacomTabletDriver routingTableForContext:mContextID];
  }

  Rect screenArea = {0};

  // Convert Cocoa rect to old QuickDraw rect.
  screenArea.left = NSMinX(screenPortion_I);
  screenArea.top = NSMaxY(rectPrimary) - NSMaxY(screenPortion_I) + 1;
  screenArea.right = NSMaxX(screenPortion_I);
  screenArea.bottom = NSMaxY(rectPrimary) - NSMinY(screenPortion_I) + 1;

  [WacomTabletDriver setBytes:&screenArea
                       ofSize:sizeof(Rect)
                       ofType:typeQDRectangle
                 forAttribute:pMapScreenArea
                 routingTable:routingDesc];
}

- (void)track:(NSEventMask)mask handler:(nonnull void (^)(NSEvent *_Nonnull))handler {
  [NSEvent addGlobalMonitorForEventsMatchingMask:mask handler:handler];
}

- (void)log:(NSString *)text {
  NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:logfilePath];
  [fileHandle seekToEndOfFile];
  [fileHandle writeData:[text dataUsingEncoding:NSUTF8StringEncoding]];
  [fileHandle writeData:[@"\n" dataUsingEncoding:NSUTF8StringEncoding]];
  [fileHandle closeFile];
}

- (void)startLog:(NSString *)text {
  [text writeToFile:logfilePath atomically:YES encoding:NSUTF8StringEncoding error:NULL];
}

- (void)quit {
  NSLog(@"End of execution!");
  [self destroyContext];
  [[NSApplication sharedApplication] terminate:nil];
}

- (void)applicationWillTerminate:(NSNotification *)notification_I {
  [self destroyContext];
}

@end
