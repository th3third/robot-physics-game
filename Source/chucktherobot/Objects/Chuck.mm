//
//  Chuck.m
//  Chuck the Robot
//
//  Created by Marshall on 03/01/2013.
//
//

#import "Chuck.h"
#import "BodyPart.h"

@implementation Chuck

// ----------Initialization and deallocation
//------------------------------------------
+ (id) chuckWithPos: (CGPoint) pos
{
	return [[self alloc] initWithPos: pos];
}
 
- (id) initWithPos: (CGPoint) pos
{
	if ((self = [super init]))
    {
        // Initialize man variables
        self.startPos = pos;
		self.curPos = self.startPos;
        
        //Widths and heights
        partScale = 1.0f;
        width = 30 * [Director shared].scaleFactor.width;
        height = 40 * [Director shared].scaleFactor.height;
        
        armWidth = width * 0.165;
        armHeight = height * 0.225;
        legWidth = width * 0.195;
        legHeight = height * 0.165;
        torsoWidth = width * 0.30;
        torsoHeight = height * 0.165;
        headWidth = width * 0.33;
        headHeight = height * 0.20;
		
		//Hit sounds.
		self.hitSounds = 9;
		
		hurtDuration = 1.0;
    }
    
	return self;
}

- (id) unserializeWithDict: (NSDictionary *) dict
{
	[self initWithPos: ccp([[dict objectForKey: @"startPosX"] floatValue] * [Director shared].scaleFactor.width, [[dict objectForKey: @"startPosY"] floatValue] * [Director shared].scaleFactor.width)];
	[super unserializeWithDict: dict];
	
	return self;
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
    if (!self.body)
		return;
	
	//[self remove];
	[self moveToPoint: self.startPos];
    
	self.body->SetLinearVelocity(b2Vec2(0, 0));
	
    head->SetLinearVelocity(b2Vec2(0, 0));
    torso1->SetLinearVelocity(b2Vec2(0, 0));
    upperArmL->SetLinearVelocity(b2Vec2(0, 0));
    upperArmR->SetLinearVelocity(b2Vec2(0, 0));
    upperLegL->SetLinearVelocity(b2Vec2(0, 0));
    upperLegR->SetLinearVelocity(b2Vec2(0, 0));
	
	head->SetAngularVelocity(0);
	torso1->SetAngularVelocity(0);
	upperArmL->SetAngularVelocity(0);
	upperArmR->SetAngularVelocity(0);
	upperLegL->SetAngularVelocity(0);
	upperLegR->SetAngularVelocity(0);
	
	self.alive = YES;
    [self createVisibleBody];
}

- (void) remove
{
	if (head)
		self.world->DestroyBody(head);
    
	if (torso1)
		self.world->DestroyBody(torso1);
    
	if (upperArmL)
		self.world->DestroyBody(upperArmL);
    
	if (upperArmR)
		self.world->DestroyBody(upperArmR);
    
	if (upperLegL)
		self.world->DestroyBody(upperLegL);
    
	if (upperLegR)
		self.world->DestroyBody(upperLegR);
    
    [self.bodyVisible removeFromParentAndCleanup: YES];
    
    for (BodyPart *part in bodyParts)
    {
        [part.sprite removeFromParentAndCleanup: YES];
    }
}

- (void) tick:(ccTime)dt
{
	if (self->neckJoint)
	{
		b2Vec2 reactionForce;
		reactionForce = self->neckJoint->GetReactionForce(dt);
		float avgForce = ((reactionForce.x + reactionForce.y) / 2);
		
		if (avgForce < 0)
			avgForce *= -1;
		
		float difference = previousForceAvg - avgForce;
		if (difference < 0)
			difference *= -1;
		
		if ((difference) > 0.001 && !hurt)
		{
			hurt = YES;
			hurtCooldown = hurtDuration;
			[self hit];
		}
		else if (hurt)
		{
			if (hurtCooldown > 0)
				hurtCooldown -= dt;
			
			else if (hurtCooldown <= 0)
			{
				hurt = NO;
			}
		}
		
		previousForceAvg = avgForce;
	}
	
    if (self.body && self.body->IsAwake())
        [self createVisibleBody];
}

