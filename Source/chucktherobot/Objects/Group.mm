//
//  Group.m
//  chucktherobot
//
//  Created by Marshall on 16/01/2013.
//
//

#import "Group.h"

@implementation Group

- (id) init
{
    if (self = [super init])
    {
        self.objects = [NSMutableArray array];
    }
    
    return self;
}

- (void) addObject:(id)object
{
    if (![self.objects containsObject: object])
    {
        [self.objects addObject: object];
    }
}

- (void) removeObject:(id)object
{
    if ([self.objects containsObject: object])
    {
        [self.objects removeObject: object];
    }
}

@end
