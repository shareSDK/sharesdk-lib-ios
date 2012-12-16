//
//  SSActivityViewController.m
//  Analytics
//
//  Created by Jesse Curry on 12/1/12.
//
//

#import "SSActivityViewController.h"

#import "ShareSDKTracker.h"

@interface SSActivityViewController ()
@property (nonatomic, copy) UIActivityViewControllerCompletionHandler shareSDKCompletionHandler;
@property (nonatomic, copy) NSString* shareType;
- (NSString*)shareTypeForActivityItems: (NSArray*)activityItems;
- (NSString*)recipientForActivityType: (NSString*)activityType;
@end

////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation SSActivityViewController
@synthesize shareSDKCompletionHandler=_shareSDKCompletionHandler;
@synthesize shareType=_shareType;

- (id)initWithActivityItems: (NSArray*)activityItems
	  applicationActivities: (NSArray*)applicationActivities
{
	self = [super initWithActivityItems: activityItems
				  applicationActivities: applicationActivities];
	
	if ( self )
	{
		// Setup the share type
		for ( id activityItem in activityItems )
			SS_LOG(@"activityItem: %@", activityItem);
		
		for ( id applicationActivity in applicationActivities )
			SS_LOG(@"applicationActivity: %@", applicationActivity);
		
		self.shareType = [self shareTypeForActivityItems: activityItems];
	}
	
	return self;
}

- (void)dealloc
{
	self.shareSDKCompletionHandler = nil;
	self.shareType = nil;
}

- (void)setCompletionHandler: (UIActivityViewControllerCompletionHandler)completionHandler
{
	self.shareSDKCompletionHandler = completionHandler;
	
	super.completionHandler = ^(NSString* activityType, BOOL completed){
		if ( completed )
		{
			// Track share
			NSString* recipient = [self recipientForActivityType: activityType];
			[[ShareSDKTracker sharedTracker] trackShare: self.shareType
											  recipient: recipient];
		}
		
		// Call supplied completion handler
		self.shareSDKCompletionHandler(activityType, completed);
	};
}

#pragma mark - Private
- (NSString*)shareTypeForActivityItems: (NSArray*)activityItems
{
	NSString* shareType = nil;
	
	Class lastClass = nil;
	for ( id activityItem in activityItems )
	{
		Class currentClass = [activityItem class];
		if ( shareType == nil )
		{
			if ( [currentClass isSubclassOfClass: [NSString class]] )
				shareType = NSLocalizedString(@"Text", @"ShareSDK Share Type");
			else if ( [currentClass isSubclassOfClass: [UIImage class]] )
				shareType = NSLocalizedString(@"Image", @"ShareSDK Share Type");
			else
				shareType = NSLocalizedString(@"Other", @"ShareSDK Share Type");
		}
		else
		{
			// Check to see if this is a homogenous batch.
			if ( ![lastClass isSubclassOfClass: currentClass] )
			{
				shareType = NSLocalizedString(@"Multimedia", @"ShareSDK Share Type");
				break;
			}
		}
		
		lastClass = currentClass;
	}
	
	return shareType;
}

- (NSString*)recipientForActivityType:(NSString *)activityType
{
	NSString* recipient = activityType;
	
	if ( [activityType isEqualToString: UIActivityTypePostToFacebook] )
	{
		recipient = NSLocalizedString(@"Facebook", @"ShareSDK Recipient");
	}
	else if ( [activityType isEqualToString: UIActivityTypePostToTwitter] )
	{
		recipient = NSLocalizedString(@"Twitter", @"ShareSDK Recipient");
	}
	else if ( [activityType isEqualToString: UIActivityTypePostToWeibo] )
	{
		recipient = NSLocalizedString(@"Weibo", @"ShareSDK Recipient");
	}
	
	return recipient;
}

@end