- (void) hit
{
	if (self.hitSoundPlaying)
		[[SimpleAudioEngine sharedEngine] stopEffect: self.hitSoundPlaying];
	
	self.hitSoundPlaying = [[SimpleAudioEngine sharedEngine] playEffect: [NSString stringWithFormat: @"Media/Audio/general/chuck_hit/chuck_hit%d.caf", arc4random() % self.hitSounds]];
}

- (void) moveToPoint: (CGPoint) point
{
    float x = point.x - self.startPos.x;
    float y = point.y - self.startPos.y;

    [self moveBodyByX: x andY: y];
}

- (void) moveBodyByX:(float)x andY:(float)y
{
    self.curPos = ccp(self.curPos.x + x, self.curPos.y + y);
    self.startPos = ccp(self.startPos.x + x, self.startPos.y + y);

	for (BodyPart *part in bodyParts)
	{
		b2Body *body = part.body;

		if (part.body)
		{
			body->SetTransform(b2Vec2((part.startPos.x + x) / PTM_RATIO, (part.startPos.y + y) / PTM_RATIO), 0);
			part.startPos = ccp(part.startPos.x + x, part.startPos.y + y);
		}
	}
	
	//[self rotateAllPartsTo: self.rotationAngle];
	
	[self createVisibleBody];
}

- (void) rotateAllPartsTo: (float) angle
{
	if (!self->torso1)
		return;
	
	b2Vec2 torsoPos = self->torso1->GetPosition();
	torso1->SetTransform(b2Vec2(torso1->GetTransform().p.x, torso1->GetTransform().p.y), self.rotationAngle);
	
	for (BodyPart *part in bodyParts)
	{
		b2Body *body = part.body;
		
		if (part.body && part.body != torso1)
		{
			double distance = part.dx + part.dy;
			double nx, ny;
			
			if (part.body == head)
			{
				nx = cos(angle + CC_DEGREES_TO_RADIANS(90)) * distance;
				ny = sin(angle + CC_DEGREES_TO_RADIANS(90)) * distance;
				part.startPos = ccp((nx + torsoPos.x) * PTM_RATIO, (ny + torsoPos.y) * PTM_RATIO);
				body->SetTransform(b2Vec2((part.startPos.x) / PTM_RATIO, (part.startPos.y) / PTM_RATIO), self.rotationAngle);
			}
			else if (part.body == upperArmL || part.body == upperArmR)
			{
				nx = cos(angle) * distance;
				ny = sin(angle) * distance;
				part.startPos = ccp((nx + torsoPos.x) * PTM_RATIO, (ny + torsoPos.y) * PTM_RATIO);
				body->SetTransform(b2Vec2((part.startPos.x) / PTM_RATIO, (part.startPos.y) / PTM_RATIO), self.rotationAngle);
			}
			
			else if (part.body == upperLegL)
			{
				//distance += ((torsoWidth * 1.5) / PTM_RATIO);
				//nx = cos(angle + CC_DEGREES_TO_RADIANS(90)) * distance;
				//ny = sin(angle + CC_DEGREES_TO_RADIANS(90)) * distance;
				part.startPos = ccp((torsoPos.x + (legWidth / PTM_RATIO)) * PTM_RATIO, (torsoPos.y + (torsoHeight * 2) / PTM_RATIO) * PTM_RATIO);
				body->SetTransform(b2Vec2((part.startPos.x) / PTM_RATIO, (part.startPos.y) / PTM_RATIO), self.rotationAngle);
			}
			else if (part.body == upperLegR)
			{
				//distance += ((torsoWidth * 1.5) / PTM_RATIO);
				//nx = cos(angle + CC_DEGREES_TO_RADIANS(90)) * distance;
				//ny = sin(angle + CC_DEGREES_TO_RADIANS(90)) * distance;
				part.startPos = ccp((torsoPos.x  - (legWidth / PTM_RATIO)) * PTM_RATIO, (torsoPos.y + (torsoHeight * 2) / PTM_RATIO) * PTM_RATIO);
				body->SetTransform(b2Vec2((part.startPos.x) / PTM_RATIO, (part.startPos.y) / PTM_RATIO), self.rotationAngle);
			}

			/*float cosMulti = cos(angle);
			float sinMulti = sin(angle);
			
			CGFloat dx = (part.body->GetPosition().x * PTM_RATIO) - (torsoPos.x * PTM_RATIO);
			CGFloat dy = (part.body->GetPosition().y * PTM_RATIO) - (torsoPos.y * PTM_RATIO);
			float distance = sqrt(dx*dx + dy*dy);
			float atan2Angle = atan2(dy, dx);
			float cosAngle = cos(atan2Angle);
			float sinAngle = sin(atan2Angle);
		
			part.startPos = ccp((torsoPos.x * PTM_RATIO) + (cosAngle * (distance * cosMulti)), (torsoPos.y * PTM_RATIO) + (sinAngle * (distance * sinMulti)));
			body->SetTransform(b2Vec2((part.startPos.x) / PTM_RATIO, (part.startPos.y) / PTM_RATIO), self.rotationAngle);*/
		}
	}
	
	[self createVisibleBody];
}

