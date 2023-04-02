//
//  Rect.h
//  Wacom Kit
//
//  Created by khang on 2/4/23.
//

#import <Cocoa/Cocoa.h>

#ifndef WacomKitRect_h
#define WacomKitRect_h

@interface WRect : NSObject {
}

+ (NSRect)scaled:(float)scale aspectRatio:(float)aspectRatio;
+ (NSRect)center:(NSRect)parent child:(NSRect)child;
+ (NSRect)smart:(NSPoint)cursor rect:(NSRect)rect;

@end

#endif /* WacomKitRect_h */

// vim:ft=objc
