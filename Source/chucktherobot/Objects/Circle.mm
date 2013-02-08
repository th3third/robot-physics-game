//
//  Circle.m
//  chucktherobot
//
//  Created by Marshall on 08/01/2013.
//
//

#import "Circle.h"

@implementation Circle

+ (id) circleWithStart: (CGPoint) pos1 andRadius: (float) rad
{
    return [[self alloc] initWithStart: pos1 andRadius: rad];
}

- (id) initWithStart: (CGPoint) pos1 andRadius: (float) rad
{
    if ((self = [super init]))
    {
        // Initialize main variables.
        self.startPos = pos1;
        self.curPos = self.startPos;
		self.centerPos = self.curPos;
        self.radius = rad;
		self.density = 1.0f;
		self.rotationAngle = (arc4random() % 6) - 3.14; //rotation is random for circles. This gives it the appearance of a "different" texture.
	}
    
	return self;
}

- (void) remove
{
	[super remove];
	[self.dropShadow removeFromParentAndCleanup: YES];
}


- (id) copy
{
	Circle *copy = [[Circle alloc] initWithStart: ccp(self.startPos.x, self.startPos.y) andRadius: self.radius];
	[self copyVars: copy];
	
	return copy;
}

- (void) copyVars:(Object *)copy
{
	[super copyVars: copy];
}

- (void) display
{
	[super display];
	
	[self moveBodyByX: 0 andY: 0];
}

- (void) reset
{
	if (self.body)
    {
        self.body->SetActive(YES);
        self.alive = YES;
        self.body->SetLinearVelocity(b2Vec2(0, 0));
        self.body->SetAngularVelocity(0);
        self.body->SetTransform(b2Vec2((self.curPos.x)/PTM_RATIO, (self.curPos.y)/PTM_RATIO), self.rotationAngle);
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

- (NSString *) serialize
{
    NSMutableString *code = [NSMutableString string];
    [code appendString: [super serialize]];
    
    //Radius
    [code appendString: @"\t<radius>"];
    [code appendString: [NSString stringWithFormat: @"%f", self.radius / [Director shared].scaleFactor.width]];
    [code appendString: @"</radius>\n"];
    
    return code;
}

- (id) unserializeWithDict: (NSDictionary *) dict
{
	[self initWithStart: ccp([[dict objectForKey: @"startPosX"] floatValue] * [Director shared].scaleFactor.width, [[dict objectForKey: @"startPosY"] floatValue] * [Director shared].scaleFactor.width) andRadius: [[dict objectForKey: @"radius"] floatValue] * [Director shared].scaleFactor.width];
	[super unserializeWithDict: dict];
	
	return self;
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
    
    [self createVisibleBody];
}

- (void) createBox2DBody
{
    //Clear the current body.
    if (self.body)
	{
        self.world->DestroyBody(self.body);
	}
    
    b2BodyDef bodyDef;
    
    //This is a movable object.
    if (self.movable)
        bodyDef.type = b2_dynamicBody;
    else
        bodyDef.type = b2_staticBody;
    
    bodyDef.position.Set((self.curPos.x)/PTM_RATIO, (self.curPos.y)/PTM_RATIO);
    self.body = self.world->CreateBody(&bodyDef);
    
    b2CircleShape *circle = new b2CircleShape();
    circle->m_radius = self.radius/PTM_RATIO;
    
    b2FixtureDef fixtureDef;
    fixtureDef.shape = circle;
    fixtureDef.density = self.density;
    fixtureDef.friction = 0.3f;
	fixtureDef.restitution = self.restitution;
    
    self.body->CreateFixture(&fixtureDef);
}

- (void) createVisibleBody
{
	if (!self.body)
		return;
	
    if (!self.bodyVisible.parent || self.needToChangeTexture)
    {
		if (self.bodyVisible.parent)
			[self.bodyVisible removeFromParentAndCleanup: YES];
		
		self.dropShadow = [CCSprite spriteWithFile: @"Media/Objects/circle_drop_shadow.png"];
		[self addChild: self.dropShadow];
		
		if (self.restitution >= 0.5f)
		{
			self.bodyVisible = [CCSprite spriteWithFile: @"Media/Objects/circle_bouncy.png"];
		}
		else
			self.bodyVisible = [CCSprite spriteWithFile: @"Media/Objects/circle.png"];
		
		self.needToChangeTexture = NO;
        self.bodyVisible.anchorPoint = ccp(0.5, 0.5);
		[self tint];
        [self addChild: self.bodyVisible];
    }

    float newWidth = self.radius * 2;
    float newHeight = self.radius * 2;
    
    float startWidth = self.bodyVisible.contentSize.width;
    float startHeight = self.bodyVisible.contentSize.height;
    
    self.bodyVisible.scaleX = newWidth / startWidth;
    self.bodyVisible.scaleY = newHeight / startHeight;
    self.bodyVisible.position = ccp((self.body->GetPosition().x) * PTM_RATIO, (self.body->GetPosition().y) * PTM_RATIO);
    self.bodyVisible.rotation = -CC_RADIANS_TO_DEGREES(self.body->GetAngle());
	
	self.dropShadow.scaleX = newWidth / self.dropShadow.contentSize.width * 1.1;
	self.dropShadow.scaleY = newHeight / self.dropShadow.contentSize.height * 1.1;
    self.dropShadow.position = ccp(((self.body->GetPosition().x * PTM_RATIO)) + 2, ((self.body->GetPosition().y * PTM_RATIO) - 2));
    self.dropShadow.rotation = 0;
    self.dropShadow.anchorPoint = ccp(0.5, 0.5);
}

@synthesize rotationAngle = _rotationAngle;
- (void) setRotationAngle:(float) rotationAngle
{
	_rotationAngle = rotationAngle;
	[self reset];
}

@end
