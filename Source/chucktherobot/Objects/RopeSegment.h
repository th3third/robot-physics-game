//
//  RopeSegment.h
//  chucktherobot
//
//  Created by Marshall on 09/01/2013.
//
//

#import <Foundation/Foundation.h>
#import "Box2D.h"
#import "cocos2d.h"

@interface RopeSegment : NSObject

@property float angle;
@property b2Body *body;
@property CCSprite *bodyVisible;
@property CGPoint startPos;

@end
