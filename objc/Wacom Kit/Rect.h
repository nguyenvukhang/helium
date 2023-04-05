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

+ (NSRect)screen;
+ (NSRect)scale:(NSRect)rect by:(CGFloat)ratio;

+ (NSRect)move:(NSRect)rect to:(NSPoint)cursor bounds:(NSRect)bounds;
+ (NSRect)moveInScreen:(NSRect)rect to:(NSPoint)cursor;

+ (NSRect)fill:(NSRect)parent aspectRatio:(CGFloat)r;
+ (NSRect)fillScreen:(CGFloat)aspectRatio;

+ (NSRect)center:(NSRect)child in:(NSRect)parent;
+ (NSRect)centerInScreen:(NSRect)rect;

+ (Rect)legacy:(NSRect)rect;

@end

#endif /* WacomKitRect_h */

// vim:ft=objc
