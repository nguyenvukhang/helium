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

- (id)init {
  self = [super init];
  logger = [[WLogger alloc] init:@".cache/wacom/log.txt"];
  [logger start:@"--- start ---"];

  // initialize menu bar
  bar = [[WKStatusItem alloc] initWithParent:self];
  [bar addMenuItem:@"Toggle" keyEquivalent:@"t" action:@selector(toggle)];
  [bar addMenuItem:@"Quit" keyEquivalent:@"q" action:@selector(quit)];

  // track tablet proximity sensor to grab latest tablet used
  // track keystrokes to listen for toggle key combination
  [self track:NSEventMaskTabletProximity | NSEventMaskKeyDown
      handler:^(NSEvent *event) {
          if (event.type == NSEventTypeTabletProximity && event.isEnteringProximity) {
            lastUsedTablet = [event systemTabletID];
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
  [logger log:@"Key down toggle!"];
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
  [logger log:@"[ make context ]" t:mContextID == 0 y:@"make new!" n:@"keep existing."];
  if (mContextID != 0)
    return;

  mContextID = [WacomTabletDriver createContextForTablet:(UInt32)lastUsedTablet
                                                    type:pContextTypeDefault];
  [logger log:@"new context" val:mContextID];
}

/**
 * Destroys existing context.
 */
- (void)destroyContext {
  [logger log:@"[ destroy context ]" t:mContextID == 0 y:@"nothing." n:@"boom!"];
  if (mContextID == 0)
    return;

  [WacomTabletDriver destroyContext:mContextID];
  [logger log:@"id destroyed" val:mContextID];
  mContextID = 0;
}

- (void)resetContext {
  [self destroyContext];
  [self makeContext];
}

- (void)setPortionOfScreen:(NSRect)portion {
  [self resetContext];
  Rect r = [WRect legacy:portion];

  [WacomTabletDriver setBytes:&r
                       ofSize:sizeof(Rect)
                       ofType:typeQDRectangle
                 forAttribute:pMapScreenArea
                 routingTable:[WacomTabletDriver routingTableForContext:mContextID]];
}

- (void)track:(NSEventMask)mask handler:(nonnull void (^)(NSEvent *_Nonnull))handler {
  [NSEvent addGlobalMonitorForEventsMatchingMask:mask handler:handler];
}

- (void)quit {
  [self destroyContext];
  [[NSApplication sharedApplication] terminate:nil];
  [logger log:@"End of execution!"];
}

- (void)applicationWillTerminate:(NSNotification *)notification_I {
  [self destroyContext];
}

@end
