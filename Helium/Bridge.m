//
//  Helium.m
//  Helium
//
//  Created by khang on 5/4/23.
//

#import "Bridge.h"
#import "WacomTabletDriver.h"

Rect legacyRect(NSRect rect, NSRect screen) {
  Rect r;
  r.left = NSMinX(rect);
  r.right = NSMaxX(rect);
  r.top = NSMaxY(screen) + 0.5 - NSMaxY(rect);
  r.bottom = NSMaxY(screen) + 0.5 - NSMinY(rect);
  return r;
}

@implementation Wacom

+ (void)setScreenMapArea:(NSRect)rect
                  screen:(NSRect)screen
                tabletId:(int)tabletId {
  Rect r = legacyRect(rect, screen);
  [WacomTabletDriver setBytes:&r
                       ofSize:sizeof(Rect)
                       ofType:typeQDRectangle
                 forAttribute:pMapScreenArea
                 routingTable:[WacomTabletDriver routingTableForTablet:tabletId
                                                            transducer:1]];
}
@end
