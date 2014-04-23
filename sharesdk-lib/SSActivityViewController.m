//
//  SSActivityViewController.m
//  Analytics
//
//  Created by Jesse Curry on 12/1/12.
//
//

#import "SSActivityViewController.h"
#import "shareSDKDefines.h"

// Tracker
#import "ShareSDKTracker.h"

static LinkShorteningBehavior _linkShorteningBehavior = LinkShorteningBehaviorAutomatic;

#define SS_SAFE_STRING(str)		([str isKindOfClass: [NSString class]] ? str : nil)

////////////////////////////////////////////////////////////////////////////////////////////////////
@interface SSActivityViewController ()
@property (nonatomic, copy) UIActivityViewControllerCompletionHandler shareSDKCompletionHandler;
@property (nonatomic, copy) NSString* shareType;
- (NSString*)shareTypeForActivityItems: (NSArray*)activityItems;
- (NSString*)recipientForActivityType: (NSString*)activityType;

// Link Shortening
+ (NSArray*)extractURLs: (NSString*)text;
+ (NSString*)replaceURLs: (NSDictionary*)urls
									inText: (NSString*)text;

// Track shortened links
@property	NSArray* sharedLinkIds;
- (void)buildSharedLinkIdsForActivityItems: (NSArray*)activityItems;
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
		
		[self buildSharedLinkIdsForActivityItems: activityItems];
		
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
																				recipient: recipient
																		sharedLinkIds: self.sharedLinkIds];
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

#pragma mark - Link Shortening
+ (void)setLinkShorteningBehavior: (LinkShorteningBehavior)linkShorteningBehavior
{
	_linkShorteningBehavior = linkShorteningBehavior;
}

+ (void)shortenLinksIfNeeded: (NSString*)text
			 withCompletionHandler: (SSLinkReplacementHandler)completionHandler
{
	if ( _linkShorteningBehavior != LinkShorteningBehaviorNever )
	{
		NSArray* urls = [self extractURLs: text];
		
		[ShareSDKTracker shortenURLs: urls
					 withCompletionHandler: ^(NSDictionary* shortURLs, NSError* error) {
						 if ( shortURLs )
						 {
							 NSString* shortText = [self replaceURLs: shortURLs
																								inText: text];
							 completionHandler(shortText);
						 }
						 else
						 {
							 completionHandler(text);
						 }
		}];
	}
	else
	{
		// Do nothing, just return the same text
		completionHandler(text);
	}
}

+ (NSArray*)extractURLs: (NSString*)text
{
	NSMutableArray* urls = [NSMutableArray array];
	
	if ( text )
	{
		NSDataDetector* linkDetector = [NSDataDetector dataDetectorWithTypes: NSTextCheckingTypeLink
																																	 error: nil];
		NSArray* matches = [linkDetector matchesInString: text
																						 options: 0
																							 range: NSMakeRange(0, text.length)];
		
		urls = [NSMutableArray arrayWithCapacity: matches.count];
		for ( NSTextCheckingResult* match in matches )
		{
			if ( [match resultType] == NSTextCheckingTypeLink )
			{
				NSString* urlString = [[match URL] absoluteString];
				if ( urlString )
					[urls addObject: urlString];
			}
		}
	}
	
	return urls;
}

+ (NSString*)replaceURLs: (NSDictionary*)urls
									inText: (NSString*)text
{
	NSString* replacedText = text;
	
	for ( NSString* originalURL in urls )
	{
		NSString* shortURL = SS_SAFE_STRING(urls[originalURL]);
		
		if ( _linkShorteningBehavior == LinkShorteningBehaviorAutomatic )
		{
			if ( shortURL != nil
					&& originalURL.length > shortURL.length )
			{
				replacedText = [replacedText stringByReplacingOccurrencesOfString: originalURL
																															 withString: shortURL];
			}
		}
		else if ( _linkShorteningBehavior == LinkShorteningBehaviorAlways )
		{
			replacedText = [replacedText stringByReplacingOccurrencesOfString: originalURL
																														 withString: shortURL];
		}
	}
	
	return replacedText;
}

#pragma mark -
- (void)buildSharedLinkIdsForActivityItems: (NSArray*)activityItems
{
	NSMutableArray* strings = [NSMutableArray array];
	
	// Pull strings for all of the activity items.
	for ( id activityItem in activityItems )
	{
		if ( [activityItem isKindOfClass: [NSString class]] )
			[strings addObject: activityItem];
		else if ( [activityItem isKindOfClass: [NSURL class]] )
			[strings addObject: [(NSURL*)activityItem absoluteString]];
	}
	
	NSMutableArray* linkIds = [NSMutableArray arrayWithCapacity: strings.count];
	NSRegularExpression* regex = [NSRegularExpression
																regularExpressionWithPattern: @"(?<=[http|https]?://shr.rs/)[0-9A-Za-z]+"
																options: 0
																error: NULL];
	for ( NSString* string in strings )
	{
		NSArray* matches = [regex matchesInString: string
																			options: 0
																				range: NSMakeRange(0, string.length)];
		for ( NSTextCheckingResult* match in matches )
		{
			NSString* substring = [string substringWithRange: match.range];			
			[linkIds addObject: substring];
		}
	}
	
	self.sharedLinkIds = linkIds;
}

@end
