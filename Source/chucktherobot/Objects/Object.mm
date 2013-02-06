//
//  Object.m
//  Chuck the Robot
//
//  Created by Marshall on 03/01/2013.
//
//

#import "Object.h"
#import "Group.h"
#import "Objects.h"

@implementation Object

+ (Object *) object
{
    Object *object = [[Object alloc] init];
    
    return object;
}

- (id) init
{
    return [self initWithCFID: nil];
}

- (id) initWithCFID: (CFUUIDRef) newID
{
    if (self = [super init])
    {
        if (newID)
        {
            self.cfid = newID;
        }
        else if (!self.cfid)
        {
			self.cfid = CFUUIDCreate(kCFAllocatorDefault);
        }
		
		self.z = [[Director shared].stage.objects count] + 1;
        self.zOrder = self.z;
		self.restitution = 0.2;
        self.alive = YES;
		self.movable = YES;
		self.minimumSize = 4;
        
        if (![Director shared].world)
            NSLog(@"WARNING: No world obtained from Director when attempting to initialize object! Perhaps it has not been set?");
        else
            self.world = [Director shared].world;
    }
    
    return self;
}

- (id) copy
{
	Object *copy = [[Object alloc] init];
	[self copyVars: copy];
	
	return copy;
}

- (void) copyVars: (Object *) copy
{
	copy.restitution = self.restitution;
	copy.movable = self.movable;
	copy.poppable = self.poppable;
	copy.startPos = ccp(self.startPos.x, self.startPos.y);
	copy.curPos = ccp(self.curPos.x, self.curPos.y);
	copy.rotationAngle = self.rotationAngle;
	copy.rotationForce = self.rotationForce;
	copy.alive = self.alive;
	copy.type = self.type;
}

- (NSString *) serialize
{
    NSMutableString *code = [NSMutableString string];
	
    //CFID
	//We need to replace the lesser-than and greater-than characters with XML value compatible characters.
    [code appendString: @"\t<cfid>"];
    [code appendString: [NSString stringWithFormat: @"%@", CFUUIDCreateString(kCFAllocatorDefault, self.cfid)]];
    [code appendString: @"</cfid>\n"];
    
    //Starting position x
    [code appendString: @"\t<startPosX>"];
    [code appendString: [NSString stringWithFormat: @"%f", self.curPos.x / [Director shared].scaleFactor.width]];
    [code appendString: @"</startPosX>\n"];
    
    //Starting position y
    [code appendString: @"\t<startPosY>"];
    [code appendString: [NSString stringWithFormat: @"%f", self.curPos.y / [Director shared].scaleFactor.height]];
    [code appendString: @"</startPosY>\n"];
    
    //Rotation angle (in degrees)
    [code appendString: @"\t<rotationAngle>"];
    [code appendString: [NSString stringWithFormat: @"%f", self.rotationAngle]];
    [code appendString: @"</rotationAngle>\n"];
    
    //Rotation force
    [code appendString: @"\t<rotationForce>"];
    [code appendString: [NSString stringWithFormat: @"%f", self.rotationForce]];
    [code appendString: @"</rotationForce>\n"];
	
	//Restitution
    [code appendString: @"\t<restitution>"];
    [code appendString: [NSString stringWithFormat: @"%f", self.restitution]];
    [code appendString: @"</restitution>\n"];
    
    //Movable
    [code appendString: @"\t<movable>"];
    [code appendString: [NSString stringWithFormat: @"%d", self.movable]];
    [code appendString: @"</movable>\n"];
    
    //Poppable
    [code appendString: @"\t<poppable>"];
    [code appendString: [NSString stringWithFormat: @"%d", self.poppable]];
    [code appendString: @"</poppable>\n"];
    
    //z
    [code appendString: @"\t<z>"];
    [code appendString: [NSString stringWithFormat: @"%d", self.z]];
    [code appendString: @"</z>\n"];
    
    return code;
}

