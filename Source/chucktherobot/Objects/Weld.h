//
//  Weld.h
//  chucktherobot
//
//  Created by Marshall on 15/01/2013.
//
//

#import "Object.h"

@interface Weld : Object

@property Object *bodyA;
@property Object *bodyB;
@property b2Joint *joint;
@property b2Vec2 localAnchorA;
@property b2Vec2 localAnchorB;
@property bool welded;

+ (id) weldWithBodyA: (Object *) bodyA andBodyB: (Object *) bodyB;
- (id) initWithBodyA: (Object *) bodyA andBodyB: (Object *) bodyB;

@end
