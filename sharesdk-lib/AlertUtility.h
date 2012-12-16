//
//  AlertUtility.h
//  ThingsToDo
//
//  Created by Jesse Curry on 8/27/10.
//  Copyright 2010 St. Pete Times. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AlertUtility : NSObject <UIAlertViewDelegate>
{
}

+ (void)showAlertWithTitle: (NSString*)title message: (NSString*)message;
+ (void)showConnectionErrorAlert;
+ (void)showDatabaseErrorAlert;
@end
