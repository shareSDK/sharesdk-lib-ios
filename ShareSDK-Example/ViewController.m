//
//  ViewController.m
//  ShareSDK-Example
//
//  Created by Jesse Curry on 12/16/12.
//  Copyright (c) 2012 ShareSDK. All rights reserved.
//

#import "ViewController.h"

// Controllers
#import "ShareSDK.h"

#define SHARE_TEXT		@"Take a look at http://games.slashdot.org/story/13/03/27/0044216/bioshock-infinite-released"
#define SHARE_IMAGE		[UIImage imageNamed: @"Sharing.png"]

@interface ViewController ()
- (void)shareItems: (NSArray*)items;
@end

////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.title = NSLocalizedString(@"shareSDK", @"UIViewController Title");
}

#pragma mark - Actions
- (IBAction)shareText: (id)sender
{
	[SSActivityViewController shortenLinksIfNeeded: SHARE_TEXT
													 withCompletionHandler: ^(NSString* shortenedText) {
														 [self shareItems: @[shortenedText]];
													 }];
}

- (IBAction)shareImage: (id)sender
{
	[self shareItems: @[
	 SHARE_IMAGE
	]];
}

- (IBAction)shareMultiple: (id)sender
{
	[self shareItems: @[
	 SHARE_TEXT,
	 SHARE_IMAGE
	]];
}

#pragma mark - Private
- (void)shareItems: (NSArray*)activityItems
{
	if ( [activityItems isKindOfClass: [NSArray class]] )
	{
		NSArray* applicationActivities = nil;
		NSArray* excludedActivities = [NSArray arrayWithObjects:
									   // UIActivityTypePostToFacebook,
									   // UIActivityTypePostToTwitter,
									   // UIActivityTypePostToWeibo,
									   UIActivityTypeMessage,
									   UIActivityTypeMail,
									   UIActivityTypePrint,
									   UIActivityTypeCopyToPasteboard,
									   UIActivityTypeAssignToContact,
									   UIActivityTypeSaveToCameraRoll, nil];
		
		SSActivityViewController* avc = [[SSActivityViewController alloc]
										 initWithActivityItems: activityItems
										 applicationActivities: applicationActivities];
		avc.excludedActivityTypes = excludedActivities;
		avc.completionHandler = ^(NSString* activityType, BOOL completed) {
			if ( completed )
			{
				SS_LOG(@"[%@]shareItems: activity completion handler.", CLASS_NAME);
				UIAlertView* av = [[UIAlertView alloc]
								   initWithTitle: NSLocalizedString(@"shareSDK", @"AlertView Title")
								   message: [NSString stringWithFormat: @"Shared: %@", activityType]
								   delegate: nil
								   cancelButtonTitle: NSLocalizedString(@"Cool", @"")
								   otherButtonTitles: nil];
				[av show];
			}
		};
		
		[self presentViewController: avc
						   animated: YES
						 completion: NULL];
	}
	else
	{
		SS_LOG(@"[%@]shareItems - ERROR: did not pass an array", CLASS_NAME);
	}
}

@end
