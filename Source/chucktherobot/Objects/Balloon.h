//
//  Balloon.h
//  chucktherobot
//
//  Created by Marshall on 14/01/2013.
//
//

#import "Circle.h"

@interface Balloon : Circle

@property float lift;

+ (id) balloonWithStart: (CGPoint) pos1 andRadius: (float) rad;
- (id) initWithStart: (CGPoint) pos1 andRadius: (float) rad;

@end
