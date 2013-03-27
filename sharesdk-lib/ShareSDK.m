//
//  ShareSDK.m
//  sharesdk-lib
//
//  Created by Jesse Curry on 12/16/12.
//  Copyright (c) 2012 ShareSDK. All rights reserved.
//

#import "ShareSDK.h"

// Tracker
#import "ShareSDKTracker.h"

@implementation ShareSDK
+ (void)start: (NSString*)applicationId
{
	[ShareSDKTracker start: applicationId];
}

+ (void)trackShare: (NSString*)name
				 recipient: (NSString*)recipient
{
	[ShareSDKTracker trackShare: name
										recipient: recipient];
}

@end
