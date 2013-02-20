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
#import "MToolsPurchaseManager.h"

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
		[[CCTextureCache sharedTextureCache] removeUnusedTextures];
		
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
	[logo setPosition: ccp(s.width / 2, s.height * 0.885)];
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
		[Director shared].editing = YES;
		[self goToStage];
	}];
	[menuItem setScale: scale];
    [menuItems addObject: menuItem];
    
	menuItemSpriteNormal = [CCSprite spriteWithFile: @"Media/Buttons/general/button_main_online_levels.png"];
	menuItemSpriteSelected = [CCSprite spriteWithFile: @"Media/Buttons/general/button_main_online_levels.png"];
    menuItem = [CCMenuItemImage itemWithNormalSprite: menuItemSpriteNormal selectedSprite: menuItemSpriteSelected block:^(id sender) {
		
		[Director shared].fullVersion = [[MToolsPurchaseManager sharedManager] productPurchased: @"fullversion"];
		
		if (![Director shared].fullVersion)
		{
			DialogLayer *purchaseDialog = [[DialogLayer alloc] initNotificationWithMessage: @"Sorry, but playing online levels requires purchasing the Full Version in-app purchase." callback: self selector: @selector(openPurchaseDialog)];
			[self addChild: purchaseDialog z: 9000];
			return;
		}
		
		if (![Director shared].loggedIn)
		{
			[Director shared].online = YES;
			DialogLayer *loginDialog = [[DialogLayer alloc] initLoginWithCallbackObj: self selector: @selector(logInWith:)];
			[self addChild: loginDialog z: 9000];
		}
		else
		{
			[Director shared].online = YES;
			[self performSelector: @selector(createLoadingBox)];
			[self scheduleOnce:@selector(goToStageSelect) delay:0.2];
		}
	}];
	[menuItem setScale: scale];
    [menuItems addObject: menuItem];
	
	CCMenu *menu = [CCMenu menuWithArray: menuItems];
	[menu alignItemsVertically];
	[menu setPosition: ccp(s.width / 2, (s.height / 2) - ((logo.contentSize.height / 2.3) * logo.scale))];
	[self addChild: menu z:-1];
	
	//LOWER-LEFT MENU
	CCSprite *lowerLeftMenuBackground = [CCSprite spriteWithFile: @"Media/Buttons/general/main_menu/button_lower_left_background.png"];
	[lowerLeftMenuBackground setAnchorPoint: ccp(0, 0.5)];
	[lowerLeftMenuBackground setScale: (s.width * 0.2) / lowerLeftMenuBackground.contentSize.width];
	[lowerLeftMenuBackground setPosition: ccp(0, (lowerLeftMenuBackground.contentSize.height * lowerLeftMenuBackground.scale) * 0.5)];
	[self addChild: lowerLeftMenuBackground];
	
	menuItems = [NSMutableArray array];
	
	menuItemSpriteNormal = [CCSprite spriteWithFile: @"Media/Buttons/general/main_menu/button_cart.png"];
	menuItemSpriteSelected = [CCSprite spriteWithFile: @"Media/Buttons/general/main_menu/button_cart.png"];
    menuItem = [CCMenuItemImage itemWithNormalSprite: menuItemSpriteNormal selectedSprite: menuItemSpriteSelected block:^(id sender)
	{
		[self openPurchaseDialog];
	}];
	[menuItem setScale: scale];
	[menuItem setAnchorPoint: ccp(0, 0.5)];
	[menuItem setPosition: ccp(lowerLeftMenuBackground.position.x + ((lowerLeftMenuBackground.contentSize.width * lowerLeftMenuBackground.scale) * 0.15), lowerLeftMenuBackground.position.y)];
    [menuItems addObject: menuItem];
	
	menuItemSpriteNormal = [CCSprite spriteWithFile: @"Media/Buttons/general/main_menu/button_question_mark.png"];
	menuItemSpriteSelected = [CCSprite spriteWithFile: @"Media/Buttons/general/main_menu/button_question_mark.png"];
    menuItem = [CCMenuItemImage itemWithNormalSprite: menuItemSpriteNormal selectedSprite: menuItemSpriteSelected block:^(id sender) {
	DialogLayer *creditsDialog = [[DialogLayer alloc] initCreditsWithCallbackObj: self selector: @selector(madePurchase:)];
	[self addChild: creditsDialog z: 9000];
	}];
	[menuItem setScale: scale];
	[menuItem setAnchorPoint: ccp(1, 0.5)];
	[menuItem setPosition: ccp(lowerLeftMenuBackground.position.x + ((lowerLeftMenuBackground.contentSize.width * lowerLeftMenuBackground.scale) * 0.80), lowerLeftMenuBackground.position.y)];
    [menuItems addObject: menuItem];
	
	menu = [CCMenu menuWithArray: menuItems];
	[menu setAnchorPoint: ccp(0, 0)];
	[menu setPosition: CGPointZero];
	[self addChild: menu];
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
		NSString *pageURL = @"http://www.facebook.com/sharer.php?u=https://www.facebook.com/gearsprout?fref=ts&t=Playing Chuck the Bot by GearSprout!";
		NSString *escaped = [pageURL stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
		[[UIApplication sharedApplication] openURL: [NSURL URLWithString: escaped]];
	}];
	[menuItem setScale: scale];
    [menuItems addObject: menuItem];
    
	menuItemSpriteNormal = [CCSprite spriteWithFile: @"Media/Buttons/general/button_main_twitter.png"];
	menuItemSpriteSelected = [CCSprite spriteWithFile: @"Media/Buttons/general/button_main_twitter.png"];
	scale = (s.width * 0.06) / menuItemSpriteNormal.contentSize.width;
    menuItem = [CCMenuItemImage itemWithNormalSprite: menuItemSpriteNormal selectedSprite: menuItemSpriteSelected block:^(id sender) {
		NSString *pageURL = @"http://twitter.com/home?status=RT @GearSprout – Having fun playing Chuck the Bot on my iOS device!";
		NSString *escaped = [pageURL stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
		[[UIApplication sharedApplication] openURL: [NSURL URLWithString: escaped]];
	}];
	[menuItem setScale: scale];
    [menuItems addObject: menuItem];
    
	menuItemSpriteNormal = [CCSprite spriteWithFile: @"Media/Buttons/general/button_main_email.png"];
	menuItemSpriteSelected = [CCSprite spriteWithFile: @"Media/Buttons/general/button_main_email.png"];
	scale = (s.width * 0.06) / menuItemSpriteNormal.contentSize.width;
    menuItem = [CCMenuItemImage itemWithNormalSprite: menuItemSpriteNormal selectedSprite: menuItemSpriteSelected block:^(id sender) {
		[self mail];
	}];
	[menuItem setScale: scale];
    [menuItems addObject: menuItem];
	
	CCMenu *menu = [CCMenu menuWithArray: menuItems];
	[menu alignItemsHorizontallyWithPadding: 1.0f];
	[menu setPosition: ccp(s.width - ((menuBackground.contentSize.width / 2) * menuBackground.scale), ((menuBackground.contentSize.height / 2) * menuBackground.scale))];
	
	[self addChild: menu z:-1];
}

