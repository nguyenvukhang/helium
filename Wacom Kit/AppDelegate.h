//
//  AppDelegate.h
//  Wacom Kit
//
//  Created by khang on 27/2/23.
//

#ifndef AppDelegate_h
#define AppDelegate_h

#import <Cocoa/Cocoa.h>

#import "TabletAEDictionary.h"

NSString *PRECISION_ON_ICON = @"plus.rectangle.fill";
NSString *PRECISION_OFF_ICON = @"plus.rectangle";

@interface AppDelegate : NSObject <NSApplicationDelegate> {
  CGPoint cursorAtToggle;
  NSStatusItem *barItem;
  UInt32 mContextID;
  NSUInteger lastUsedTablet;
  BOOL mPrecisionOn;
}

- (void)makeContextForCurrentTablet;
- (void)setPortionOfScreen:(NSRect)screenPortion_I;

@end

#endif /* AppDelegate_h */
