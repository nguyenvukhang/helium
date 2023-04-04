//
//  StatusItem.h
//  Wacom Kit
//
//  Created by khang on 17/3/23.
//

#import <Cocoa/Cocoa.h>

#ifndef StatusItem_h
#define StatusItem_h

@interface WStatusItem : NSObject {
  NSMutableArray<NSMenuItem *> *items;
  NSObject *parent;
  NSStatusItem *bar;
  NSString *PRECISION_ON_ICON;
  NSString *PRECISION_ON_DESC;
  NSString *PRECISION_OFF_ICON;
  NSString *PRECISION_OFF_DESC;
  NSString *BOUNDS_HIDE_DESC;
  NSString *BOUNDS_SHOW_DESC;

  SEL _Nullable togglePrecisionMode;
  SEL _Nullable togglePrecisionBounds;
  SEL _Nullable quitApp;
}

- (id _Nonnull)initWithParent:(NSObject *_Nonnull)parent;
- (void)setButton:(NSString *_Nonnull)icon description:(NSString *_Nonnull)description;
- (void)addBanner:(NSString *_Nonnull)title;
- (void)addMenuItem:(NSString *_Nonnull)title keyEquivalent:(NSString *_Nonnull)key action:(SEL _Nullable)action;
- (void)setPrecisionOn;
- (void)setPrecisionOff;
- (void)setPrecisionBounds:(bool)state;
- (void)build;
- (void)setTogglePrecisionModeAction:(SEL _Nullable)a;
- (void)setTogglePrecisionBoundsAction:(SEL _Nullable)a;
- (void)setQuitAction:(SEL _Nullable)a;

@end

#endif /* StatusItem_h */

// vim:ft=objc
