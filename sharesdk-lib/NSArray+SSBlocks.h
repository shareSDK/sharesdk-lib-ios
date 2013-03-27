//
//  NSArray+SSBlocks.h
//  sharesdk-lib
//
//  Created by Jesse Curry on 3/26/13.
//  Copyright (c) 2013 ShareSDK. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef id (^SSCollectionMapHandler)(id obj);

@interface NSArray (SSBlocks)
- (NSArray*)map: (SSCollectionMapHandler)block;
@end
