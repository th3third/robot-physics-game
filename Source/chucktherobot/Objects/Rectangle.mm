//
//  Rectangle.m
//  Chuck the Robot
//
//  Created by Marshall on 03/01/2013.
//
//

#import "Rectangle.h"

@implementation Rectangle

+ (id) rectangleWithStart: (CGPoint) pos1 andEnd: (CGPoint) pos2
{
	return [[self alloc] initWithStart: pos1 andEnd: pos2];
}

- (id) init
{
    return [self initWithStart: ccp(0, 0) andEnd: ccp(1, 1)];
}

- (id) initWithStart: (CGPoint) pos1 andEnd: (CGPoint) pos2
{
	if ((self = [super init]))
    {
        // Initialize main variables.
        self.startPos = pos1;
        self.endPos = pos2;
        self.curPos = self.startPos;
		
		if (self.widthAbs < self.minimumSize)
		{
			_endPos.x = self.curPos.x + self.minimumSize;
		}
		
		if (self.heightAbs < self.minimumSize)
		{
			_endPos.y = self.curPos.y + self.minimumSize;
		}
	}
    
	return self;
}

- (void) remove
{
	[super remove];
	[self.dropShadow removeFromParentAndCleanup: YES];
}

- (NSString *) serialize
{
    NSMutableString *code = [NSMutableString string];
    [code appendString: [super serialize]];
    
    //Ending position x
    [code appendString: @"\t<endPosX>"];
    [code appendString: [NSString stringWithFormat: @"%f", self.endPos.x / [Director shared].scaleFactor.width]];
    [code appendString: @"</endPosX>\n"];
    
    //Ending position y
    [code appendString: @"\t<endPosY>"];
    [code appendString: [NSString stringWithFormat: @"%f", self.endPos.y / [Director shared].scaleFactor.height]];
    [code appendString: @"</endPosY>\n"];
    
    return code;
}

- (id) unserializeWithDict: (NSDictionary *) dict
{
	[self initWithStart: ccp([[dict objectForKey: @"startPosX"] floatValue] * [Director shared].scaleFactor.width, [[dict objectForKey: @"startPosY"] floatValue] * [Director shared].scaleFactor.width) andEnd: ccp([[dict objectForKey: @"endPosX"] floatValue] * [Director shared].scaleFactor.width, [[dict objectForKey: @"endPosY"] floatValue] * [Director shared].scaleFactor.width)];
	
	[super unserializeWithDict: dict];
	
	return self;
}

- (id) copy
{
	Rectangle *copy = [[Rectangle alloc] initWithStart: self.startPos andEnd: self.endPos];
	[self copyVars: copy];
	
	return copy;
}

- (void) copyVars:(Object *)copy
{
	[super copyVars: copy];
}

- (void) display
{
	//Create physic body.
	[self createBox2DBody];
	
	//Now create the visible body (visible to the player)
	[self createVisibleBody];
}

- (void) reset
{    
    //Create the physics body.
    float width = abs(self.endPos.x - self.curPos.x);
    float height = abs(self.endPos.y - self.curPos.y);
    
    if (self.body)
    {
        self.body->SetActive(YES);
        self.alive = YES;
        self.body->SetLinearVelocity(b2Vec2(0, 0));
        self.body->SetAngularVelocity(0);
        self.body->SetTransform(b2Vec2((self.curPos.x + width / 2)/PTM_RATIO, (self.curPos.y + height / 2)/PTM_RATIO), self.rotationAngle);
    }
    
	if (self.bodyVisible)
	{
		[self createVisibleBody];
		self.bodyVisible.visible = YES;
		self.dropShadow.visible = YES;
	}
}
- (void) pop
{
	if (self.poppable)
	{
		[super pop];
		self.dropShadow.visible = NO;
	}
}

- (void) moveToPoint:(CGPoint)point
{    
    float x = point.x - self.startPos.x;
    float y = point.y - self.startPos.y;
	
    [self moveByX: x andY: y];
}

- (void) moveBodyByX: (float) x andY: (float) y
{
    self.curPos = ccp(self.curPos.x + x, self.curPos.y + y);
    self.startPos = ccp(self.startPos.x + x, self.startPos.y + y);
    self.endPos = ccp(self.endPos.x + x, self.endPos.y + y);
    
    float width = abs(self.endPos.x - self.curPos.x);
    float height = abs(self.endPos.y - self.curPos.y);
    
    if (self.body)
    {
        self.body->SetActive(YES);
        self.alive = YES;
        self.body->SetTransform(b2Vec2((self.curPos.x + width / 2) / PTM_RATIO, (self.curPos.y + height / 2) / PTM_RATIO), self.rotationAngle);
    }
    
    [self createVisibleBody];
}

