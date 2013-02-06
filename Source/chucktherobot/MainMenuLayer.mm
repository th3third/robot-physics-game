//
//  MainMenuLayer.m
//  chucktherobot
//
//  Created by Marshall on 03/01/2013.
//
//

// Import the interfaces
#import "Layers.h"
#import "MToolsAppSettings.h"

@interface MainMenuLayer()
-(void) createMenu;
@end

@implementation MainMenuLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	MainMenuLayer *layer = [MainMenuLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(id) init
{
	if( (self=[super init]))
    {
		// enable events
		
		self.isTouchEnabled = YES;
		self.isAccelerometerEnabled = NO;
		
		CGSize s = [CCDirector sharedDirector].winSize;
		
		//Crate the background.
		CCSprite *background = [CCSprite spriteWithFile: @"Media/Backgrounds/general/main_menu.jpg"];
		float scaleX = s.width / background.contentSize.width;
		float scaleY = s.height / background.contentSize.height;
		[background setAnchorPoint: ccp(0, 0)];
		[background setScaleX: scaleX];
		[background setScaleY: scaleY];
		[self addChild: background z: -3];
		
		//Create the main menu.
		[self createMainMenu];
		
		//Create the social menu.
		[self createSocialMenu];
	}
	
	return self;
}

-(void) createMainMenu
{	
	CGSize s = [CCDirector sharedDirector].winSize;
	
	//Start from level.
	float scale;
    NSMutableArray *menuItems = [NSMutableArray array];
	CCMenuItemImage *menuItem;
	CCSprite *menuItemSpriteNormal;
	CCSprite *menuItemSpriteSelected;
	CCSprite *logo;
	
	logo = [CCSprite spriteWithFile: @"Media/main_logo.png"];
	scale = (s.width * 0.9) / logo.contentSize.width;
	[logo setScale: scale];
	[logo setAnchorPoint: ccp(0.5, 1)];
	[logo setPosition: ccp(s.width / 2, s.height - 5)];
	[self addChild: logo];
	
	menuItemSpriteNormal = [CCSprite spriteWithFile: @"Media/Buttons/general/button_main_play.png"];
	menuItemSpriteSelected = [CCSprite spriteWithFile: @"Media/Buttons/general/button_main_play.png"];
	scale = (s.width * 0.40) / menuItemSpriteNormal.contentSize.width;
    menuItem = [CCMenuItemImage itemWithNormalSprite: menuItemSpriteNormal selectedSprite: menuItemSpriteSelected block:^(id sender) {
		[Director shared].online = NO;
		[self scheduleOnce:@selector(goToStageSelect) delay: 0];
	}];
	[menuItem setScale: scale];
    [menuItems addObject: menuItem];
    
	menuItemSpriteNormal = [CCSprite spriteWithFile: @"Media/Buttons/general/button_main_create.png"];
	menuItemSpriteSelected = [CCSprite spriteWithFile: @"Media/Buttons/general/button_main_create.png"];
    menuItem = [CCMenuItemImage itemWithNormalSprite: menuItemSpriteNormal selectedSprite: menuItemSpriteSelected block:^(id sender) {
		[self scheduleOnce:@selector(goToStage) delay:0];
	}];
	[menuItem setScale: scale];
    [menuItems addObject: menuItem];
    
	menuItemSpriteNormal = [CCSprite spriteWithFile: @"Media/Buttons/general/button_main_online_levels.png"];
	menuItemSpriteSelected = [CCSprite spriteWithFile: @"Media/Buttons/general/button_main_online_levels.png"];
    menuItem = [CCMenuItemImage itemWithNormalSprite: menuItemSpriteNormal selectedSprite: menuItemSpriteSelected block:^(id sender) {
		
		if (![Director shared].loggedIn)
		{
			[self addChild: [[Director shared] createLogInDialog] z: 9000];
		}
		else
		{
			[Director shared].online = YES;
			[self scheduleOnce:@selector(goToStageSelect) delay:0];
		}
	}];
	[menuItem setScale: scale];
    [menuItems addObject: menuItem];
	
	CCMenu *menu = [CCMenu menuWithArray: menuItems];
	[menu alignItemsVertically];
	[menu setPosition: ccp(s.width / 2, (s.height / 2) - ((logo.contentSize.height / 2.3) * logo.scale))];
	
	[self addChild: menu z:-1];
}

-(void) createSocialMenu
{	
	CGSize s = [CCDirector sharedDirector].winSize;
	
	//Start from level.
	float scale;
    NSMutableArray *menuItems = [NSMutableArray array];
	CCMenuItemImage *menuItem;
	CCSprite *menuItemSpriteNormal;
	CCSprite *menuItemSpriteSelected;
	CCSprite *menuBackground;
	
	menuBackground = [CCSprite spriteWithFile: @"Media/Backgrounds/general/social_menu.png"];
	scale = (s.width * 0.225) / menuBackground.contentSize.width;
	[menuBackground setScale: scale];
	[menuBackground setAnchorPoint: ccp(1, 0)];
	[menuBackground setPosition: ccp(s.width - 2, 0)];
	[self addChild: menuBackground z: -3];
	
	menuItemSpriteNormal = [CCSprite spriteWithFile: @"Media/Buttons/general/button_main_facebook.png"];
	menuItemSpriteSelected = [CCSprite spriteWithFile: @"Media/Buttons/general/button_main_facebook.png"];
	scale = (s.width * 0.06) / menuItemSpriteNormal.contentSize.width;
    menuItem = [CCMenuItemImage itemWithNormalSprite: menuItemSpriteNormal selectedSprite: menuItemSpriteSelected block:^(id sender) {
		//TODO: Share on Facebook.
	}];
	[menuItem setScale: scale];
    [menuItems addObject: menuItem];
    
	menuItemSpriteNormal = [CCSprite spriteWithFile: @"Media/Buttons/general/button_main_twitter.png"];
	menuItemSpriteSelected = [CCSprite spriteWithFile: @"Media/Buttons/general/button_main_twitter.png"];
	scale = (s.width * 0.06) / menuItemSpriteNormal.contentSize.width;
    menuItem = [CCMenuItemImage itemWithNormalSprite: menuItemSpriteNormal selectedSprite: menuItemSpriteSelected block:^(id sender) {
		//TODO: Share on Twitter.
	}];
	[menuItem setScale: scale];
    [menuItems addObject: menuItem];
    
	menuItemSpriteNormal = [CCSprite spriteWithFile: @"Media/Buttons/general/button_main_email.png"];
	menuItemSpriteSelected = [CCSprite spriteWithFile: @"Media/Buttons/general/button_main_email.png"];
	scale = (s.width * 0.06) / menuItemSpriteNormal.contentSize.width;
    menuItem = [CCMenuItemImage itemWithNormalSprite: menuItemSpriteNormal selectedSprite: menuItemSpriteSelected block:^(id sender) {
		//TODO: Share via email.
	}];
	[menuItem setScale: scale];
    [menuItems addObject: menuItem];
	
	CCMenu *menu = [CCMenu menuWithArray: menuItems];
	[menu alignItemsHorizontallyWithPadding: 1.0f];
	[menu setPosition: ccp(s.width - ((menuBackground.contentSize.width / 2) * menuBackground.scale), ((menuBackground.contentSize.height / 2) * menuBackground.scale))];
	
	[self addChild: menu z:-1];
}

- (void) goToStageSelect
{
	[[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration: 0.0 scene: [StageSelectLayer scene]]];
}

- (void) goToStage
{
	[Director shared].editing = YES;
	[[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration: 0.0 scene: [StageLayer scene]]];
}

#pragma mark GameKit delegate

-(void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}

-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}

@end

