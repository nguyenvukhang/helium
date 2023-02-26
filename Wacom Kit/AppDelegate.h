//
//  AppDelegate.h
//  Wacom Kit
//
//  Created by khang on 27/2/23.
//

#import <Cocoa/Cocoa.h>
#import "TabletAEDictionary.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>
{
  NSStatusItem *barItem;
	UInt32	mContextID;
  NSUInteger	lastUsedTablet;
	BOOL		mPrecisionOn;
	
}

- (void) makeContextForCurrentTablet;
- (void) setPortionOfScreen:(NSRect)screenPortion_I;

@end

