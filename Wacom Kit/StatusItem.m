//
//  StatusItem.m
//  Wacom Kit
//
//  Created by khang on 17/3/23.
//

#import "StatusItem.h"

@implementation WKStatusItem

- (id)init:(NSObject *_Nonnull)parent {
  self = [super init];
  self->parent = parent;
  return self;
}

- (void)setButton:(NSString *)icon description:(NSString *)description {
  if (@available(macOS 11.0, *)) {
    [self.button setImage:[NSImage imageWithSystemSymbolName:icon
                                    accessibilityDescription:description]];
  }
}

- (void)addBanner:(NSString *)title {
  NSMenuItem *it = [[NSMenuItem alloc] init];
  [it setTitle:title];
  [self.menu addItem:it];
}

- (void)addMenuItem:(NSString *)title keyEquivalent:(NSString *)key action:(SEL _Nullable)action {
  NSMenuItem *it = [[NSMenuItem alloc] init];
  [it setTitle:title];
  [it setKeyEquivalent:key];
  [it setAction:action];
  [it setTarget:self->parent];
  [self.menu addItem:it];
}

@end
