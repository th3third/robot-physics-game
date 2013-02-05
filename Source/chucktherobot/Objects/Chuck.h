//
//  Chuck.h
//  Chuck the Robot
//
//  Created by Marshall on 03/01/2013.
//
//

#import "Object.h"

@interface Chuck : Object
{    
    b2Body *head;
    b2Body *torso1;
    b2Body *upperArmL;
    b2Body *upperArmR;
    b2Body *upperLegL;
    b2Body *upperLegR;
	b2Joint *neckJoint;
    NSMutableArray *bodyParts;
	bool hurt;
	float hurtDuration;
	float hurtCooldown;
    float partScale;
	float previousForceAvg;
    
    @public
    float height;
    float width;
    float armHeight;
    float armWidth;
    float legHeight;
    float legWidth;
    float torsoHeight;
    float torsoWidth;
    float headHeight;
    float headWidth;
}

+ (id) chuckWithPos: (CGPoint) pos;
- (id) initWithPos: (CGPoint) pos;

@end
