//
//  AppDelegate.h
//  Wacom Kit
//
//  Created by khang on 27/2/23.
//

#ifndef AppDelegate_h
#define AppDelegate_h

#import "Logger.h"
#import "StatusItem.h"

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate> {
  CGPoint cursorAtToggle;
  int total;
  NSStatusItem *barItem;
  WStatusItem *bar;
  WLogger *logger;
  UInt32 mContextID;
  NSUInteger lastUsedTablet;
  BOOL mPrecisionOn;
}

- (void)handleKeyDown:(NSEvent *)event;

- (void)toggle;
- (void)setPrecisionMode:(NSPoint)cursor;
- (void)setFullScreenMode;
- (void)refreshMode:(NSPoint)cursor;

- (void)makeContext;
- (void)destroyContext;
- (void)resetContext;
- (void)setPortionOfScreen:(NSRect)portion;

@end

#endif /* AppDelegate_h */

// vim:ft=objc
