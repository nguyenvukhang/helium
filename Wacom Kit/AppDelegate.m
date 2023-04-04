//
//  AppDelegate.m
//  Wacom Kit
//
//  Created by khang on 27/2/23.
//

#import "AppDelegate.h"
#import "Overlay.h"
#import "Rect.h"

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
  mPrecisionBoundsOn = YES;
  [self setFullScreenMode];

  // create overlay
  overlay = [[WOverlay alloc] init];
  wc = [[NSWindowController alloc] initWithWindow:overlay];
  [wc showWindow:overlay];

  // initialize menu bar
  [bar setTogglePrecisionModeAction:@selector(toggle)];
  [bar setTogglePrecisionBoundsAction:@selector(togglePrecisionBounds)];
  [bar setQuitAction:@selector(quit)];
  [bar build];

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
  if (cmd && shift && [event keyCode] == 0x78) { // 0x78 is 'f2'
    mPrecisionOn = YES;
    [self setPrecisionMode:[NSEvent mouseLocation]];
  }
}

/**
 * Toggle between full-screen coverage and precision mode.
 */
- (void)toggle {
  mPrecisionOn = !mPrecisionOn;
  if (mPrecisionOn)
    [self setPrecisionMode:[NSEvent mouseLocation]];
  else
    [self setFullScreenMode];
}

/**
 * Toggle setting to show precision bounds. Useful for presenting.
 */
- (void)togglePrecisionBounds {
  mPrecisionBoundsOn = !mPrecisionBoundsOn;
  [overlay setEnabled:mPrecisionBoundsOn];
  [bar setPrecisionBounds:mPrecisionBoundsOn];
  if (mPrecisionBoundsOn) {
    [overlay flash];
  } else {
    [overlay hide];
  }
}

/**
 * Start Precision Mode.
 */
- (void)setPrecisionMode:(NSPoint)cursor {
  NSRect rect = [WRect scale:[WRect fillScreen:ASPECT_RATIO] by:SCALE];
  rect = [WRect moveInScreen:rect to:cursor];
  [self setPortionOfScreen:rect];
  [bar setPrecisionOn];
  [overlay move:rect];
  [overlay flash];
}

/**
 * Start FullScreen Mode.
 */
- (void)setFullScreenMode {
  NSRect rect = [WRect fillScreen:ASPECT_RATIO];
  [self setPortionOfScreen:[WRect centerInScreen:rect]];
  [bar setPrecisionOff];
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
  id handler = ^(NSEvent *ev) {
      if (ev.type == NSEventTypeTabletProximity) {
        if (ev.isEnteringProximity) {
          self->lastUsedTablet = (int)[ev systemTabletID];
          if (self->mPrecisionOn)
            [self->overlay show];
        } else {
          [self->overlay hide];
        }
      }
      if (ev.type == NSEventTypeKeyDown)
        [self handleKeyDown:ev];
  };
  [NSEvent addGlobalMonitorForEventsMatchingMask:mask handler:handler];
}

- (void)quit {
  [self setFullScreenMode];
  [[NSApplication sharedApplication] terminate:nil];
}

@end
