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
		
		[self scheduleUpdate];
		[self setStatusLabel: @"Contacting server..."];
		[self createSpinner];
		[self loadLevel];
	}
	
	return self;
}

- (void) loadLevel
{
	downloadingLevel = YES;
	
	if ([[Director shared] getLevelFromServer])
	{
		finishedDownloadingLevel = YES;
	}
	else
	{
		[self performSelectorOnMainThread: @selector(failedLoading) withObject: nil waitUntilDone: YES];
	}
}

- (void) failedLoading
{
	DialogLayer *errorDialog = [[DialogLayer alloc] initWithHeader: @"Server Error" andLine1: @"There was an error loading the level from the server. This could mean the server is currently too busy, a firewall is blocking the connection, the file is corrupt, or some other insane reason. Sorry about that!" target: self selector: @selector(goToStage) textField: NO];
	[self addChild: errorDialog z: 9000];
}

- (void) setStatusLabel: (NSString *) message
{
	if (!statusLabel)
	{
		CGSize s = [CCDirector sharedDirector].winSize;
		
		statusLabel = [CCLabelTTF labelWithString: message fontName: [Director shared].globalFont fontSize: 24];
        [statusLabel setColor:ccc3(255, 255, 255)];
        [statusLabel setPosition: ccp(s.width / 2, 50)];
        [self addChild:statusLabel z: 0];
	}
	else
	{
		[statusLabel setString: message];
	}
}

- (void) createSpinner
{
	CGSize s = [CCDirector sharedDirector].winSize;
	
	spinner = [CCSprite spriteWithFile: @"Media/Buttons/general/button_gear.png"];
	[spinner setPosition: ccp(s.width / 2, s.height / 2)];
	[spinner setRotation: 0.00];
	[spinner setScale: 0.50];
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
		[self setStatusLabel: @"Loading level..."];
		finishedDownloadingLevel = NO;
		[self scheduleOnce: @selector(goToStage) delay: 1.0];
	}
}

#pragma mark GOTOS

- (void) goToStage
{
	[[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration: 0.5 scene: [StageLayer scene]]];
}

@end
