//
//  CCMenuMT.m
//  chucktherobot
//
//  Created by Marshall on 07/01/2013.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "CCMenuMT.h"

#define kDefaultPadding 5

@implementation CCMenuMT

- (void) alignItemsTopRight
{
    [self alignItemsTopRightWithPadding: kDefaultPadding];
}

- (void) alignItemsTopRightWithPadding: (float) padding
{
    float width = -padding;
	CCMenuItem *item;
	CCARRAY_FOREACH(children_, item)
        width += item.contentSize.width * item.scaleX + padding;
    
	float x = self.contentSize.width / 2;
    
	CCARRAY_FOREACH(children_, item)
    {
		CGSize itemSize = item.contentSize;
        [item setAnchorPoint: ccp(1, 1)];
		[item setPosition: ccp(x - padding, self.contentSize.height / 2 - padding)];
		x -= itemSize.width * item.scaleX + padding;
	}
}

@end
