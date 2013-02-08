//
//  Pivot.h
//  chucktherobot
//
//  Created by Marshall on 09/01/2013.
//
//

#import "Circle.h"

@interface Pivot : Circle

@property Object *bodyA;
@property b2Joint *joint;
@property b2Vec2 localAnchorA;
@property bool attached;

+ (id) pivotWithBodyA: (Object *) bodyA;
- (id) initWithBodyA: (Object *) bodyA;

@end
