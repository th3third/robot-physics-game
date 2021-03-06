//
//  StageSaveToFile.m
//  chucktherobot
//
//  Created by Marshall on 23/01/2013.
//
//

#import "Layers.h"

@implementation StageSaveToFile

+ (CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	StageSaveToFile *layer = [StageSaveToFile node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

- (id) init
{
	if( (self = [super init]))
    {
		[[CCTextureCache sharedTextureCache] removeUnusedTextures];
		
		// enable events
		self.isTouchEnabled = YES;
		
		CGSize size = [[CCDirector sharedDirector] winSize];
		
		CCSprite *background = [CCSprite spriteWithFile: [NSString stringWithFormat: @"Media/Backgrounds/general/main_menu.jpg", [Director shared].stage.background]];
		background.position = ccp(size.width / 2, size.height / 2);
		background.scaleX = size.width / background.contentSize.width;
		background.scaleY = size.height / background.contentSize.height;
		[self addChild: background z: -2];
		
		[self scheduleUpdate];
		[self setStatusLabel: @"Saving and sharing level..."];
		[self createSpinner];
		[self saveCurrentStage];
	}
	
	return self;
}

- (void) saveCurrentStage
{
	finishedLocalSave = NO;
	finishedOnlineSave = NO;
	
	[[Director shared].stage saveToFile];
	finishedLocalSave = YES;
	
	if ([[Director shared] saveLevelToServer])
	{
		finishedOnlineSave = YES;
	}
	else
	{
		[self performSelectorOnMainThread: @selector(failedServerSave) withObject: nil waitUntilDone: YES];
	}
}

- (void) failedServerSave
{
	DialogLayer *errorDialog = [[DialogLayer alloc] initNotificationWithMessage: @"There was an error saving your level to the server. This usually means that a level by your name already exists or you entered an invalid name."];
	[self addChild: errorDialog z: 9000];
}

- (void) setStatusLabel: (NSString *) message
{
	if (!statusLabel)
	{
		CGSize s = [CCDirector sharedDirector].winSize;
		
		[statusLabel removeFromParentAndCleanup:YES];
		statusLabel = [DialogLayer createShadowHeaderWithString: message
													   position: ccp(s.width * 0.5, s.height * 0.1)
												   shadowOffset: CGSizeMake(1, -1)
														  color: ccWHITE
													shadowColor: ccBLACK
													 dimensions: CGSizeMake(s.width, s.height * 0.5)
													 hAlignment: kCCTextAlignmentCenter
													 vAlignment: kCCVerticalTextAlignmentCenter
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
	
	if (finishedLocalSave)
	{
		[self setStatusLabel: @"Sending to server..."];
		finishedLocalSave = NO;
	}
	
	if (finishedOnlineSave)
	{
		[self setStatusLabel: @"Level saved!"];
		finishedOnlineSave = NO;
		[self scheduleOnce: @selector(goToStage) delay: 1.0];
	}
}

#pragma mark GOTOS

- (void) goToStage
{
	[Director shared].stageName = [Director shared].stage.name;
	[[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration: 0.5 scene: [StageLayer scene]]];
}

@end
