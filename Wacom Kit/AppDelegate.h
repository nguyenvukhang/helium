//
//  AppDelegate.h
//  Wacom Kit
//
//  Created by khang on 27/2/23.
//

#ifndef AppDelegate_h
#define AppDelegate_h

#import "StatusItem.h"

#import <Cocoa/Cocoa.h>

#import "TabletAEDictionary.h"

@interface AppDelegate : NSObject <NSApplicationDelegate> {
  CGPoint cursorAtToggle;
  NSStatusItem *barItem;
  WKStatusItem *bar;
  UInt32 mContextID;
  NSUInteger lastUsedTablet;
  BOOL mPrecisionOn;
}

- (void)makeContextForCurrentTablet;
- (void)setPortionOfScreen:(NSRect)screenPortion_I;

@end

#endif /* AppDelegate_h */

// vim:ft=objc
