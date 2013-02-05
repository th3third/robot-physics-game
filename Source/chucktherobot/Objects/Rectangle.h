//
//  Rectangle.h
//  Chuck the Robot
//
//  Created by Marshall on 03/01/2013.
//
//

#import "Object.h"

@interface Rectangle : Object

@property (nonatomic) CGPoint endPos;
@property (nonatomic) CCSprite *dropShadow;

+ (id) rectangleWithStart: (CGPoint) pos1 andEnd: (CGPoint) pos2;
- (id) initWithStart: (CGPoint) pos1 andEnd: (CGPoint) pos2;

@end
