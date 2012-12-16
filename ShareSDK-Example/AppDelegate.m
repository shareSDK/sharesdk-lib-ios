//
//  AppDelegate.m
//  ShareSDK-Example
//
//  Created by Jesse Curry on 12/16/12.
//  Copyright (c) 2012 ShareSDK. All rights reserved.
//

#import "AppDelegate.h"

// ShareSDK
#import "ShareSDK.h"

// Controllers
#import "ViewController.h"

#define SHARE_SDK_APP_ID	@"14de74045d33707fdbef31fc36f2afb545ad95cd"

@interface AppDelegate ()
- (void)configureAppearanceDefaults;
- (void)buildViewHierarchy;
@end

////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation AppDelegate

- (BOOL)application: (UIApplication*)application didFinishLaunchingWithOptions: (NSDictionary*)launchOptions
{
	[ShareSDK start: SHARE_SDK_APP_ID];
	
	[self configureAppearanceDefaults];
	[self buildViewHierarchy];
    
	return YES;
}

#pragma mark - Private
- (void)configureAppearanceDefaults
{
	[[UINavigationBar appearance] setTintColor: [UIColor darkGrayColor]];
}

- (void)buildViewHierarchy
{
	self.window = [[UIWindow alloc] initWithFrame: [[UIScreen mainScreen] bounds]];
    ViewController* viewController = [[ViewController alloc] init];
	UINavigationController* navController = [[UINavigationController alloc]
											 initWithRootViewController: viewController];
    self.window.rootViewController = navController;
	[self.window makeKeyAndVisible];
}

@end
