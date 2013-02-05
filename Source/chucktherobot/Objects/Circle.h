//
//  Circle.h
//  chucktherobot
//
//  Created by Marshall on 08/01/2013.
//
//

#import "Object.h"

@interface Circle : Object

@property float radius;
@property CCSprite *dropShadow;
@property float density;

+ (id) circleWithStart: (CGPoint) pos1 andRadius: (float) rad;
- (id) initWithStart: (CGPoint) pos1 andRadius: (float) rad;

@end
