//
//  Motor.h
//  chucktherobot
//
//  Created by Marshall on 28/01/2013.
//
//

#import "Circle.h"

@interface Motor : Circle

@property Object *bodyA;
@property b2Vec2 localAnchorA;
@property bool attached;

+ (id) motorWithBody: (Object *) bodyA andForce: (float) force;
- (id) initWithBody: (Object *) bodyA andForce: (float) force;

@end
