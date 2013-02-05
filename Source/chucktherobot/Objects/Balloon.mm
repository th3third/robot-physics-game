//
//  Balloon.m
//  chucktherobot
//
//  Created by Marshall on 14/01/2013.
//
//

#import "Balloon.h"

@implementation Balloon

+ (id) balloonWithStart: (CGPoint) pos1 andRadius: (float) rad
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
        self.radius = rad;
        self.lift = 25;
		self.radius = 20.0;
        self.movable = YES;
	}
    
	return self;
}

- (void) tick:(ccTime)dt
{
    [super tick: dt];
 
    if (![Director shared].paused)
    {
        self.body->ApplyForce(b2Vec2(0.0, self.lift * self.body->GetMass()),self.body->GetWorldCenter());
    }
}

- (NSString *) serialize
{
    NSMutableString *code = [NSMutableString string];
    [code appendString: [super serialize]];
    
    //Lift
    [code appendString: @"\t<lift>"];
    [code appendString: [NSString stringWithFormat: @"%f", self.lift]];
    [code appendString: @"</lift>\n"];
    
    return code;
}

- (id) unserializeWithDict:(NSDictionary *)dict
{
	[self initWithStart: ccp([[dict objectForKey: @"startPosX"] floatValue], [[dict objectForKey: @"startPosY"] floatValue]) andRadius: [[dict objectForKey: @"radius"] floatValue]];
	self.lift = [[dict objectForKey: @"lift"] floatValue];
	[super unserializeWithDict: dict];
	
	return self;
}

- (void) createVisibleBody
{
	if (!self.body)
		return;
	
    if (!self.bodyVisible.parent)
    {
		self.dropShadow = [CCSprite spriteWithFile: @"Media/Objects/balloon_dropshadow.png"];
		[self addChild: self.dropShadow];
		
		self.bodyVisible = [CCSprite spriteWithFile: @"Media/Objects/balloon.png"];
		
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

@end
