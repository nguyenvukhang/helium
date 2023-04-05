//
//  Logger.h
//  Wacom Kit
//
//  Created by khang on 2/4/23.
//

#import <Cocoa/Cocoa.h>

#ifndef WacomKitLogger_h
#define WacomKitLogger_h

@interface WLogger : NSObject {
  NSString *_Nonnull path;
}

- (id _Nonnull)init:(NSString *_Nonnull)path;
- (void)start:(NSString *_Nonnull)text;
- (void)log:(NSString *_Nonnull)text;
- (void)log:(NSString *_Nonnull)title detail:(NSString *_Nonnull)detail;
- (void)log:(NSString *_Nonnull)text val:(int)val;
- (void)log:(NSString *_Nonnull)text prev:(int)prev next:(int)next;
- (void)log:(NSString *_Nonnull)base t:(bool)t y:(NSString *_Nonnull)y n:(NSString *_Nonnull)n;

@end

#endif /* WacomKitLogger_h */

// vim:ft=objc
