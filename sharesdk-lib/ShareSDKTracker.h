//
//  ShareSDK.h
//  shareSDK
//
//  Created by Jesse Curry on 3/27/11.
//  Copyright 2011 shareSDK, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "SSWebServiceConnectorDelegate.h"

extern NSString* const ShareSDKApplicationIDKey;

@interface ShareSDKTracker : NSObject <SSWebServiceConnectorDelegate>
{
}

@property (nonatomic, assign) BOOL verboseOutput;
@property (nonatomic, readonly) NSString* applicationId;
@property (nonatomic, readonly) NSString* uniqueId;

+ (ShareSDKTracker*)sharedTracker;

// Configuration
+ (void)start: (NSString*)applicationId;
- (void)start: (NSString*)applicationId;

// Tracking
+ (void)trackShare: (NSString*)name
				 recipient: (NSString*)recipient;
- (void)trackShare: (NSString*)name
				 recipient: (NSString*)recipient;

// URL Shortening
+ (NSDictionary*)shortenURLs: (NSArray*)urls;
- (NSDictionary*)shortenURLs: (NSArray*)urls;

@end
