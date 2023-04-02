//
//  Rect.m
//  Wacom Kit
//
//  Created by khang on 2/4/23.
//

#import "Rect.h"

@implementation WRect

+ (NSRect)scaled:(float)scale aspectRatio:(float)aspectRatio {
  NSRect screen = [NSScreen screens][0].frame;
  NSRect scaled = NSZeroRect;
  scaled.origin.x = 0;
  scaled.origin.y = 0;
  scaled.size.width = screen.size.width * scale;
  scaled.size.height = scaled.size.width / aspectRatio;
  return scaled;
}

+ (NSRect)center:(NSRect)parent child:(NSRect)child {
  child.origin.x = (parent.size.width / 2) - (child.size.width / 2);
  child.origin.y = (parent.size.height / 2) - (child.size.height / 2);
  return child;
}

+ (NSRect)smart:(NSPoint)cursor rect:(NSRect)rect {
  // bounds
  NSRect screen = [NSScreen screens][0].frame;

  // center rect at cursor
  rect.origin = cursor;
  rect.origin.x -= rect.size.width / 2;
  rect.origin.y -= rect.size.height / 2;

  // adjust it minimally to have it within bounds

  // rect is sticking out on the left side
  if (NSMinX(rect) < 0)
    rect.origin.x -= NSMinX(rect);

  // rect is sticking out on the right side
  if (NSMaxX(rect) > NSMaxX(screen))
    rect.origin.x -= NSMaxX(rect) - NSMaxX(screen);

  // rect is sticking out below
  if (NSMinY(rect) < 0)
    rect.origin.y -= NSMinY(rect);

  // rect is sticking out above
  if (NSMaxY(rect) > NSMaxY(screen))
    rect.origin.y -= NSMaxY(rect) - NSMaxY(screen);

  return rect;
}

/**
 * Convert Cocoa rect to old QuickDraw rect.
 */
+ (Rect)legacy:(NSRect)rect {
  NSRect s = [NSScreen screens][0].frame;
  Rect r = {0};

  r.left = NSMinX(rect);
  r.top = NSMaxY(s) - NSMaxY(rect) + 1;
  r.right = NSMaxX(rect);
  r.bottom = NSMaxY(s) - NSMinY(rect) + 1;

  return r;
}

@end
