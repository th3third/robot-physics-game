//
//  Pivot.m
//  chucktherobot
//
//  Created by Marshall on 09/01/2013.
//
//

#import "Pivot.h"

@implementation Pivot

+ (id) pivotWithBodyA: (Object *) bodyA
{
	return [[self alloc] initWithBodyA: bodyA];
}

- (id) init
{
    return [self initWithBodyA: nil];
}

- (id) initWithBodyA: (Object *) bodyA
{
	if ((self = [super init]))
    {        
        // Initialize main variables.
		self.radius = 5.0f * [Director shared].scaleFactor.width;
		self.bodyA = bodyA;
		self.movable = NO;
		self.density = 1.0;
	}
    
	return self;
}

- (NSString *) serialize
{
    NSMutableString *code = [NSMutableString string];
    [code appendString: [super serialize]];
    
    //Body A
    [code appendString: @"\t<bodyA>"];
    [code appendString: [NSString stringWithFormat: @"%@", CFUUIDCreateString(kCFAllocatorDefault, self.bodyA.cfid)]];
    [code appendString: @"</bodyA>\n"];
    
    return code;
}

- (id) unserializeWithDict:(NSDictionary *)dict
{
	NSString *bodyACFIDString = [dict objectForKey: @"bodyA"];
	CFUUIDRef bodyACFID = CFUUIDCreateFromString(kCFAllocatorDefault, (CFStringRef)bodyACFIDString);
	
    int found = 0;
    for (Object *object in [[Director shared].stage objects])
    {
        if (object.cfid == bodyACFID)
        {
            self.bodyA = object;
            found++;
        }
        if (found >= 1)
        {
            break;
        }
    }
	
	if (!self.bodyA)
	{
		NSLog(@"CRITICAL ERROR: Could not find object for pivot: %@", self);
		return nil;
	}
	
	[self initWithBodyA: self.bodyA];
	
	NSString *cfidString = [dict objectForKey: @"cfid"];
	CFUUIDRef cfid = CFUUIDCreateFromString(kCFAllocatorDefault, (CFStringRef)cfidString);
	self.cfid = cfid;
	
	self.localAnchorA = b2Vec2([[dict objectForKey: @"localAnchorAX"] floatValue], [[dict objectForKey: @"localAnchorAY"] floatValue]);
	self.rotationForce = [[dict objectForKey: @"rotationForce"] floatValue];
	self.movable = [[dict objectForKey: @"movable"] boolValue];
	self.poppable = [[dict objectForKey: @"poppable"] boolValue];
	self.z = [[dict objectForKey: @"z"] intValue];
	
	return self;
}

- (void) createBox2DBody
{    
    if (self.attached)
		return;
	
	self.startPos = ccp(self.bodyA.centerPos.x, self.bodyA.centerPos.y);
	self.curPos = self.startPos;
	
    [super createBox2DBody];
	
	b2RevoluteJointDef revoluteJointDef;
	revoluteJointDef.collideConnected = NO;
	revoluteJointDef.bodyA = self.body;
	revoluteJointDef.bodyB = self.bodyA.body;
	revoluteJointDef.localAnchorA.Set(0, 0);
	revoluteJointDef.localAnchorB.Set(0, 0);
	self.world->CreateJoint(&revoluteJointDef);
	
	[self.bodyA attachObject: self];
    [self attachObject: self.bodyA];
	
	self.attached = YES;
}

@end