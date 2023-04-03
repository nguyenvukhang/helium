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

- (id)init:(NSString *_Nonnull)path;
- (void)start:(NSString *)text;
- (void)log:(NSString *)text;
- (void)log:(NSString *)title detail:(NSString *)detail;
- (void)log:(NSString *)text val:(int)val;
- (void)log:(NSString *)text prev:(int)prev next:(int)next;
- (void)log:(NSString *)base t:(bool)t y:(NSString *)y n:(NSString *)n;

@end

#endif /* WacomKitLogger_h */

// vim:ft=objc
