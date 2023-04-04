//
//  StatusItem.m
//  Wacom Kit
//
//  Created by khang on 17/3/23.
//

#import "StatusItem.h"
#include <Foundation/Foundation.h>

@implementation WStatusItem

- (id)initWithParent:(NSObject *_Nonnull)p {
  self = [super init];
  self->parent = p;

  // set icons
  PRECISION_ON_ICON = @"plus.rectangle.fill";
  PRECISION_ON_DESC = @"precision mode";
  PRECISION_OFF_ICON = @"plus.rectangle";
  PRECISION_OFF_DESC = @"full screen";
  BOUNDS_HIDE_DESC = @"Hide bounds";
  BOUNDS_SHOW_DESC = @"Show bounds";

  items = [NSMutableArray arrayWithCapacity:2];
  bar = [NSStatusBar.systemStatusBar statusItemWithLength:NSVariableStatusItemLength];
  [bar setMenu:[[NSMenu alloc] init]];
  [self setPrecisionOff];
  [self addBanner:@"Wacom Kit"];
  return self;
}

- (void)setButton:(NSString *)icon description:(NSString *)description {
  if (@available(macOS 11.0, *)) {
    NSImage *img = [NSImage imageWithSystemSymbolName:icon accessibilityDescription:description];
    [bar.button setImage:img];
  }
}

/**
 * Add a greyed-out menu entry that serves as a banner
 */
- (void)addBanner:(NSString *)title {
  NSMenuItem *it = [[NSMenuItem alloc] init];
  [it setTitle:title];
  [items addObject:it];
  [items addObject:[NSMenuItem separatorItem]];
}

- (void)addMenuItem:(NSString *)title keyEquivalent:(NSString *)key action:(SEL _Nullable)action {
  NSMenuItem *it = [[NSMenuItem alloc] init];
  [it setTitle:title];
  [it setKeyEquivalent:key];
  [it setAction:action];
  [it setTarget:parent];
  [items addObject:it];
}

- (void)setPrecisionOn {
  [self setButton:PRECISION_ON_ICON description:PRECISION_ON_DESC];
}

- (void)setPrecisionOff {
  [self setButton:PRECISION_OFF_ICON description:PRECISION_OFF_DESC];
}

- (void)setPrecisionBounds:(bool)show {
  NSString *q = show ? BOUNDS_SHOW_DESC : BOUNDS_HIDE_DESC;
  NSPredicate *p = [NSPredicate predicateWithFormat:@"title == %@", q];
  NSArray *f = [items filteredArrayUsingPredicate:p];
  [f[0] setTitle:show ? BOUNDS_HIDE_DESC : BOUNDS_SHOW_DESC];
}

- (void)build {
  [bar.menu setItemArray:items];
}

- (void)setTogglePrecisionModeAction:(SEL _Nullable)a {
  [self addMenuItem:@"Toggle precision" keyEquivalent:@"t" action:a];
  self->togglePrecisionMode = a;
}
- (void)setTogglePrecisionBoundsAction:(SEL _Nullable)a {
  [self addMenuItem:BOUNDS_HIDE_DESC keyEquivalent:@"b" action:a];
  self->togglePrecisionBounds = a;
}
- (void)setQuitAction:(SEL _Nullable)a {
  [self addMenuItem:@"Quit" keyEquivalent:@"q" action:a];
  self->quitApp = a;
}

@end