- (id) unserializeWithDict: (NSDictionary *) dict
{
	NSString *cfidString = [dict objectForKey: @"cfid"];
	CFUUIDRef cfid = CFUUIDCreateFromString(kCFAllocatorDefault, (CFStringRef)cfidString);
	self.cfid = cfid;
	
	self.movable = [[dict objectForKey: @"movable"] boolValue];
	self.poppable = [[dict objectForKey: @"poppable"] boolValue];
	self.rotationAngle = [[dict objectForKey: @"rotationAngle"] floatValue];
	self.rotationForce = [[dict objectForKey: @"rotationForce"] floatValue];
	self.restitution = [[dict objectForKey: @"restitution"] floatValue];
	self.z = [[dict objectForKey: @"z"] intValue];
	
	return self;
}

- (void) tick: (ccTime) dt
{
	if (self.alive)
		[self createVisibleBody];
}

- (void) attachObject:(Object *)object
{
    //If this object doesn't belong to any groups we need to create a new one just for it.
    if (!self.groups)
    {
        self.groups = [NSMutableArray array];
    }
    
    Group *group = [[Group alloc] init];
    [self.groups addObject: group];
    [group addObject: object];
    [group addObject: self];
}

- (void) pop
{
    if (self.poppable)
    {
        self.body->SetActive(NO);
        self.bodyVisible.visible = NO;
        self.alive = NO;
		
		NSMutableArray *objectsToPop = [NSMutableArray array];
		for (Object *object in [[Director shared].stage objects])
		{
			if ([object isKindOfClass: [Rope class]])
			{
				Rope *rope = object;
				if (rope.bodyA == self || rope.bodyB == self)
				{
					if (![objectsToPop containsObject: rope])
						[objectsToPop addObject: rope];
				}
			}
		}
		
		for (Object *object in objectsToPop)
		{
			[object pop];
		}
    }
}

- (void) remove
{
	//Check and make sure we didn't have any joints/ropes/etc attached to it. If we did, we need to remove those.
	//TODO: Weld cleanups.
	NSMutableArray *objectsToRemove = [NSMutableArray array];
	for (Object *object in [[Director shared].stage objects])
    {
		if ([object isKindOfClass: [Rope class]])
		{
			Rope *rope = object;
			if (rope.bodyA == self || rope.bodyB == self)
			{
				if (![objectsToRemove containsObject: rope])
					[objectsToRemove addObject: rope];
			}
		}
		else if ([object isKindOfClass: [Weld class]])
		{
			Weld *weld = object;
			if (weld.bodyA == self || weld.bodyB == self)
			{
				if (![objectsToRemove containsObject: weld])
					[objectsToRemove addObject: weld];
			}
		}
		else if ([object isKindOfClass: [Pivot class]])
		{
			Pivot *pivot = object;
			if (pivot.bodyA == self)
			{
				if (![objectsToRemove containsObject: pivot])
					[objectsToRemove addObject: pivot];
			}
		}
		else if ([object isKindOfClass: [Motor class]])
		{
			Motor *motor = object;
			if (motor.bodyA == self)
			{
				if (![objectsToRemove containsObject: motor])
					[objectsToRemove addObject: motor];
			}
		}
    }
	
	for (Object *object in objectsToRemove)
	{
		[object remove];
		[[Director shared].stage.objects removeObject: object];
	}
	
	if (self.body)
		self.world->DestroyBody(self.body);
    
	[self.bodyVisible removeFromParentAndCleanup: YES];
    self.alive = NO;
}

- (void) reset
{
    self.curPos = self.startPos;
    
    if (self.body)
    {
        self.body->SetActive(YES);
        self.body->SetLinearVelocity(b2Vec2(0, 0));
        self.body->SetAngularVelocity(0);
        self.alive = YES;
        self.body->SetTransform(b2Vec2(self.startPos.x / PTM_RATIO, self.startPos.y / PTM_RATIO), self.rotationAngle);
    }

    if (self.bodyVisible)
    {
        self.bodyVisible.visible = YES;
    }
	
	[self createVisibleBody];
}

