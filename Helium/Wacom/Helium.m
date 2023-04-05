//
//  Helium.m
//  Helium
//
//  Created by khang on 5/4/23.
//

#import "Bridge.h"
#import "WacomTabletDriver.h"

@implementation HRect

/**
 * Convert Cocoa rect to old QuickDraw rect.
 */
+ (Rect)legacy:(NSRect)rect screen:(NSRect)s {
  Rect r;
  r.left = NSMinX(rect);
  r.right = NSMaxX(rect);
  r.top = NSMaxY(s) - NSMaxY(rect);
  r.bottom = NSMaxY(s) - NSMinY(rect);
  return r;
}

/**
 * Set tablet to only cover a specified Rect on the screen.
 */
+ (void)setScreenMapArea:(NSRect)rect screen:(NSRect)s forTablet:(int)tabletId {
  Rect r = [HRect legacy:rect screen:s];
  [WacomTabletDriver setBytes:&r
                       ofSize:sizeof(Rect)
                       ofType:typeQDRectangle
                 forAttribute:pMapScreenArea
                 routingTable:[WacomTabletDriver routingTableForTablet:tabletId transducer:1]];
}

@end
