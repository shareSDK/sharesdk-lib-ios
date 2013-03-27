//
//  ShareSDK.h
//  sharesdk-lib
//
//  Created by Jesse Curry on 12/16/12.
//  Copyright (c) 2012 ShareSDK. All rights reserved.
//

#import <Foundation/Foundation.h>

// View Controller
#import "SSActivityViewController.h"

// Defines
#import "shareSDKDefines.h"

@interface ShareSDK : NSObject
//////////////////////////////////////////
// ShareSDKTracker
+ (void)start: (NSString*)applicationId;

+ (void)trackShare: (NSString*)name
				 recipient: (NSString*)recipient;
@end
