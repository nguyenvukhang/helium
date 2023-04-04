//
//  Overlay.h
//  Wacom Kit
//
//  Created by khang on 2/4/23.
//

#import <Cocoa/Cocoa.h>

#ifndef WacomKitOverlay_h
#define WacomKitOverlay_h

@interface WOverlay : NSWindow {
  BOOL mEnabled;
}

- (void)move:(NSRect)rect;
- (void)show;
- (void)hide;
- (void)flash;
- (void)setEnabled:(bool)state;

@end

#endif /* WacomKitOverlay_h */

// vim:ft=objc
