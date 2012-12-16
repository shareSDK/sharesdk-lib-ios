//
//  shareSDKDefines.h
//  shareSDK
//
//  Created by Jesse Curry on 5/15/11.
//  Copyright 2011 shareSDK, LLC. All rights reserved.
//

#pragma mark Logging

#if DEBUG
#define SS_LOG(...) NSLog(__VA_ARGS__)
#else
#define SS_LOG(...) /* */
#endif

#define SS_FORCE_STRING(x) [x isKindOfClass: [NSString class]] ? x : @""

#define CLASS_NAME NSStringFromClass([self class])