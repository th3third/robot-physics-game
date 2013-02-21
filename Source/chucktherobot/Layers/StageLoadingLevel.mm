//
//  StageLoadingLevel.m
//  chucktherobot
//
//  Created by Marshall on 31/01/2013.
//
//

#import "Layers.h"

@implementation StageLoadingLevel

+ (CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	StageLoadingLevel *layer = [StageLoadingLevel node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

- (id) init
{
	if( (self = [super init]))
    {
		// enable events
		self.isTouchEnabled = YES;
		
		CGSize size = [[CCDirector sharedDirector] winSize];
		
		CCSprite *background = [CCSprite spriteWithFile: @"Media/Backgrounds/general/main_menu.jpg"];
		background.position = ccp(size.width / 2, size.height / 2);
		background.scaleX = size.width / background.contentSize.width;
		background.scaleY = size.height / background.contentSize.height;
		[self addChild: background z: -2];
		
		NSArray *statusMessage = [NSArray arrayWithObjects:
								  @"Constructing circles out of toothpicks",
								  @"Untangling ropes from each other",
								  @"Welding robot back together",
								  @"Throwing blocks in to level",
								  @"Double-checking safety parameters",
								  @"Unpopping potential poppable poppers",
								  @"Inflating all balloons in level",
								  @"Janitor is sweeping level - stand by",
								  @"Chuck Enrichment & Testing Initiative",
								  nil];
		
		[self scheduleUpdate];
		[self setStatusLabel: [statusMessage objectAtIndex: arc4random() % [statusMessage count]]];
		[self createSpinner];
		[self loadLevel];
	}
	
	return self;
}

- (void) loadLevel
{
	downloadingLevel = YES;
	
	if ([Director shared].online)
	{
		if ([[Director shared] getLevelFromServer])
		{
			finishedDownloadingLevel = YES;
		}
		else
		{
			[self performSelectorOnMainThread: @selector(failedLoading) withObject: nil waitUntilDone: YES];
		}
	}
	else
	{
		finishedDownloadingLevel = YES;
	}
}

- (void) failedLoading
{
	DialogLayer *errorDialog = [[DialogLayer alloc] initNotificationWithMessage: @"There was an error loading the level from the server. This could mean the file is corrupt or the server is currently down. Sorry about that!" callback: self selector: @selector(goToStageSelect)];
	[self addChild: errorDialog z: 9000];
}

- (void) setStatusLabel: (NSString *) message
{
	if (!statusLabel)
	{
		CGSize s = [CCDirector sharedDirector].winSize;
		
		[statusLabel removeFromParentAndCleanup:YES];
		statusLabel = [DialogLayer createShadowHeaderWithString: message
													   position: ccp(s.width * 0.5, s.height * 0.1 * [Director shared].scaleFactor.width)
												   shadowOffset: CGSizeMake(1, -1)
														  color: ccWHITE
													shadowColor: ccBLACK
													 dimensions: CGSizeMake(s.width, 50)
													 hAlignment: kCCTextAlignmentCenter
					    vAlignment: kCCVerticalTextAlignmentBottom
												  lineBreakMode: kCCLineBreakModeMiddleTruncation
													   fontSize: 22 * [Director shared].scaleFactor.width
					   ];
		[self addChild: statusLabel];
	}
}

- (void) createSpinner
{
	CGSize s = [CCDirector sharedDirector].winSize;
	
	spinner = [CCSprite spriteWithFile: @"Media/Buttons/general/button_gear.png"];
	[spinner setPosition: ccp(s.width / 2, s.height / 2)];
	[spinner setRotation: 0.00];
	[spinner setScale: ((s.width)) * 0.40 / spinner.contentSize.width];
	[self addChild: spinner];
	
	spinnerTween = [CCActionTween actionWithDuration: 2.0 key: @"rotation" from: 0.00 to: 360.00];
	[spinner runAction: spinnerTween];
}

- (void) update: (ccTime) dt
{
	if (spinnerTween.isDone)
	{
		[spinner runAction: spinnerTween];
	}
	
	if (finishedDownloadingLevel)
	{
		finishedDownloadingLevel = NO;
		[self scheduleOnce: @selector(goToStage) delay: 1.0];
	}
}

#pragma mark GOTOS

- (void) goToStage
{
	[[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration: 0.5 scene: [StageLayer scene]]];
}

- (void) goToStageSelect
{
	[[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration: 0.5 scene: [StageSelectLayer scene]]];
}

@end
