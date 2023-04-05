//
//  Rect.m
//  Wacom Kit
//
//  Created by khang on 2/4/23.
//

#import "Rect.h"

@implementation WRect

+ (NSRect)screen {
  return [NSScreen screens][0].frame;
}

/**
 * Scales a rect.
 */
+ (NSRect)scale:(NSRect)rect by:(CGFloat)r {
  rect.size.width *= r;
  rect.size.height *= r;
  return rect;
}

/**
 * Moves the rect such that its center is as close as possible to the
 * cursor while still being in the bounds.
 */
+ (NSRect)move:(NSRect)rect to:(NSPoint)cursor bounds:(NSRect)bounds {
  CGFloat lx = rect.size.width / 2, ly = rect.size.height / 2;
  CGFloat rx = bounds.size.width - lx, ry = bounds.size.height - lx;
  rect.origin.x = MIN(MAX(lx, cursor.x), rx) - lx;
  rect.origin.y = MIN(MAX(ly, cursor.y), ry) - ly;
  return rect;
}

/**
 * Moves the rect such that its center is as close as possible to the
 * cursor while still being in the screen.
 */
+ (NSRect)moveInScreen:(NSRect)rect to:(NSPoint)cursor {
  return [WRect move:rect to:cursor bounds:[WRect screen]];
}

/**
 * Fills a parent rect, given an aspect ratio constraint
 */
+ (NSRect)fill:(NSRect)parent aspectRatio:(CGFloat)r {
  CGFloat w = MIN(parent.size.height * r, parent.size.width);
  return NSMakeRect(0, 0, w, w / r);
}

/**
 * Fills the current screen, given an aspect ratio constraint
 */
+ (NSRect)fillScreen:(CGFloat)aspectRatio {
  return [WRect fill:[WRect screen] aspectRatio:aspectRatio];
}

/**
 * Center a child rect in a parent rect.
 * Parent's origin is The origin.
 */
+ (NSRect)center:(NSRect)c in:(NSRect)p {
  c.origin.x = (p.size.width - c.size.width) / 2;
  c.origin.y = (p.size.height - c.size.height) / 2;
  return c;
}

/**
 * Center a rect in the current screen.
 */
+ (NSRect)centerInScreen:(NSRect)rect {
  return [WRect center:rect in:[WRect screen]];
}

/**
 * Convert Cocoa rect to old QuickDraw rect.
 */
+ (Rect)legacy:(NSRect)rect {
  NSRect s = [WRect screen];
  Rect r;
  r.left = NSMinX(rect);
  r.right = NSMaxX(rect);
  r.top = NSMaxY(s) - NSMaxY(rect);
  r.bottom = NSMaxY(s) - NSMinY(rect);
  return r;
}

@end
