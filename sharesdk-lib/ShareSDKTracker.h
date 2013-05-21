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

typedef void (^SSURLShortenerCompletionHandler)(NSDictionary* shortenedURLs, NSError* error);

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
+ (void)trackShare: (NSString*)name
				 recipient: (NSString*)recipient
		 sharedLinkIds: (NSArray*)sharedLinkIds;
- (void)trackShare: (NSString*)name
				 recipient: (NSString*)recipient
		 sharedLinkIds: (NSArray*)sharedLinkIds;

// URL Shortening
+ (void)shortenURLs: (NSArray*)urls
withCompletionHandler: (SSURLShortenerCompletionHandler)completionHandler;
- (void)shortenURLs: (NSArray*)urls
withCompletionHandler: (SSURLShortenerCompletionHandler)completionHandler;

@end
