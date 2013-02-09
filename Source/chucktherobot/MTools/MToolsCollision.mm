//
//  MToolsCollision.m
//  Laser Wars
//
//  Created by Marshall on 05/11/2012.
//
//

#import "MToolsCollision.h"

@implementation MToolsCollision

+ (bool) rectCollision: (SPRectangle *) rect1 rect2: (SPRectangle *) rect2
{
    /*int left1, left2;
    int right1, right2;
    int top1, top2;
    int bottom1, bottom2;
    
    left1 = rect1.x;
    left2 = rect2.x;
    right1 = rect1.x + rect1.width;
    right2 = rect2.x + rect2.width;
    top1 = rect1.y;
    top2 = rect2.y;
    bottom1 = rect1.y + rect1.height;
    bottom2 = rect2.y + rect2.height;
    
    if (bottom1 < top2)
        return NO;
    if (top1 > bottom2)
        return NO;
    
    if (right1 < left2)
        return NO;
    if (left1 > right2)
        return NO;
    
    return YES;*/
    
    if ([rect1 intersectsRectangle: rect2])
        return YES;
    
    return NO;
}

+ (bool) lineCollision: (SPRectangle *) rect point1: (SPPoint *) point1 point2: (SPPoint *) point2
{
    float denom = ((rect.y - rect.y + rect.height) * (point2.x - point1.x) -
                   (rect.x - rect.x + rect.width) * (point2.y - point1.y));
    
    if (denom == 0)
        return NO;
    
    float ua = (((rect.x - rect.x + rect.width) * (point1.y - point2.y)) -
                ((rect.y - rect.y + rect.height) * (point1.x - point2.x)));
    
    float ub = (((point2.x - point1.x) * (point1.y - rect.y)) -
                ((point2.y - point1.y) * (point1.x - rect.x)));
    
    if (ua < 0 || ua > 1 || ub < 0 || ub > 1)
        return NO;
    
    return YES;
}

+ (bool) pointInRectCollision: (SPRectangle *) rect point: (SPPoint *) point
{
    if ([rect containsPoint: point])
        return YES;
    
    return NO;
}

@end
