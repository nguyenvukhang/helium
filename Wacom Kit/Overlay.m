//
//  Overlay.m
//  Wacom Kit
//
//  Created by khang on 2/4/23.
//

#import "Overlay.h"

@implementation WOverlay

- (id)initWithRect:(NSRect)contentRect {
  self = [super initWithContentRect:contentRect
                          styleMask:NSWindowStyleMaskBorderless
                            backing:NSBackingStoreBuffered
                              defer:YES];

  if (self) {
    [self setOpaque:YES];
    [self setBackgroundColor:[self addBorderToBackground]];
    [self setIgnoresMouseEvents:YES];
    [self setLevel:NSFloatingWindowLevel];
    [self setAlphaValue:0];
  }

  return self;
}

- (void)show {
  [self setAlphaValue:1];
}

- (void)fade {
  float alpha = [self alphaValue];
  [self setAlphaValue:alpha];
  [self makeKeyAndOrderFront:self];
  [NSAnimationContext beginGrouping];
  [[NSAnimationContext currentContext] setDuration:1.5f];
  [[self animator] setAlphaValue:0.f];
  [NSAnimationContext endGrouping];
}

- (void)hide {
  [self setAlphaValue:0];
}

- (void)move:(NSRect)to {
  [self setFrame:to display:YES];
  [self setBackgroundColor:[self addBorderToBackground]];
}

- (NSColor *)addBorderToBackground {
  NSImage *bg = [[NSImage alloc] initWithSize:[self frame].size];

  // Prepares the image to receive drawing commands.
  [bg lockFocus];

  [[NSColor colorWithRed:0.925 green:0.282 blue:0.600 alpha:0.5] set];
  NSRect f = [self frame];
  f = NSMakeRect(0, 0, f.size.width, f.size.height);
  NSBezierPath *bz = [NSBezierPath bezierPathWithRect:f];
  [bz stroke];

  [bg unlockFocus];

  return [NSColor colorWithPatternImage:bg];
}

@end
