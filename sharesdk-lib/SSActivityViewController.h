//
//  SSActivityViewController.h
//  Analytics
//
//  Created by Jesse Curry on 12/1/12.
//
//

#import <UIKit/UIKit.h>

typedef enum _LinkShorteningBehavior {
	LinkShorteningBehaviorNever,
	LinkShorteningBehaviorAutomatic,
	LinkShorteningBehaviorAlways,
	LinkShorteningBehaviorCount
} LinkShorteningBehavior;
typedef void (^SSLinkReplacementHandler)(NSString* shortenedText);

@interface SSActivityViewController : UIActivityViewController
+ (void)setLinkShorteningBehavior: (LinkShorteningBehavior)linkShorteningBehavior;
+ (void)shortenLinksIfNeeded: (NSString*)text
			 withCompletionHandler: (SSLinkReplacementHandler)completionHandler;
@end
