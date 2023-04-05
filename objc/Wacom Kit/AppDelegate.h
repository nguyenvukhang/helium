//
//  AppDelegate.h
//  Wacom Kit
//
//  Created by khang on 27/2/23.
//

#ifndef AppDelegate_h
#define AppDelegate_h

#import "Overlay.h"
#import "StatusItem.h"

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate> {
  NSRect PRECISE_RECT;
  WOverlay *overlay;
  NSWindowController *wc;
  NSStatusItem *barItem;
  WStatusItem *bar;
  int lastUsedTablet;
  BOOL mPrecisionOn;
  BOOL mPrecisionBoundsOn;
}

@end

#endif /* AppDelegate_h */

// vim:ft=objc