- (void) createBox2DBody
{
    //Clear the current body.
    if (self.body)
        self.world->DestroyBody(self.body);
    
    //Create the physics body.
    float width = abs(self.endPos.x - self.curPos.x);
    float height = abs(self.endPos.y - self.curPos.y);

    //Make sure that we have an area.
    if (width == 0)
        width++;
    if (height == 0)
        height++;
    
    b2BodyDef bodyDef;
    
    //This is a movable object.
    if (self.movable)
        bodyDef.type = b2_dynamicBody;
    else
        bodyDef.type = b2_staticBody;
    
    bodyDef.angle = self.rotationAngle;
    bodyDef.position.Set((self.curPos.x + width / 2)/PTM_RATIO, (self.curPos.y + height / 2)/PTM_RATIO);
    self.body = self.world->CreateBody(&bodyDef);
    
    b2PolygonShape rectangle;
    rectangle.SetAsBox(width/PTM_RATIO * 0.5, height/PTM_RATIO * 0.5);
    
    b2FixtureDef fixtureDef;
    fixtureDef.shape = &rectangle;
    fixtureDef.density = 1.0f;
    fixtureDef.friction = 0.3f;
	fixtureDef.restitution = self.restitution;
	
	ObjectUserData *newUserData = new ObjectUserData;
	newUserData->objectID = self;
	fixtureDef.userData = newUserData;
    
    self.body->CreateFixture(&fixtureDef);
}

- (void) createVisibleBody
{
	if (!self.body)
		return;
	
	float width = (self.endPos.x - self.curPos.x);
    float height = (self.endPos.y - self.curPos.y);
	
    if (!self.bodyVisible.parent || self.needToChangeTexture)
    {
		if (self.bodyVisible.parent)
			[self.bodyVisible removeFromParentAndCleanup: YES];
		
		if (!self.dropShadow.parent)
		{
			self.dropShadow = [CCSprite spriteWithFile: @"Media/Objects/rectangle_drop_shadow.png"];
			[self addChild: self.dropShadow];
		}
	
		if (self.restitution >= 0.5f)
		{
			self.bodyVisible = [CCSprite spriteWithFile: @"Media/Objects/bouncy.jpg"];
		}
		else
			self.bodyVisible = [CCSprite spriteWithFile: @"Media/Objects/rectangle.jpg"];
		
		self.needToChangeTexture = NO;
		
		[self addChild: self.bodyVisible];
		[self tint];
    }
	
	CGSize s = [CCDirector sharedDirector].winSize;
	
	[self.bodyVisible setTextureRect: CGRectMake(MIN(MAX(self.curPos.x, s.width), 0), MIN(MAX(self.curPos.y, s.height), 0), width, height) ];
    self.bodyVisible.position = ccp((self.body->GetPosition().x * PTM_RATIO), (self.body->GetPosition().y * PTM_RATIO));
    self.bodyVisible.rotation = -CC_RADIANS_TO_DEGREES(self.body->GetAngle());
    self.bodyVisible.anchorPoint = ccp(0.5, 0.5);
	
	float scaleX = ((self.bodyVisible.contentSize.width + 2) / self.dropShadow.contentSize.width);
	float scaleY = ((self.bodyVisible.contentSize.height + 2) / self.dropShadow.contentSize.height);
	self.dropShadow.scaleX = scaleX;
	self.dropShadow.scaleY = scaleY;
    self.dropShadow.position = ccp(((self.body->GetPosition().x * PTM_RATIO)) + 2, ((self.body->GetPosition().y * PTM_RATIO) - 2));
    self.dropShadow.rotation = -CC_RADIANS_TO_DEGREES(self.body->GetAngle());
    self.dropShadow.anchorPoint = ccp(0.5, 0.5);
	
    self.poppable = self.poppable;
}

- (float) widthAbs
{
    float width = abs(self.endPos.x - self.curPos.x);

    return width;
}

- (float) heightAbs
{
    float height = abs(self.endPos.y - self.curPos.y);
    
    return height;
}

- (void) setEndPos:(CGPoint)endPos
{
    //The new value x is going to be less than the start position.
    if (endPos.x < self.startPos.x)
    {
        self.curPos = ccp(endPos.x, self.curPos.y);
    }
    else
    {
        _endPos = ccp(endPos.x, self.endPos.y);
    }
    
    //The new value y is going to be less than the start position.
    if (endPos.y < self.startPos.y)
    {
        self.curPos = ccp(self.curPos.x, endPos.y);
    }
    else
    {
        _endPos = ccp(self.endPos.x, endPos.y);
    }
	
	if (self.widthAbs < self.minimumSize)
	{
		_endPos.x = self.curPos.x + self.minimumSize;
	}
	
	if (self.heightAbs < self.minimumSize)
	{
		_endPos.y = self.curPos.y + self.minimumSize;
	}
}

@synthesize rotationAngle = _rotationAngle;
- (void) setRotationAngle:(float) rotationAngle
{
	_rotationAngle = rotationAngle;
	[self reset];
}

@end