- (void) openPurchaseDialog
{
	DialogLayer *purchaseDialog = [[DialogLayer alloc] initPurchaseWithCallbackObj: self selector: @selector(madePurchase:)];
	[self addChild: purchaseDialog z: 9000];
}

- (void) createLoadingBox
{
	CGSize s = [CCDirector sharedDirector].winSize;
	
	CCSprite *loadingBackground = [CCSprite spriteWithFile: @"Media/Backgrounds/blank.jpg"];
	[loadingBackground setScaleX: (s.width / loadingBackground.contentSize.width)];
	[loadingBackground setScaleY: (s.height / loadingBackground.contentSize.height)];
	[loadingBackground setOpacity: 100];
	[loadingBackground setPosition: ccp(s.width * 0.5, s.height * 0.5)];
	[self addChild: loadingBackground z: 8999];
	
	CCLabelTTF *loadingLabel = [DialogLayer createShadowHeaderWithString: @"Loading..."
																position: ccp(s.width * 0.5, s.height * 0.5)
															shadowOffset: CGSizeMake(1, -1)
																   color: ccWHITE
															 shadowColor: ccBLACK
															  dimensions: CGSizeMake(s.width, s.height)
															  hAlignment: kCCTextAlignmentCenter
															  vAlignment: kCCVerticalTextAlignmentCenter
														   lineBreakMode: kCCLineBreakModeMiddleTruncation
																fontSize: 48
								];
	
	[self addChild: loadingLabel z: 9000];
}

#pragma mark GOTOS

- (void) goToStageSelect
{
	[DialogLayer playButtonSound];
	[[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration: 0.5 scene: [StageSelectLayer scene]]];
}

- (void) goToStage
{
	[DialogLayer playButtonSound];
	[Director shared].editing = YES;
	[Director shared].stage = nil;
	[Director shared].stageName = nil;
	[[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration: 0.5 scene: [StageLayer scene]]];
}

- (void) goToBotList
{
	[DialogLayer playButtonSound];
	[[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration: 0.0 scene: [BotSelectLayer scene]]];
}

#pragma mark LOGIN

- (void) logInWith:(NSArray *)loginInfo
{
	[super logInWith: loginInfo];
	[self goToStageSelect];
}

#pragma mark MFMail delegate

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
	AppController *app = (AppController *)[[UIApplication sharedApplication] delegate];
	[app.navController dismissModalViewControllerAnimated: YES];
}

- (void) mail
{
	AppController *app = (AppController *)[[UIApplication sharedApplication] delegate];
	
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self;
	[picker setSubject:@"Playing Chuck the Bot"];
	
	NSString *emailBody = @"I've been playing Chuck the Bot and I'd like you to check it out too so we can share levels! \n\n http://gearsprout.com/chuck_the_bot.html";
	[picker setMessageBody:emailBody isHTML:YES];
	
	[app.navController presentModalViewController:picker animated:YES];
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

