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
  PADDING = 10;
  [self setIgnoresMouseEvents:YES];
  [self setLevel:NSFloatingWindowLevel];
  [self setAlphaValue:0];
  mEnabled = YES;
  return self;
}

- (void)show {
  if (!mEnabled)
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
  [self animate:1.0f to:0];
}

- (void)flash {
  if (!mEnabled)
    return;
  [self setAlphaValue:1];
  [self animate:1.0f to:0];
}

- (void)move:(NSRect)toRect {
  toRect.size.height += 2 * PADDING;
  toRect.size.width += 2 * PADDING;
  toRect.origin.x -= PADDING;
  toRect.origin.y -= PADDING;
  [self setFrame:toRect display:YES];
  [self drawBorder];
}

- (void)drawBounds:(NSBezierPath *)bz bounds:(NSRect)r length:(CGFloat)l {
  CGFloat x1 = PADDING, x2 = r.size.width - PADDING;
  CGFloat y1 = PADDING, y2 = r.size.height - PADDING;

  [bz moveToPoint:NSMakePoint(x1 + l, y1)];
  [bz lineToPoint:NSMakePoint(x1, y1)];
  [bz lineToPoint:NSMakePoint(x1, y1 + l)];

  [bz moveToPoint:NSMakePoint(x1 + l, y2)];
  [bz lineToPoint:NSMakePoint(x1, y2)];
  [bz lineToPoint:NSMakePoint(x1, y2 - l)];

  [bz moveToPoint:NSMakePoint(x2 - l, y1)];
  [bz lineToPoint:NSMakePoint(x2, y1)];
  [bz lineToPoint:NSMakePoint(x2, y1 + l)];

  [bz moveToPoint:NSMakePoint(x2 - l, y2)];
  [bz lineToPoint:NSMakePoint(x2, y2)];
  [bz lineToPoint:NSMakePoint(x2, y2 - l)];
}

- (void)drawBorder {
  NSImage *bg = [[NSImage alloc] initWithSize:[self frame].size];

  // Prepares the image to receive drawing commands.
  [bg lockFocus];
  NSColor *color = [NSColor colorWithRed:0.925 green:0.282 blue:0.600 alpha:0.5];
  [color set];

  NSRect f = [self frame];
  CGFloat w = f.size.width, h = f.size.height;
  NSBezierPath *bz = [NSBezierPath bezierPath];
  [bz setLineWidth:5];
  [self drawBounds:bz bounds:[self frame] length:32];
  [bz stroke];

  [bg unlockFocus];

  [self setBackgroundColor:[NSColor colorWithPatternImage:bg]];
}

- (void)setEnabled:(bool)state {
  mEnabled = state;
  if (!state)
    [self hide];
}

@end
