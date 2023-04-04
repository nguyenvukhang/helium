//
//  AppDelegate.m
//  Wacom Kit
//
//  Created by khang on 27/2/23.
//

#import "AppDelegate.h"
#import "Overlay.h"
#import "Rect.h"
#include <AppKit/AppKit.h>

#import "Wacom/WacomTabletDriver.h"

@implementation AppDelegate

const double SCALE = 0.48;       // personal preference
const double ASPECT_RATIO = 1.6; // Wacom Intuous' aspect ratio

- (id)init {
  self = [super init];

  // initialize attributes
  bar = [[WStatusItem alloc] initWithParent:self];
  lastUsedTablet = 0; // 0 is an invalid tablet index.
  mPrecisionOn = NO;
  [self setFullScreenMode];

  // create overlay
  overlay = [[WOverlay alloc] initWithRect:NSMakeRect(0, 0, 2, 2)];
  wc = [[NSWindowController alloc] initWithWindow:overlay];
  [wc showWindow:overlay];

  // initialize menu bar
  [bar addMenuItem:@"Toggle" keyEquivalent:@"t" action:@selector(toggle)];
  [bar addMenuItem:@"Quit" keyEquivalent:@"q" action:@selector(quit)];

  // listen to global events
  [self trackKeys];

  return self;
}

/**
 * Trigger a toggle on Cmd + Shift + F2.
 */
- (void)handleKeyDown:(NSEvent *)event {
  BOOL cmd = [event modifierFlags] & NSEventModifierFlagCommand;
  BOOL shift = [event modifierFlags] & NSEventModifierFlagShift;
  if (cmd && shift && [event keyCode] == 0x78) // 0x78 is 'f2'
    [self toggle];
}

/**
 * Toggle between full-screen coverage and precision mode.
 */
- (void)toggle {
  self->mPrecisionOn = !self->mPrecisionOn;
  if (mPrecisionOn)
    [self setPrecisionMode:[NSEvent mouseLocation]];
  else
    [self setFullScreenMode];
}

/**
 * Start Precision Mode.
 */
- (void)setPrecisionMode:(NSPoint)cursor {
  NSRect rect = [WRect scaled:SCALE aspectRatio:ASPECT_RATIO];
  NSRect smart = [WRect smart:rect at:cursor];
  [self setPortionOfScreen:smart];
  [bar setOn];
  [overlay move:smart];
  [overlay show];
}

/**
 * Start FullScreen Mode.
 */
- (void)setFullScreenMode {
  NSRect full = [WRect scaled:1 aspectRatio:ASPECT_RATIO];
  full = [WRect center:([NSScreen screens][0].frame) child:full];
  [self setPortionOfScreen:full];
  [bar setOff];
  [overlay hide];
}

/**
 * Sets the tablet to cover a specified portion of the screen.
 */
- (void)setPortionOfScreen:(NSRect)portion {
  Rect r = [WRect legacy:portion];
  [WacomTabletDriver setBytes:&r
                       ofSize:sizeof(Rect)
                       ofType:typeQDRectangle
                 forAttribute:pMapScreenArea
                 routingTable:[WacomTabletDriver routingTableForTablet:lastUsedTablet transducer:1]];
}

/**
 * Track keystrokes.
 *   - track tablet proximity sensor to grab latest tablet used
 *   - track keystrokes to listen for toggle key combination
 */
- (void)trackKeys {
  NSEventMask mask = NSEventMaskTabletProximity | NSEventMaskKeyDown;
  id handler = ^(NSEvent *event) {
      if (event.type == NSEventTypeTabletProximity && event.isEnteringProximity)
        self->lastUsedTablet = (int)[event systemTabletID];
      if (event.type == NSEventTypeKeyDown)
        [self handleKeyDown:event];
  };
  [NSEvent addGlobalMonitorForEventsMatchingMask:mask handler:handler];
}

- (void)quit {
  [self setFullScreenMode];
  [[NSApplication sharedApplication] terminate:nil];
}

@end
