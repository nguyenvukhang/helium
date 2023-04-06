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

@class Wacom;

@interface Wacom : NSObject {
}

+ (void)setScreenMapArea:(NSRect)rect screen:(NSRect)s tabletId:(int)tabletId;

@end

#endif /* Bridge_h */

// vim:ft=objc