// ----------Box2d body creation
//------------------------------------------
- (void) createBox2DBody
{
	if (self.body)
		return;
	
    // -------------------------
    // Bodies ------------------
    // -------------------------
    b2BodyDef bd;
    bd.type = b2_dynamicBody;
    b2PolygonShape box;
    b2FixtureDef fixtureDef;
    
    // Head ------
    box.SetAsBox(headWidth / PTM_RATIO, headHeight / PTM_RATIO);
    fixtureDef.shape = &box;
    fixtureDef.density = 0.16f;
    fixtureDef.friction = 0.12f;
    fixtureDef.restitution = 0.5f;
    bd.position.Set((self.curPos.x + width * .5) / PTM_RATIO, (self.curPos.y) / PTM_RATIO);
    head = self.world->CreateBody(&bd);//b2Body *head
    head->CreateFixture(&fixtureDef);
    head->SetSleepingAllowed(true);
    
    
    // Torso1 ----
    box.SetAsBox(torsoWidth / PTM_RATIO, torsoHeight / PTM_RATIO);
    fixtureDef.shape = &box;
    bd.position.Set((self.curPos.x + width * .5) / PTM_RATIO, ((self.curPos.y - headHeight * 1.8)) / PTM_RATIO);
    torso1 = self.world->CreateBody(&bd);
    torso1->CreateFixture(&fixtureDef);
    torso1->SetSleepingAllowed(true);
    
    // ARMS    
    // Left
    box.SetAsBox(armWidth / PTM_RATIO, armHeight / PTM_RATIO);
    fixtureDef.shape = &box;
    bd.position.Set((self.curPos.x + armWidth * 0.6) / PTM_RATIO, (self.curPos.y - headHeight * 1.8) / PTM_RATIO);
    upperArmL = self.world->CreateBody(&bd);
    upperArmL->CreateFixture(&fixtureDef);
    upperArmL->SetSleepingAllowed(true);
    
    // Right
    box.SetAsBox(armWidth / PTM_RATIO, armHeight / PTM_RATIO);
    fixtureDef.shape = &box;
    bd.position.Set((self.curPos.x + width * 1.0 - (armWidth * 0.6)) / PTM_RATIO, (self.curPos.y - headHeight * 1.8) / PTM_RATIO);
    upperArmR = self.world->CreateBody(&bd);
    upperArmR->CreateFixture(&fixtureDef);
    upperArmR->SetSleepingAllowed(true);    
    
    // LEGS
    // Left
    box.SetAsBox(legWidth / PTM_RATIO, legHeight / PTM_RATIO);
    fixtureDef.shape = &box;
    bd.position.Set((self.curPos.x + width * .36) / PTM_RATIO, (self.curPos.y - ((headHeight * 2) + torsoHeight * 1.75)) / PTM_RATIO);
    upperLegL = self.world->CreateBody(&bd);
    upperLegL->CreateFixture(&fixtureDef);
    upperLegL->SetSleepingAllowed(true);
    
    // Right
    box.SetAsBox(legWidth / PTM_RATIO, legHeight / PTM_RATIO);
    fixtureDef.shape = &box;
    bd.position.Set((self.curPos.x + width * .63) / PTM_RATIO, (self.curPos.y - ((headHeight * 2) + torsoHeight * 1.75)) / PTM_RATIO);
    upperLegR = self.world->CreateBody(&bd);
    upperLegR->CreateFixture(&fixtureDef);
    upperLegR->SetSleepingAllowed(true);    
    
    // -------------------------
    // Joints ------------------
    // -------------------------
    b2RevoluteJointDef jd;
    jd.enableLimit = true;
    
    // Head to shoulders
    jd.lowerAngle = -5.0f / (180.0f / M_PI);
    jd.upperAngle = 5.0f / (180.0f / M_PI);
    jd.Initialize(torso1, head, b2Vec2((self.curPos.x + headWidth) / PTM_RATIO, (self.curPos.y) / PTM_RATIO));
    self.world->CreateJoint(&jd);
    
    // Upper arm to shoulders
    // Left
    jd.lowerAngle = -15.0f / (180.0f / M_PI);
    jd.upperAngle = 15.0f / (180.0f / M_PI);
    jd.Initialize(torso1, upperArmL, b2Vec2((self.curPos.x + armWidth / 2) / PTM_RATIO, (self.curPos.y - headHeight * 1.8 + armHeight / 2) / PTM_RATIO));
    self.world->CreateJoint(&jd);
    // Right
    jd.lowerAngle = -15.0f / (180.0f / M_PI);
    jd.upperAngle = 15.0f / (180.0f / M_PI);
    jd.Initialize(torso1, upperArmR, b2Vec2((self.curPos.x + width * 1.0 - armWidth / 2) / PTM_RATIO, (self.curPos.y - headHeight * 1.8 + armHeight / 2) / PTM_RATIO));
    self.world->CreateJoint(&jd);
    
    // Torso to upper leg
    // Left
    jd.lowerAngle = -25.0f / (180.0f / M_PI);
    jd.upperAngle = 45.0f / (180.0f / M_PI);
    jd.Initialize(torso1, upperLegL, b2Vec2((self.curPos.x + width * .36) / PTM_RATIO, (self.curPos.y - headHeight * 1.8 - legHeight / 2) / PTM_RATIO));
    self->neckJoint = self.world->CreateJoint(&jd);
    // Right
    jd.lowerAngle = -45.0f / (180.0f / M_PI);
    jd.upperAngle = 25.0f / (180.0f / M_PI);
    jd.Initialize(torso1, upperLegR, b2Vec2((self.curPos.x + width * .63) / PTM_RATIO, (self.curPos.y - headHeight * 1.8 - legHeight / 2) / PTM_RATIO));
    self.world->CreateJoint(&jd);
    
    //Add all the bodies to the array so we can keep track of them.
    bodyParts = [NSMutableArray array];
    BodyPart *part;
	b2Vec2 startPosVec;
    
    //Head.
    part = [[BodyPart alloc] init];
    part.body = head;
    part.height = headHeight;
    part.width = headWidth;
    part.sprite = [CCSprite spriteWithFile: [NSString stringWithFormat: @"Media/Objects/bots/%@/chuck_head.png", [Director shared].botType]];
	part.spriteHurt = [CCSprite spriteWithFile: [NSString stringWithFormat: @"Media/Objects/bots/%@/chuck_head_hurt.png", [Director shared].botType]];
	part.sprite.scaleX = (part.width / (part.sprite.contentSize.width * 0.8)) * 2;
	part.sprite.scaleY = (part.height / part.sprite.contentSize.height) * 2;
	part.spriteHurt.scaleX = (part.width / (part.spriteHurt.contentSize.width * 0.8)) * 2;
	part.spriteHurt.scaleY = (part.height / part.spriteHurt.contentSize.height) * 2;
	startPosVec = part.body->GetPosition();
	part.startPos = ccp(startPosVec.x * PTM_RATIO, startPosVec.y * PTM_RATIO);
	part.dx = (part.body->GetPosition().x) - (torso1->GetPosition().x);
	part.dy = (part.body->GetPosition().y) - (torso1->GetPosition().y);
    [bodyParts addObject: part];
    
    //Torso
    part = [[BodyPart alloc] init];
    part.body = torso1;
    part.height = torsoHeight;
    part.width = torsoWidth;
    part.sprite = [CCSprite spriteWithFile: [NSString stringWithFormat: @"Media/Objects/bots/%@/chuck_torso.png", [Director shared].botType]];
	part.sprite.scaleX = (part.width / part.sprite.contentSize.width) * 2;
	part.sprite.scaleY = (part.height / part.sprite.contentSize.height) * 2;
	startPosVec = part.body->GetPosition();
	part.startPos = ccp(startPosVec.x * PTM_RATIO, startPosVec.y * PTM_RATIO);
	part.dx = (part.body->GetPosition().x) - (torso1->GetPosition().x);
	part.dy = (part.body->GetPosition().y) - (torso1->GetPosition().y);
    [bodyParts addObject: part];
    
    //Arm L
    part = [[BodyPart alloc] init];
    part.body = upperArmL;
    part.height = armHeight;
    part.width = armWidth;
    part.sprite = [CCSprite spriteWithFile: [NSString stringWithFormat: @"Media/Objects/bots/%@/chuck_left_arm.png", [Director shared].botType]];
	part.sprite.scaleX = (part.width / part.sprite.contentSize.width) * 2;
	part.sprite.scaleY = (part.height / part.sprite.contentSize.height) * 2;
	startPosVec = part.body->GetPosition();
	part.startPos = ccp(startPosVec.x * PTM_RATIO, startPosVec.y * PTM_RATIO);
	part.dx = (part.body->GetPosition().x) - (torso1->GetPosition().x);
	part.dy = (part.body->GetPosition().y) - (torso1->GetPosition().y);
    [bodyParts addObject: part];
    
    //Arm R
    part = [[BodyPart alloc] init];
    part.body = upperArmR;
    part.height = armHeight;
    part.width = armWidth;
    part.sprite = [CCSprite spriteWithFile: [NSString stringWithFormat: @"Media/Objects/bots/%@/chuck_right_arm.png", [Director shared].botType]];
	part.sprite.scaleX = (part.width / part.sprite.contentSize.width) * 2;
	part.sprite.scaleY = (part.height / part.sprite.contentSize.height) * 2;
	startPosVec = part.body->GetPosition();
	part.startPos = ccp(startPosVec.x * PTM_RATIO, startPosVec.y * PTM_RATIO);
	part.dx = (part.body->GetPosition().x) - (torso1->GetPosition().x);
	part.dy = (part.body->GetPosition().y) - (torso1->GetPosition().y);
    [bodyParts addObject: part];
    
    //Leg L
    part = [[BodyPart alloc] init];
    part.body = upperLegL;
    part.height = legHeight;
    part.width = legWidth;
    part.sprite = [CCSprite spriteWithFile: [NSString stringWithFormat: @"Media/Objects/bots/%@/chuck_left_leg.png", [Director shared].botType]];
	part.sprite.scaleX = (part.width / part.sprite.contentSize.width) * 2;
	part.sprite.scaleY = (part.height / part.sprite.contentSize.height) * 2;
	startPosVec = part.body->GetPosition();
	part.startPos = ccp(startPosVec.x * PTM_RATIO, startPosVec.y * PTM_RATIO);
	part.dx = (part.body->GetPosition().x) - (torso1->GetPosition().x);
	part.dy = (part.body->GetPosition().y) - (torso1->GetPosition().y);
    [bodyParts addObject: part];
    
    //Leg R
    part = [[BodyPart alloc] init];
    part.body = upperLegR;
    part.height = legHeight;
    part.width = legWidth;
    part.sprite = [CCSprite spriteWithFile: [NSString stringWithFormat: @"Media/Objects/bots/%@/chuck_right_leg.png", [Director shared].botType]];
	part.sprite.scaleX = (part.width / part.sprite.contentSize.width) * 2;
	part.sprite.scaleY = (part.height / part.sprite.contentSize.height) * 2;
	startPosVec = part.body->GetPosition();
	part.startPos = ccp(startPosVec.x * PTM_RATIO, startPosVec.y * PTM_RATIO);
	part.dx = (part.body->GetPosition().x) - (torso1->GetPosition().x);
	part.dy = (part.body->GetPosition().y) - (torso1->GetPosition().y);
    [bodyParts addObject: part];
    
    self.body = head;
}

