//
//  SPImage+Draggable.m
//  picturewithsanta
//
//  Created by Marshall on 04/12/2012.
//
//

#import "SPImage+Draggable.h"

@implementation SPImage (Draggable)

- (void) makeDraggable
{
    [self addEventListener: @selector(onTouch:) atObject: self forType: SP_EVENT_TYPE_TOUCH];
}

- (void) makeStatic
{
    [self removeEventListener: @selector(onTouch:) atObject: self forType: SP_EVENT_TYPE_TOUCH];
}

- (void) onTouch: (SPTouchEvent *) event
{
    NSArray *touches = [[event touchesWithTarget: self andPhase: SPTouchPhaseMoved] allObjects];
    
    //Single touch.
    //This should only move the item.
    if (touches.count == 1)
    {
        SPTouch *touch = [touches objectAtIndex: 0];
        SPPoint *currentPos = [touch locationInSpace: self.parent];
        SPPoint *previousPos = [touch previousLocationInSpace: self.parent];
        
        self.x -= previousPos.x - currentPos.x;
        self.y -= previousPos.y - currentPos.y;
    }
    //Multitouch!
    //This should resize and scale the item.
    else if (touches.count == 2)
    {
        SPTouch *touch1 = [touches objectAtIndex: 0];
        SPPoint *currentPos1 = [touch1 locationInSpace: self.parent];
        SPPoint *previousPos1 = [touch1 previousLocationInSpace: self.parent];
        
        SPTouch *touch2 = [touches objectAtIndex: 1];
        SPPoint *currentPos2 = [touch2 locationInSpace: self.parent];
        SPPoint *previousPos2 = [touch2 previousLocationInSpace: self.parent];
        
        //Get the difference between the two points and scale the image accordingly.
        float distance1 = [SPPoint distanceFromPoint: currentPos1 toPoint: currentPos2];
        float distance2 = [SPPoint distanceFromPoint: previousPos1 toPoint: previousPos2];
        
        float scaleX = (([self scaleX] / distance2) * distance1);
        float scaleY = (([self scaleY] / distance2) * distance1);
        
        self.scaleX = scaleX;
        self.scaleY = scaleY;
    }
    else if (touches.count >= 3)
    {
        float averageCurrentX;
        float averageCurrentY;
        float averagePreviousX;
        float averagePreviousY;
        
        float midPointX = self.width / 2;
        float midPointY = self.height / 2;
        
        for (SPTouch *touch in touches)
        {
            averageCurrentX = [touch locationInSpace: self.parent].x;
            averageCurrentY = [touch locationInSpace: self.parent].y;
            
            averagePreviousX = [touch previousLocationInSpace: self.parent].x;
            averagePreviousY = [touch previousLocationInSpace: self.parent].y;
        }
        
        averageCurrentX = averageCurrentX / [touches count];
        averageCurrentY = averageCurrentY / [touches count];
        averagePreviousX = averagePreviousX / [touches count];
        averagePreviousY = averagePreviousY / [touches count];
        
        //Get the rotation from the center to the previous touch point.
        float prevAngle = atan2((averagePreviousX - midPointX), (averagePreviousY - midPointY));
        
        //Now get the rotation from the center to the current touch point.
        float curAngle = atan2((averageCurrentX - midPointX), (averageCurrentY - midPointY));
        
        //See how much they've changed and rotate accordingly.
        float angleDiff = prevAngle - curAngle;
        
        self.rotation += angleDiff;
    }
}

@end