- (void) moveToPoint: (CGPoint) point
{
    float x = point.x - self.startPos.x;
    float y = point.y - self.startPos.y;
    
    [self moveByX: x andY: y];
}

- (void) moveBodyByX: (float) x andY: (float) y
{
    self.curPos = ccp(self.curPos.x + x, self.curPos.y + y);
    self.startPos = ccp(self.startPos.x + x, self.startPos.y + y);
    
    if (self.body)
    {
        self.body->SetActive(YES);
        self.alive = YES;
        self.body->SetTransform(b2Vec2((self.curPos.x) / PTM_RATIO, (self.curPos.y) / PTM_RATIO), self.rotationAngle);
    }
    
    [self display];
}

- (void) moveByX: (float) x andY: (float) y
{
    NSMutableArray *objectsToMove = [NSMutableArray arrayWithObject: self];
    
    for (Group *group in self.groups)
    {
        for (Object *object in group.objects)
        {
            if (![objectsToMove containsObject: object])
            {
                [objectsToMove addObject: object];
            }
        }  
    }
    
    NSMutableArray *newObjects;
    bool addedNewObjects = NO;
    do
    {
        newObjects = [NSMutableArray array];
        addedNewObjects = NO;
        
        for (Object *object in objectsToMove)
        {
            if (object.groups)
            {
                for (Group *group in object.groups)
                {
                    for (Object *object2 in group.objects)
                    {
                        if (![objectsToMove containsObject: object2])
                        {
                            [newObjects addObject: object2];
                            addedNewObjects = YES;
                        }
                    }
                }
            }
        }
        
        [objectsToMove addObjectsFromArray: newObjects];
    }
    while (addedNewObjects);
    
    for (Object *object in objectsToMove)
    {
        [object moveBodyByX: x andY: y];
    }
}

- (float) widthAbs
{
    return 0;
}

- (float) heightAbs
{
    return 0;
}

- (void) createBox2DBody
{
    
}

- (void) createVisibleBody
{
    
}

- (void) wakeUp
{
    if (self.body)
        self.body->SetAwake(YES);
}

- (void) tint
{
	ccColor3B tintColor;
    
	if (!self.bodyVisible)
		return;
	
    if (self.poppable)
        tintColor = ccc3(255, 75, 75);
	else if (self.restitution > 0.2f)
		tintColor = ccc3(255, 255, 255);
    else if (self.movable)
		tintColor = ccc3(75, 150, 255);
	else
		tintColor = ccc3(51, 240, 110);
    
    self.bodyVisible.color = tintColor;
}

- (void) display
{
	//Create physic body.
	[self createBox2DBody];
	
	//Now create the visible body (visible to the player)
	[self createVisibleBody];
}

#pragma  mark GETTERS/SETTERS

- (CGPoint) centerPos
{
	return self.bodyVisible.position;
}


- (void) setRotationAngle:(float)rotationAngle
{
    _rotationAngle = rotationAngle;
    [self display];
}

- (void) setMovable:(bool)movable
{	
	_movable = movable;
	
	if (!self.body)
		return;
	
	[self tint];
	
	b2BodyType newBodyType;
	if (_movable)
		newBodyType = b2_dynamicBody;
	else
		newBodyType = b2_staticBody;
	
	self.body->SetType(newBodyType);
}

- (void) setPoppable:(bool)poppable
{
    _poppable = poppable;
	[self tint];
}

- (void) setRestitution:(float)restitution
{
	_restitution = restitution;
	
	if (!self.body)
		return;
	
	for (b2Fixture* fixture = self.body->GetFixtureList(); fixture; fixture = fixture->GetNext())
	{
		fixture->SetRestitution(_restitution);
	}
	self.needToChangeTexture = YES;
	[self tint];
	[self createVisibleBody];
}

- (void) setRotationForce:(float)rotationForce
{
	_rotationForce = rotationForce;
	
	if (!self.body)
		return;
}

- (void) setAlive:(bool)alive
{
    _alive = alive;
    
    if (self.body)
    {
        self.body->SetActive(alive);
    }
}

@end
