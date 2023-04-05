//
//  Helium.h
//  Helium
//
//  Created by khang on 5/4/23.
//

#ifndef Helium_h
#define Helium_h

#import <Foundation/Foundation.h>

@interface HRect : NSObject {
}

+ (Rect)legacy:(NSRect)rect screen:(NSRect)screen;
+ (void)setScreenMapArea:(NSRect)rect screen:(NSRect)s forTablet:(int)tabletId;

@end

#endif /* Helium_h */

// vim:ft=objc
