//
//  Rope.m
//  chucktherobot
//
//  Created by Marshall on 07/01/2013.
//
//

#import "Rope.h"
#import "Director.h"
#import "RopeSegment.h"
#import "TouchEvent.h"

@implementation Rope

+ (id) ropeWithBodyA: (Object *) bodyA andBodyB: (Object *) bodyB
{
	return [[self alloc] initWithBodyA: bodyA andBodyB: bodyB];
}

+ (id) ropeWithBodyA: (Object *) bodyA andBodyB: (Object *) bodyB andTouches: (NSArray *) touches
{
	return [[self alloc] initWithBodyA: bodyA andBodyB: bodyB andTouches: touches];
}

- (id) init
{
    return [self initWithBodyA: nil andBodyB: nil];
}

- (id) initWithBodyA: (Object *) bodyA andBodyB: (Object *) bodyB
{
	return [self initWithBodyA: bodyA andBodyB: bodyB andTouches: nil];
}

- (id) initWithBodyA: (Object *) bodyA andBodyB: (Object *) bodyB andTouches: (NSArray *) touches
{    
	if ((self = [super init]))
    {
        if (bodyA == bodyB)
        {
            [debug log: @"You can't attach a rope to the same object."];
            return NULL;
        }
			
        // Initialize main variables.
        ropeLength = (0.25 * [Director shared].scaleFactor.width) / [Director shared].scaleFactor.width;
        ropeWidth = 0.05 * [Director shared].scaleFactor.width;
        self.bodyA = bodyA;
        self.bodyB = bodyB;
        self.localAnchorA = b2Vec2(0, 0);
        self.localAnchorB = b2Vec2(0, 0);
		
        segments = [NSMutableArray array];
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
    
    //Max length
    [code appendString: @"\t<maxLength>"];
    [code appendString: [NSString stringWithFormat: @"%f", self.maxLength]];
    [code appendString: @"</maxLength>\n"];
    
    return code;
}

- (id) unserializeWithDict:(NSDictionary *)dict
{
	NSString *bodyACFIDString = [dict objectForKey: @"bodyA"];
	CFUUIDRef bodyACFID = CFUUIDCreateFromString(kCFAllocatorDefault, (CFStringRef)bodyACFIDString);
	
	NSString *bodyBCFIDString = [dict objectForKey: @"bodyB"];
	CFUUIDRef bodyBCFID = CFUUIDCreateFromString(kCFAllocatorDefault, (CFStringRef)bodyBCFIDString);
	
    Object *obj1;
    Object *obj2;
    int found = 0;
    for (Object *object in [[Director shared].stage objects])
    {
        if (object.cfid == bodyACFID)
        {
            obj1 = object;
            self.bodyA = object;
            found++;
        }
        else if (object.cfid == bodyBCFID)
        {
            obj2 = object;
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
		NSLog(@"CRITICAL ERROR: Could not find both objects for ends of rope: %@", self);
		return nil;
	}
	
	self.localAnchorA = b2Vec2([[dict objectForKey: @"localAnchorAX"] floatValue], [[dict objectForKey: @"localAnchorAY"] floatValue]);
	self.localAnchorB = b2Vec2([[dict objectForKey: @"localAnchorBX"] floatValue], [[dict objectForKey: @"localAnchorBY"] floatValue]);
	self.maxLength = [[dict objectForKey: @"maxLength"] floatValue];
	
	[self initWithBodyA: self.bodyA andBodyB: self.bodyB];
	
	return self;
}

- (void) tick:(ccTime)dt
{
	if (self.alive)
	{
		CGFloat dx = (self.bodyA.body->GetPosition().x * PTM_RATIO) - (self.bodyB.body->GetPosition().x * PTM_RATIO);
		CGFloat dy = (self.bodyA.body->GetPosition().y * PTM_RATIO) - (self.bodyB.body->GetPosition().y * PTM_RATIO);
		float distance = sqrt(dx*dx + dy*dy);
		
		if (distance > self.maxLength * 2)
		{
			b2Vec2 aLinVel = self.bodyA.body->GetLinearVelocity();
			b2Vec2 bLinVel = self.bodyB.body->GetLinearVelocity();
			
			self.bodyA.body->SetLinearVelocity(b2Vec2((-aLinVel.x * 0.5), -aLinVel.y * 0.5));
			self.bodyB.body->SetLinearVelocity(b2Vec2(-bLinVel.x * 0.5, -bLinVel.y * 0.5));
		}
		
		[self createVisibleBody];
	}
}

- (void) display
{
	[super display];
}

- (void) reset
{
	for (RopeSegment *seg in segments)
    {
		if (seg.body)
		{
			seg.body->SetActive(YES);
			seg.body->SetLinearVelocity(b2Vec2(0, 0));
		}
        
		if (seg.bodyVisible)
			seg.bodyVisible.visible = YES;
    }
	
    [self recalcPositions];
    [self createVisibleBody];
    self.alive = YES;
}

- (void) pop
{	
	for (RopeSegment *seg in segments)
    {
		seg.body->SetActive(NO);
        seg.bodyVisible.visible = NO;
    }

	self.alive = NO;
}

- (void) remove
{
    for (RopeSegment *seg in segments)
    {
		if (seg.body)
			self.world->DestroyBody(seg.body);
        
		if (seg.bodyVisible)
			[seg.bodyVisible removeFromParentAndCleanup: YES];
    }
    
	[[Director shared].stage.objects removeObject: self];
}

- (void) createBox2DBody
{
    //Clear the current body.
    if (self.body)
        self.world->DestroyBody(self.body);
    
	self.startPos = self.bodyA.centerPos;
	self.curPos = self.startPos;
	
	CGFloat dx = self.bodyB.centerPos.x - self.bodyA.centerPos.x;
	CGFloat dy = self.bodyB.centerPos.y - self.bodyA.centerPos.y;
	float d1 = sqrt(dx*dx + dy*dy);
	
	self.maxLength = ((d1) / 2) / [Director shared].scaleFactor.width;
	
    //Find the bodies that we need to attach the rope to.
    b2Body *bodyA;
    b2Body *bodyB;
    Object *obj1;
    Object *obj2;
    int found = 0;
    for (Object *object in [[Director shared].stage objects])
    {
        if (object.cfid == self.bodyA.cfid)
        {
            obj1 = object;
            bodyA = object.body;
            found++;
        }
        else if (object.cfid == self.bodyB.cfid)
        {
            obj2 = object;
            bodyB = object.body;
            found++;
        }
        if (found >= 2)
        {
            break;
        }
    }
    
    if (!bodyA || !bodyB)
    {
        NSLog(@"WARNING: Could not find all bodies for rope %@! Was a dependent body removed?", self);
        return;
    }
    
    //Create the rope segments.
    //Body common properties.
    b2BodyDef bodyDef;
    bodyDef.type = b2_dynamicBody;
    b2FixtureDef fixtureDef;
    fixtureDef.density = 1;
    fixtureDef.friction = 0.5;
    fixtureDef.restitution = 0.2;
	fixtureDef.isSensor = YES;
    b2PolygonShape polyShape;
    polyShape.SetAsBox(ropeLength, 0.1);
    fixtureDef.shape = &polyShape;
    
    //Joint common properties.
    b2RevoluteJointDef jointDef;
    jointDef.localAnchorA.Set(ropeLength, 0);
    jointDef.localAnchorB.Set(-ropeLength, 0);
    jointDef.collideConnected = NO;
    //revJointDef.maxMotorTorque = 1.0f;
    //revJointDef.enableMotor = YES;
    
    //Create the first link.
    b2Body *link;
    
    jointDef.bodyA = bodyA;
    
    //Create the multiple link bodies.
    int totalSegments = (self.maxLength / PTM_RATIO) / ropeLength;
    
    float atan2Angle;
    float cosAngle;
    float sinAngle;
    
    dx = self.bodyB.centerPos.x - self.bodyA.centerPos.x;
	dy = self.bodyB.centerPos.y - self.bodyA.centerPos.y;
    atan2Angle = atan2(dy, dx);
    cosAngle = cos(atan2Angle);
    sinAngle = sin(atan2Angle);
	
    b2Body *newLink;
    for (int i = 0; i < totalSegments; i++)
    {                
        //NSLog(@"Angle: %f, cos: %f, sin: %f", CC_RADIANS_TO_DEGREES(atan2Angle), cosAngle, sinAngle);
        
        bodyDef.position.Set(((self.bodyA.centerPos.x / PTM_RATIO) + (ropeLength * 2 * cosAngle) * (i)) / [Director shared].scaleFactor.width, ((self.bodyA.centerPos.y / PTM_RATIO) + (ropeLength * 2 * sinAngle) * (i)) / [Director shared].scaleFactor.width);
        //NSLog(@"%f, %f", bodyDef.position.x, bodyDef.position.y);
        bodyDef.angle = atan2Angle;
        
        if (i == 0)
        {
            bodyDef.position = bodyA->GetPosition();
            jointDef.localAnchorA.Set(0, 0);
            jointDef.bodyB = newLink;
        }
        else
        {
            jointDef.localAnchorA.Set(ropeLength, 0);
            jointDef.localAnchorB.Set(-ropeLength, 0);
            jointDef.bodyA = link; 
        }
        
        newLink = [self createSegment: bodyDef withFixtureDef: fixtureDef];
        jointDef.bodyB = newLink;
		RopeSegment *seg = [segments objectAtIndex: i];
        seg.joint = self.world->CreateJoint(&jointDef);
        
        link = newLink;
    }
    
    //Create the final link.
    jointDef.bodyA = link;
    jointDef.bodyB = bodyB;
    jointDef.localAnchorB.Set(0, 0);
    RopeSegment *seg = [segments objectAtIndex: [segments count] - 1];
	seg.joint = self.world->CreateJoint(&jointDef);
	[self recalcPositions];
}

- (void) createVisibleBody
{
    CCSprite *newSprite;
    for (RopeSegment *part in segments)
    {
        if (part)
        {
            newSprite = part.bodyVisible;
			newSprite.visible = YES;
            newSprite.position = ccp(((part.body->GetPosition().x * PTM_RATIO) * [Director shared].scaleFactor.width), ((part.body->GetPosition().y * PTM_RATIO) * [Director shared].scaleFactor.width));
            newSprite.rotation = -CC_RADIANS_TO_DEGREES(part.body->GetAngle());
            newSprite.anchorPoint = ccp(0.5, 0.5);
            
            if (!newSprite.parent)
            {
                [self addChild: newSprite];
            }
        }
    }
}

- (void) recalcPositions
{    
    //Find the bodies that we need to attach the rope to.
    b2Body *bodyA = self.bodyA.body;
    b2Body *bodyB = self.bodyB.body;
    
    if (!bodyA || !bodyB)
    {
        NSLog(@"WARNING: Could not find all bodies for rope %@! Was a dependent body removed?", self);
        return;
    }
    
    float dy;
    float dx;
    float atan2Angle;
    float cosAngle;
    float sinAngle;
    
    for (int i = 0; i < [segments count]; i++)
    {
		RopeSegment *seg = [segments objectAtIndex: i];
		
		dx = self.bodyB.centerPos.x - self.bodyA.centerPos.x;
		dy = self.bodyB.centerPos.y - self.bodyA.centerPos.y;

		atan2Angle = atan2(dy, dx);
		cosAngle = cos(atan2Angle);
		sinAngle = sin(atan2Angle);
		
		seg.body->SetLinearVelocity(b2Vec2(0, 0));
        seg.body->SetAngularVelocity(0);
        seg.body->SetTransform(b2Vec2((seg.startPos.x) / PTM_RATIO + seg.body->GetLocalCenter().x, (seg.startPos.y) / PTM_RATIO + seg.body->GetLocalCenter().y), seg.angle);
    }
}

- (b2Body *) createSegment: (b2BodyDef) bodyDef withFixtureDef: (b2FixtureDef) fixtureDef
{
    b2Body *newLink = self.world->CreateBody(&bodyDef);
    newLink->CreateFixture(&fixtureDef);
	
	float cosAngle = cos(bodyDef.angle);
	float sinAngle = sin(bodyDef.angle);
	
    RopeSegment *ropeSeg = [[RopeSegment alloc] init];
    ropeSeg.bodyVisible = [CCSprite spriteWithFile: @"Media/Objects/rope.jpg"];
    ropeSeg.bodyVisible.scaleX = ((ropeLength * PTM_RATIO) * [Director shared].scaleFactor.width) * 2.25 / ropeSeg.bodyVisible.contentSize.width;
    ropeSeg.bodyVisible.scaleY = ((ropeWidth * PTM_RATIO)) * 2 / ropeSeg.bodyVisible.contentSize.height;
    ropeSeg.body = newLink;
    ropeSeg.startPos = CGPointMake((bodyDef.position.x + (ropeLength * 2 * cosAngle)) * PTM_RATIO, (bodyDef.position.y + (ropeLength * 2 * sinAngle)) * PTM_RATIO);
    //ropeSeg.curPos = ropeSeg.startPos;
    ropeSeg.angle = bodyDef.angle;
    [segments addObject: ropeSeg];
    
    return newLink;
}


@end
