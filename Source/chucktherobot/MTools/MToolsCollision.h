//
//  MToolsCollision.h
//  Laser Wars
//
//  Created by Marshall on 05/11/2012.
//
//

#import <Foundation/Foundation.h>
#import "SPRectangle.h"

@interface MToolsCollision : NSObject

+ (bool) rectCollision: (SPRectangle *) rect1 rect2: (SPRectangle *) rect2;
+ (bool) lineCollision: (SPRectangle *) rect point1: (SPPoint *) point1 point2: (SPPoint *) point2;
+ (bool) pointInRectCollision: (SPRectangle *) rect point: (SPPoint *) point;

@end
