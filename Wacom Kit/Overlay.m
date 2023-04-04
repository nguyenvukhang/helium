//
//  Overlay.m
//  Wacom Kit
//
//  Created by khang on 2/4/23.
//

#import "Overlay.h"

@implementation WOverlay

- (id)init {
  self = [super initWithContentRect:NSMakeRect(0, 0, 1, 1)
                          styleMask:NSWindowStyleMaskBorderless
                            backing:NSBackingStoreBuffered
                              defer:YES];
  [self setIgnoresMouseEvents:YES];
  [self setLevel:NSFloatingWindowLevel];
  [self setAlphaValue:0];
  enabled = true;
  return self;
}

- (void)show {
  if (!enabled)
    return;
  [self setAlphaValue:1];
}

- (void)animate:(CGFloat)duration to:(NSTimeInterval)to {
  [NSAnimationContext beginGrouping];
  [[NSAnimationContext currentContext] setDuration:duration];
  [[self animator] setAlphaValue:to];
  [NSAnimationContext endGrouping];
}

- (void)hide {
  [self animate:1.5f to:0];
}

- (void)flash {
  if (!enabled)
    return;
  [self setAlphaValue:1];
  [self animate:1.5f to:0];
}

- (void)move:(NSRect)toRect {
  [self setFrame:toRect display:YES];
  [self drawBorder];
}

- (void)drawBorder {
  NSImage *bg = [[NSImage alloc] initWithSize:[self frame].size];

  // Prepares the image to receive drawing commands.
  [bg lockFocus];

  [[NSColor colorWithRed:0.925 green:0.282 blue:0.600 alpha:1] set];
  NSRect f = [self frame];
  f = NSMakeRect(0, 0, f.size.width, f.size.height);
  NSBezierPath *bz = [NSBezierPath bezierPathWithRect:f];
  [bz stroke];

  [bg unlockFocus];

  [self setBackgroundColor:[NSColor colorWithPatternImage:bg]];
}

- (void)enable {
  enabled = YES;
}

- (void)disable {
  enabled = NO;
  [self hide];
}

@end
