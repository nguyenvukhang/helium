//
//  StatusItem.m
//  Wacom Kit
//
//  Created by khang on 17/3/23.
//

#import "StatusItem.h"

@implementation WStatusItem

- (id)initWithParent:(NSObject *_Nonnull)p {
  self = [super init];

  // set icons
  PRECISION_ON_ICON = @"plus.rectangle.fill";
  PRECISION_ON_DESC = @"precision mode";
  PRECISION_OFF_ICON = @"plus.rectangle";
  PRECISION_OFF_DESC = @"full screen";

  // build status bar
  item = [NSStatusBar.systemStatusBar statusItemWithLength:NSVariableStatusItemLength];
  parent = p;
  [item setMenu:[[NSMenu alloc] init]];
  [self setOff];
  [self addBanner:@"Wacom Kit"];
  [item.menu addItem:[NSMenuItem separatorItem]];
  return self;
}

- (void)setButton:(NSString *)icon description:(NSString *)description {
  if (@available(macOS 11.0, *)) {
    NSImage *img = [NSImage imageWithSystemSymbolName:icon accessibilityDescription:description];
    [item.button setImage:img];
  }
}

- (void)addBanner:(NSString *)title {
  NSMenuItem *it = [[NSMenuItem alloc] init];
  [it setTitle:title];
  [item.menu addItem:it];
}

- (void)addMenuItem:(NSString *)title keyEquivalent:(NSString *)key action:(SEL _Nullable)action {
  NSMenuItem *it = [[NSMenuItem alloc] init];
  [it setTitle:title];
  [it setKeyEquivalent:key];
  [it setAction:action];
  [it setTarget:parent];
  [item.menu addItem:it];
}

- (void)setOn {
  [self setButton:PRECISION_ON_ICON description:PRECISION_ON_DESC];
}

- (void)setOff {
  [self setButton:PRECISION_OFF_ICON description:PRECISION_OFF_DESC];
}

@end
