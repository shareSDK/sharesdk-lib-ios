//
//  shareSDKConstants.h
//  shareSDK
//
//  Created by Jesse Curry on 5/15/11.
//  Copyright 2011 shareSDK, LLC. All rights reserved.
//

// Web Site Root
extern NSString* const kShareSDKWebServiceRoot;

typedef enum _ShareSDKService
{
	ShareSDKServiceNone,
	ShareSDKServiceExternal,
	ShareSDKServiceEmail,
	ShareSDKServiceSMS,
	// Legacy
	ShareSDKServiceFacebook,
	ShareSDKServiceTwitter,
	ShareSDKServiceCount
} ShareSDKService;

typedef enum _ShareSDKPresentationStyle {
	ShareSDKPresentationPopUpStyle,
	ShareSDKPresentationSplitStyle
} ShareSDKPresentationStyle;