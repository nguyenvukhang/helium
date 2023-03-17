//
//  StatusItem.h
//  Wacom Kit
//
//  Created by khang on 17/3/23.
//

#ifndef StatusItem_h
#define StatusItem_h

#import <Cocoa/Cocoa.h>

@interface WKStatusItem : NSStatusItem {
  NSObject *parent;
}

- (void)setButton:(NSString *_Nonnull)icon description:(NSString *_Nonnull)description;
- (void)addBanner:(NSString *_Nonnull)title;
- (void)addMenuItem:(NSString *_Nonnull)title
      keyEquivalent:(NSString *_Nonnull)key
             action:(SEL _Nullable)action;

@end

#endif /* StatusItem_h */
