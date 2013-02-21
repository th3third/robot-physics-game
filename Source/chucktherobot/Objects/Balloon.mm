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
        self.lift = 25 * [Director shared].scaleFactor.height;
		self.radius = 20.0 * [Director shared].scaleFactor.width;
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
		tintColor = ccc3(252, 178, 88);
	else
		tintColor = ccc3(51, 240, 110);
    
    self.bodyVisible.color = tintColor;
}

- (id) unserializeWithDict:(NSDictionary *)dict
{
	[self initWithStart: ccp([[dict objectForKey: @"startPosX"] floatValue] * [Director shared].scaleFactor.width, [[dict objectForKey: @"startPosY"] floatValue] * [Director shared].scaleFactor.height) andRadius: [[dict objectForKey: @"radius"] floatValue] * [Director shared].scaleFactor.width];
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
    self.bodyVisible.rotation = 0;
	
	self.dropShadow.scaleX = newWidth / self.dropShadow.contentSize.width * 1.1;
	self.dropShadow.scaleY = newHeight / self.dropShadow.contentSize.height * 1.1;
    self.dropShadow.position = ccp(((self.body->GetPosition().x * PTM_RATIO)) + 2, ((self.body->GetPosition().y * PTM_RATIO) - 2));
    self.dropShadow.rotation = 0;
    self.dropShadow.anchorPoint = ccp(0.5, 0.5);
}

@end
