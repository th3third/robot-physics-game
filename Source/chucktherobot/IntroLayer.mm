//
//  IntroLayer.m
//  chucktherobot
//
//  Created by Marshall on 03/01/2013.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//

#import "Layers.h"
#import "DialogLayer.h"
#import "MToolsFileManager.h"
#import "Director.h"
#import "MToolsPurchaseManager.h"
#import "MToolsAppSettings.h"
#import "MToolsFileManager.h"

#pragma mark - IntroLayer

// HelloWorldLayer implementation
@implementation IntroLayer

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	IntroLayer *layer = [IntroLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(void) onEnter
{
	[super onEnter];
	
	// enable events
	self.isTouchEnabled = YES;
	
	CGSize size = [[CCDirector sharedDirector] winSize];
	
	CCSprite *background = [CCSprite spriteWithFile: @"Media/Backgrounds/general/main_menu.jpg"];
	background.anchorPoint = ccp(0.5, 0.5);
	background.position = ccp(size.width / 2, size.height / 2);
	background.scaleX = size.width / background.contentSize.width;
	background.scaleY = size.height / background.contentSize.height;
	[self addChild: background z: -2];
	
	[self setStatusLabel: @"Loading..."];
	
	//Init the purchase stuff.
	[[debug sharedManager] setEnableLog: NO];
	[[MToolsPurchaseManager sharedManager] setVocal: NO];
	[[MToolsPurchaseManager sharedManager] loadStore];
	
	//Init the standard keys and increment anything that needs to be done.
	[[MToolsAppSettings sharedManager] standardKeys];
	
	
    //Create the levels folder if it doesn't exist already.
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error;
    [fm createDirectoryAtPath: [NSString stringWithFormat: @"%@/levels", [MToolsFileManager applicationDocumentsDirectory]] withIntermediateDirectories: YES attributes: nil error: &error];
    [MToolsFileManager addSkipBackupAttributeToItemAtString: [NSString stringWithFormat: @"%@/levels", [MToolsFileManager applicationDocumentsDirectory]]];
	
    if (error)
    {
        NSLog(@"CRITICAL ERROR: There was a problem creating the levels directory. The game will NOT be able to run like this!");
        DialogLayer *diaLayer = [[DialogLayer alloc] initNotificationWithMessage: @"The levels directory was not able to be created. You may have a corrupt installation of this app or another application is blocking this app."];
        [self addChild: diaLayer z: 9000];
		
		return;
    }
	
	//Create and populate the default levels folder if it doesn't exist already.
	//Create the levels folder if it doesn't exist already.
    [fm createDirectoryAtPath: [NSString stringWithFormat: @"%@/levels/defaults", [MToolsFileManager applicationDocumentsDirectory]] withIntermediateDirectories: YES attributes: nil error: &error];
	[MToolsFileManager addSkipBackupAttributeToItemAtString: [NSString stringWithFormat: @"%@/levels/defaults", [MToolsFileManager applicationDocumentsDirectory]]];
    
    if (error)
    {
		NSLog(@"CRITICAL ERROR: There was a problem creating the default levels directory. The game will NOT be able to run like this!");
		DialogLayer *diaLayer = [[DialogLayer alloc] initNotificationWithMessage: @"The default levels directory was not able to be created. You may have a corrupt installation of this app or another application is blocking this app."];
        [self addChild: diaLayer z: 9000];
		
		return;
	}
	
	NSArray *defaultsPaths = [[NSBundle mainBundle] pathsForResourcesOfType: @".ctr" inDirectory: @"defaults"];
	for (NSString *defaultPath in defaultsPaths)
	{
		[fm copyItemAtPath: defaultPath toPath: [NSString stringWithFormat: @"%@/defaults/%@", [Director levelsPath], [defaultPath lastPathComponent]] error: &error];
		[MToolsFileManager addSkipBackupAttributeToItemAtString: [NSString stringWithFormat: @"%@/defaults/%@", [Director levelsPath], [defaultPath lastPathComponent]]];
	}
}

- (void) onEnterTransitionDidFinish
{
	// In one second transition to the new scene
	[self scheduleOnce:@selector(makeTransition:) delay: 0];
}

-(void) makeTransition:(ccTime)dt
{
	
	//Play the background music.
	[[Director shared] playMusic: @"Media/Audio/general/music/main_menu.mp3"];
	[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration: 1.0 scene:[MainMenuLayer scene] withColor: ccBLACK]];
}

- (void) setStatusLabel: (NSString *) message
{
	if (!statusLabel)
	{
		CGSize s = [CCDirector sharedDirector].winSize;
		
		[statusLabel removeFromParentAndCleanup:YES];
		statusLabel = [DialogLayer createShadowHeaderWithString: message
													   position: ccp(s.width * 0.5, s.height * 0.5)
												   shadowOffset: CGSizeMake(1, -1)
														  color: ccWHITE
													shadowColor: ccBLACK
													 dimensions: CGSizeMake(s.width, s.height * 0.5)
													 hAlignment: kCCTextAlignmentCenter
													 vAlignment: kCCVerticalTextAlignmentCenter
												  lineBreakMode: kCCLineBreakModeMiddleTruncation
													   fontSize: 42 * [Director shared].scaleFactor.width
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
}


@end
