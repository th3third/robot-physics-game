//
//  Rope.h
//  chucktherobot
//
//  Created by Marshall on 07/01/2013.
//
//

#import "Object.h"
#import "VRope.h"

@interface Rope : Object
{
    NSMutableArray *segments;
    float ropeLength;
    float ropeWidth;
}

@property Object *bodyA;
@property Object *bodyB;
@property b2Vec2 localAnchorA;
@property b2Vec2 localAnchorB;
@property CGPoint midPoint;
@property float maxLength;

+ (id) ropeWithBodyA: (Object *) bodyA andBodyB: (Object *) bodyB;
+ (id) ropeWithBodyA: (Object *) bodyA andBodyB: (Object *) bodyB andTouches: (NSArray *) touches;
- (id) initWithBodyA: (Object *) bodyA andBodyB: (Object *) bodyB;

@end
