#import "Layers.h"

#define FONT_SIZE 24
#define TITLE_FONT_SIZE 32

@implementation StageSaveLayer

+ (CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	StageSaveLayer *layer = [StageSaveLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

- (id) init
{
	if( (self = [super init]))
    {
		//Create all the tag names.
		tagNames = [NSMutableArray array];
		[tagNames addObject: @"destructive"];
		[tagNames addObject: @"crazy"];
		[tagNames addObject: @"hard"];
		[tagNames addObject: @"bouncy"];
		[tagNames addObject: @"short"];
		[tagNames addObject: @"puzzle"];
		[tagNames addObject: @"artistic"];
		[tagNames addObject: @"timing"];
		
		self.isTouchEnabled = YES;
		
		CGSize size = [CCDirector sharedDirector].winSize;
		
		CCSprite *background = [CCSprite spriteWithFile: [NSString stringWithFormat: @"Media/Backgrounds/general/main_menu.jpg", [Director shared].stage.background]];
		background.position = ccp(size.width / 2, size.height / 2);
		background.scaleX = size.width / background.contentSize.width;
		background.scaleY = size.height / background.contentSize.height;
		[self addChild: background z: -2];
	}
	
	return self;
}



#pragma mark GOTOS



- (void) goToStage
{
	[[CCDirector sharedDirector] replaceScene: [CCTransitionSlideInB transitionWithDuration: 0.5 scene: [StageLayer scene]]];
}

@end

