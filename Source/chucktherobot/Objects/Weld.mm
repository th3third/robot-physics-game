//
//  Weld.m
//  chucktherobot
//
//  Created by Marshall on 15/01/2013.
//
//

#import "Weld.h"

@implementation Weld

+ (id) weldWithBodyA: (Object *) bodyA andBodyB: (Object *) bodyB
{
	return [[self alloc] initWithBodyA: bodyA andBodyB: bodyB];
}

- (id) init
{
    return [self initWithBodyA: nil andBodyB: nil];
}

- (id) initWithBodyA: (Object *) bodyA andBodyB: (Object *) bodyB
{    
	if ((self = [super init]))
    {
        if (bodyA == bodyB)
        {
            [debug log: @"You can't attach a weld to the same object."];
            return NULL;
        }
        
        // Initialize main variables.
        self.bodyA = bodyA;
        self.bodyB = bodyB;
        self.welded = NO;
        self.localAnchorA = b2Vec2(0, 0);
        self.localAnchorB = b2Vec2(0, 0);
        
        self.curPos = self.startPos;
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
    
    //Body B
    [code appendString: @"\t<bodyB>"];
    [code appendString: [NSString stringWithFormat: @"%@", CFUUIDCreateString(kCFAllocatorDefault, self.bodyB.cfid)]];
    [code appendString: @"</bodyB>\n"];
    
    //Anchor A X
    [code appendString: @"\t<localAnchorAX>"];
    [code appendString: [NSString stringWithFormat: @"%f", self.localAnchorA.x]];
    [code appendString: @"</localAnchorAX>\n"];
    
    //Anchor A Y
    [code appendString: @"\t<localAnchorAY>"];
    [code appendString: [NSString stringWithFormat: @"%f", self.localAnchorA.y]];
    [code appendString: @"</localAnchorAY>\n"];
    
    //Anchor B X
    [code appendString: @"\t<localAnchorBX>"];
    [code appendString: [NSString stringWithFormat: @"%f", self.localAnchorB.x]];
    [code appendString: @"</localAnchorBX>\n"];
    
    //Anchor B Y
    [code appendString: @"\t<localAnchorBY>"];
    [code appendString: [NSString stringWithFormat: @"%f", self.localAnchorB.y]];
    [code appendString: @"</localAnchorBY>\n"];
    
    return code;
}

- (id) unserializeWithDict:(NSDictionary *)dict
{
	NSString *bodyACFIDString = [dict objectForKey: @"bodyA"];
	CFUUIDRef bodyACFID = CFUUIDCreateFromString(kCFAllocatorDefault, (CFStringRef)bodyACFIDString);
	
	NSString *bodyBCFIDString = [dict objectForKey: @"bodyB"];
	CFUUIDRef bodyBCFID = CFUUIDCreateFromString(kCFAllocatorDefault, (CFStringRef)bodyBCFIDString);
	
    int found = 0;
    for (Object *object in [[Director shared].stage objects])
    {		
        if (object.cfid == bodyACFID)
        {
            self.bodyA = object;
            found++;
        }
        if (object.cfid == bodyBCFID)
        {
            self.bodyB = object;
            found++;
        }
        if (found >= 2)
        {
            break;
        }
    }
	
	if (!self.bodyA || !self.bodyB)
	{
		NSLog(@"CRITICAL ERROR: Could not find both objects for ends of weld, only found %d: %@", found, self);
		return nil;
	}
	
	self.localAnchorA = b2Vec2([[dict objectForKey: @"localAnchorAX"] floatValue], [[dict objectForKey: @"localAnchorAY"] floatValue]);
	self.localAnchorB = b2Vec2([[dict objectForKey: @"localAnchorBX"] floatValue], [[dict objectForKey: @"localAnchorBY"] floatValue]);
	
	[self initWithBodyA: self.bodyA andBodyB: self.bodyB];
	
	return self;
}

- (void) createBox2DBody
{
    if (self.welded)
    {
        return;
    }
	
	 self.startPos = ccp(self.bodyA.body->GetPosition().x * PTM_RATIO, self.bodyA.body->GetPosition().y * PTM_RATIO);
    
    //Attach the two objects to each other by putting them in the "attached" array.
    [self.bodyA attachObject: self.bodyB];
    [self.bodyB attachObject: self.bodyA];
    
    b2WeldJointDef weldJointDef;
    weldJointDef.Initialize(self.bodyA.body, self.bodyB.body, self.bodyA.body->GetWorldCenter());
    self.world->CreateJoint(&weldJointDef);
    
    self.welded = YES;
}

@end
