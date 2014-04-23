//
//  AlertUtility.m
//  ThingsToDo
//
//  Created by Jesse Curry on 8/27/10.
//  Copyright 2010 St. Pete Times. All rights reserved.
//

#import "AlertUtility.h"
#import "shareSDKDefines.h"

static BOOL alertVisible = NO;

////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation AlertUtility

+ (void)showAlertWithTitle: (NSString*)title message: (NSString*)message
{
	if ( !alertVisible )
	{
		UIAlertView* alertView = [[UIAlertView alloc] initWithTitle: title 
															message: message 
														   delegate: [AlertUtility class] 
												  cancelButtonTitle: NSLocalizedString(@"OK", @"") 
												  otherButtonTitles: nil];
		[alertView show];
		
		alertVisible = YES;
	}
	else
	{
		SS_LOG( @"Ignored alert: %@", title );
	}
}

+ (void)showConnectionErrorAlert
{
	[AlertUtility showAlertWithTitle: NSLocalizedString(@"Connection Error", @"") 
							 message: NSLocalizedString(@"There was a problem connecting to the server. Please make sure that you have an internet connection and try your request again.", @"")];
}

+ (void)showDatabaseErrorAlert
{
	[AlertUtility showAlertWithTitle: NSLocalizedString(@"Database Error", @"") 
							 message: NSLocalizedString(@"There was a problem loading the database. Please restart the application.", @"")];
}

#pragma mark -
#pragma mark UIAlertViewDelegate
+ (void)alertView: (UIAlertView*)alertView didDismissWithButtonIndex: (NSInteger)buttonIndex
{
	alertVisible = NO;
}

@end
