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

// 
-(void) onEnter
{
	[super onEnter];

	// ask director for the window size
	CGSize size = [[CCDirector sharedDirector] winSize];

	CCSprite *background = [CCSprite spriteWithFile:@"Media/Backgrounds/general/loading.jpg"];
	[background setScaleX: (size.width / background.contentSize.width)];
	[background setScaleY: (size.height / background.contentSize.height)];
	background.position = ccp(size.width/2, size.height/2);

	// add the label as a child to this Layer
	[self addChild: background];

	//Init the director right away.
	[[Director shared] init];
	
	//Init the purchase stuff.
	[[MToolsPurchaseManager sharedManager] setVocal: YES];
	[[MToolsPurchaseManager sharedManager] loadStore];
	
    //Create the levels folder if it doesn't exist already.
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error;
    [fm createDirectoryAtPath: [NSString stringWithFormat: @"%@/levels", [MToolsFileManager applicationDocumentsDirectory]] withIntermediateDirectories: YES attributes: nil error: &error];
    
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
	}
    
	//TODO: Increment the times run by one or set it up if it hasn't been set up already.
	
	
	// In one second transition to the new scene
	[self scheduleOnce:@selector(makeTransition:) delay:1];
}

-(void) makeTransition:(ccTime)dt
{
	
	//Play the background music.
	[[Director shared] playMusic: @"Media/Audio/general/music/main_menu.mp3"];
	[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration: 1.0 scene:[MainMenuLayer scene] withColor: ccBLACK]];
}
@end
