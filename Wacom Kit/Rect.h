//
//  Rect.h
//  Wacom Kit
//
//  Created by khang on 2/4/23.
//

#import <Foundation/Foundation.h>

#ifndef WacomKitRect_h
#define WacomKitRect_h

@interface WRect : NSObject {
}

+ (NSRect)getScaled:(float)scale aspectRatio:(float)aspectRatio;
+ (NSRect)center:(NSRect)parent child:(NSRect)child;
+ (NSRect)setSmart:(NSPoint)cursor rect:(NSRect)rect;

@end

#endif /* WacomKitRect_h */

// vim:ft=objc