- (void) createVisibleBody
{
    CCSprite *newSprite;
    for (BodyPart *part in bodyParts)
    {
        if (part)
        {
            if (!part.sprite.parent)
            {
                [self addChild: part.sprite];
            }
            
			if (part.spriteHurt)
			{
				if (!part.spriteHurt.parent)
				{
					[self addChild: part.spriteHurt];
				}
				
				if (hurt)
				{
					[part.sprite setOpacity: 0];
					[part.spriteHurt setOpacity: 255];
					newSprite = part.spriteHurt;
				}
				else
				{
					[part.sprite setOpacity: 255];
					[part.spriteHurt setOpacity: 0];
					newSprite = part.sprite;
				}
			}
            else
			{
				newSprite = part.sprite;
			}
			
			newSprite.position = ccp((part.body->GetPosition().x * PTM_RATIO), ((part.body->GetPosition().y * PTM_RATIO)));
            newSprite.rotation = -CC_RADIANS_TO_DEGREES(part.body->GetAngle());
            newSprite.anchorPoint = ccp(0.5, 0.5);  
        }
    }

    if (!self.bodyVisible.parent)
    {
		CCRenderTexture *rt = [CCRenderTexture renderTextureWithWidth: width * 2  height: height * 2];
		[rt beginWithClear: 1 g: 1 b: 1 a: 0.00];
		[rt end];
		
        self.bodyVisible = [CCSprite spriteWithTexture: rt.sprite.texture rect: CGRectMake(0, 0, width, height)];
        [self addChild: self.bodyVisible];
    }
    
    self.bodyVisible.position = ccp(self.curPos.x, self.curPos.y);
    self.bodyVisible.anchorPoint = ccp (0.0, 1.0);
    self.rotation = 0;
    
    //NSLog(@"%f %f", self.bodyVisible.boundingBox.origin.x, self.bodyVisible.boundingBox.origin.y);
}

- (void) wakeUp
{
    head->SetAwake(YES);
    torso1->SetAwake(YES);
    upperArmL->SetAwake(YES);
    upperArmR->SetAwake(YES);
    upperLegL->SetAwake(YES);
    upperLegR->SetAwake(YES);
}

#pragma mark GETTERS/SETTERS

- (void) setMovable:(bool)movable
{
	
}

- (void) setPoppable:(bool)poppable
{
	
}

- (void) setRotationAngle:(float)rotationAngle
{
	[self rotateAllPartsTo: rotationAngle];
	[super setRotationAngle: rotationAngle];
}

- (CGPoint) centerPos
{
	CGPoint position = ccp(self.bodyVisible.position.x + (self.bodyVisible.contentSize.width / 2 * self.bodyVisible.scaleX), self.bodyVisible.position.y - (self.bodyVisible.contentSize.height / 2.75 * self.bodyVisible.scaleY));
	
	return position;
}


@end
