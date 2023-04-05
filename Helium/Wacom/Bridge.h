//
//  Bridge.h
//  Helium
//
//  Created by khang on 5/4/23.
//

#ifndef Bridge_h
#define Bridge_h

#import "WacomTabletDriver.h"

#import <Foundation/Foundation.h>

@interface HRect : NSObject {
}

+ (Rect)legacy:(NSRect)rect screen:(NSRect)screen;
+ (void)setScreenMapArea:(NSRect)rect screen:(NSRect)s forTablet:(int)tabletId;

@end

#endif /* Bridge_h */
