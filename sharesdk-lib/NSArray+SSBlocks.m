//
//  NSArray+SSBlocks.m
//  sharesdk-lib
//
//  Created by Jesse Curry on 3/26/13.
//  Copyright (c) 2013 ShareSDK. All rights reserved.
//

#import "NSArray+SSBlocks.h"

@implementation NSArray (SSBlocks)
- (NSArray*)map: (SSCollectionMapHandler)block
{
  NSMutableArray* array = [NSMutableArray array];
  
  for( id obj in self )
  {
    id newObj = block(obj);
    [array addObject: newObj ? newObj : [NSNull null]];
  }
  
  return array;
}

@end
