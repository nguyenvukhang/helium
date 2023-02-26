///////////////////////////////////////////////////////////////////////////////
//
// DESCRIPTION
//    Tablet Events Only Cocoa.
//
// COPYRIGHT
//    Copyright (c) 2010 - 2023 Wacom Co., Ltd.
//    All rights reserved
//
///////////////////////////////////////////////////////////////////////////////

#pragma once

#import <Cocoa/Cocoa.h>
#import "TabletAEDictionary.h"

@interface AppController : NSObject <NSApplicationDelegate>
{
    NSStatusItem *barItem;
	
	UInt32	mContextID;
	UInt32	mTabletOfContext;
	BOOL		mPrecisionOn;
	LongRect mFullTabletArea;
	
}

@property (nonatomic)IBInspectable NSUInteger lastUsedTablet;

// Utilities
- (NSRect) desktopRect;
- (void) makeContextForCurrentTablet;
- (void) setPortionOfScreen:(NSRect)screenPortion_I;

- (NSString *) nameOfPen:(NSUInteger)serialNumber_I;

@end
