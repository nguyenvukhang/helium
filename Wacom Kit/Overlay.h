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
}

- (id)initWithRect:(NSRect)contentRect;
- (void)move:(NSRect)rect;
- (void)hide;
- (void)show;

@end

#endif /* WacomKitOverlay_h */

// vim:ft=objc
