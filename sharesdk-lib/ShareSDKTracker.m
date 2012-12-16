//
//  ShareSDK.m
//  shareSDK
//
//  Created by Jesse Curry on 3/27/11.
//  Copyright 2011 shareSDK, LLC. All rights reserved.
//

#import "ShareSDKTracker.h"

// 
#import "SSWebServiceConnector.h"

#define VERBOSE_LOG(...)  if(verboseOutput){SS_LOG(__VA_ARGS__);}

static NSString* _applicationId = nil;

////////////////////////////////////////////////////////////////////////////////////////////////////
@interface ShareSDKTracker ()
@property (nonatomic, readonly) NSUserDefaults* prefs;
@end
////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation ShareSDKTracker
@synthesize verboseOutput;

- (id)init
{
    self = [super init];
    if ( self )
    {
        
    }
	
    return self;
}

#pragma mark -
#pragma mark Configuration
+ (void)start: (NSString*)applicationId
{
    [[[self class] sharedTracker] start: applicationId];
}

- (void)start: (NSString*)applicationId
{
	_applicationId = SS_FORCE_STRING(applicationId);
}

- (NSString*)applicationId
{
    return _applicationId;
}

- (NSString*)uniqueId
{
	return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
}

#pragma mark - 
#pragma mark Tracking
+ (void)trackShare: (NSString*)name
		 recipient: (NSString*)recipient
{
	[[[self class] sharedTracker] trackShare: name
								   recipient: recipient];
}

- (void)trackShare: (NSString*)name
		 recipient: (NSString*)recipient
{
	if ( name == nil )
		name = @"Unknown";
	
	if ( recipient == nil )
		recipient = @"Unknown";
	
	NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:
							self.applicationId, @"a",
							self.uniqueId, @"u",
							name, @"t",
							recipient, @"r", nil];
	
	SSWebServiceConnector* wsc = [[SSWebServiceConnector alloc] 
								  initWithURLString: @"http://sharesdk.com/track_share"
								  parameters: params 
								  httpBody: nil
								  delegate: self];
	
	if ( wsc )
	{
		wsc.httpMethod = @"POST";
		[wsc start];
	}
}

#pragma mark -
#pragma mark Private
- (NSUserDefaults*)prefs
{
    return [NSUserDefaults standardUserDefaults];
}

#pragma mark -
#pragma mark SSWebServiceConnectorDelegate
- (void)webServiceConnector: (SSWebServiceConnector*)webServiceConnector 
		didFinishWithResult: (id)result
{
	VERBOSE_LOG(@"[%@]didFinishWithResult: %@", CLASS_NAME, result);
}

- (void)webServiceConnector: (SSWebServiceConnector*)webServiceConnector 
		   didFailWithError: (NSError*)error
{
	VERBOSE_LOG(@"[%@]didFailWithError: %@", CLASS_NAME, [error localizedDescription]);
}

#pragma mark -
#pragma mark Singleton Implementation
+ (ShareSDKTracker*)sharedTracker
{
    static dispatch_once_t pred;
    static ShareSDKTracker* _sharedTracker = nil;
    dispatch_once(&pred, ^{
        _sharedTracker = [[self alloc] init];
    });
	
    return _sharedTracker;
}

@end
