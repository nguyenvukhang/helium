//
//  StatusItem.h
//  Wacom Kit
//
//  Created by khang on 17/3/23.
//

#import <Cocoa/Cocoa.h>

#ifndef StatusItem_h
#define StatusItem_h

@interface WKStatusItem : NSObject {
  NSObject *parent;
  NSStatusItem *item;
  NSString *PRECISION_ON_ICON;
  NSString *PRECISION_ON_DESC;
  NSString *PRECISION_OFF_ICON;
  NSString *PRECISION_OFF_DESC;
}

- (id _Nonnull)initWithParent:(NSObject *_Nonnull)parent;
- (void)setButton:(NSString *_Nonnull)icon description:(NSString *_Nonnull)description;
- (void)addBanner:(NSString *_Nonnull)title;
- (void)addMenuItem:(NSString *_Nonnull)title
      keyEquivalent:(NSString *_Nonnull)key
             action:(SEL _Nullable)action;

@end

#endif /* StatusItem_h */

// vim:ft=objc
