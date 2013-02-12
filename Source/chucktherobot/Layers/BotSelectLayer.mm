//
//  BotSelectLayer.m
//  chuckthebot
//
//  Created by Marshall on 11/02/2013.
//
//

#import "Layers.h"
#import "MToolsAppSettings.h"

@implementation BotSelectLayer

#define FONT_SIZE 24

+ (CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	BotSelectLayer *layer = [BotSelectLayer node];
	
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
		
		//Defaults
		menuItemsPerPage = 20;
		totalMenuItems = [[self botList] count];
		
		//Pan gesture recognizer for swiping the menu.
		pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
		CCDirector *director = [CCDirector sharedDirector];
		[[director openGLView] addGestureRecognizer:pan];
		
		CGSize s = [CCDirector sharedDirector].winSize;
		
		//Crate the background.
		CCSprite *background = [CCSprite spriteWithFile: @"Media/Backgrounds/general/main_menu.jpg"];
		float scaleX = s.width / background.contentSize.width;
		float scaleY = s.height / background.contentSize.height;
		[background setAnchorPoint: ccp(0, 0)];
		[background setScaleX: scaleX];
		[background setScaleY: scaleY];
		[self addChild: background z: -3];
		
		//Create the menu.
		[self createMenu];
		
		//Create the list of levels.
		//[self showBotList];
	}
	
	return self;
}

- (void) createMenu
{
	[CCMenuItemFont setFontSize: FONT_SIZE];
	
	//Start from level.
    NSMutableArray *menuItems = [NSMutableArray array];
	CCMenuItemLabel *menuItem;
    
    menuItem = [CCMenuItemFont itemWithString:@"Back to Main Menu" block:^(id sender){
		[self scheduleOnce: @selector(goToMainMenu) delay: 0.0];
	}];
	[menuItem setPosition: ccp(0, -[[CCDirector sharedDirector] winSize].height / 2)];
	[menuItem setAnchorPoint: ccp(0.5, 0)];
    [menuItems addObject: menuItem];
	
	CCMenu *menu = [CCMenu menuWithArray: menuItems];
	
	CGSize size = [[CCDirector sharedDirector] winSize];
	[menu setPosition:ccp( size.width/2, size.height/2)];
	
	[self addChild: menu z:-1];
}

- (void) createBotList
{
	
    [CCMenuItemFont setFontSize: FONT_SIZE];
    
	CGSize s = [CCDirector sharedDirector].winSize;
    NSMutableArray *menuItems = [NSMutableArray array];
    CCMenuItemSprite *menuItem;
	
	//TODO: Get the bots that we currently have.
	NSArray *botList = [self botList];
	enabledMenuItems = 6;
	
	if (!enabledMenuItems)
		enabledMenuItems = 1;
	
	if (![MToolsAppSettings getValueWithName: @"botSelected"])
	{
		[MToolsAppSettings setValue: [NSNumber numberWithInt: 0] withName: @"botSelected"];
	}
	
	NSNumber *botSelected = [MToolsAppSettings getValueWithName: @"botSelected"];
	for (int i = 0; i < enabledMenuItems; i++)
	{
		NSString *botName = [botList objectAtIndex: i];
		
		CCSprite *menuItemSprite = [CCSprite spriteWithFile: @"Media/Buttons/general/button_levelselect_background.png"];
		CCSprite *menuItemSpriteSelected = [CCSprite spriteWithFile: @"Media/Buttons/general/button_levelselect_background.png"];
		
		menuItem = [CCMenuItemSprite itemWithNormalSprite: menuItemSprite selectedSprite: menuItemSpriteSelected block:^(id sender)
					{

					}];
		float scale = (s.width * 0.3) / menuItem.contentSize.width;
		[menuItem setScale: scale];
		[menuItem setUserObject: botName];
		[menuItems addObject: menuItem];
	}
	
	for (int i = enabledMenuItems; i < totalMenuItems; i++)
	{
		CCSprite *menuItemSprite = [CCSprite spriteWithFile: @"Media/Buttons/general/button_levelselect_background_locked.png"];
		CCSprite *menuItemSpriteSelected = [CCSprite spriteWithFile: @"Media/Buttons/general/button_levelselect_background_locked.png"];
		
		menuItem = [CCMenuItemSprite itemWithNormalSprite: menuItemSprite selectedSprite: menuItemSpriteSelected block:^(id sender)
					{
					}];
		float scale = (s.width * 0.3) / menuItem.contentSize.width;
		[menuItem setScale: scale];
		[menuItems addObject: menuItem];
	}
	
	int menusToCreate = MAX(1, round(totalMenuItems / menuItemsPerPage));
	if (totalMenuItems % menuItemsPerPage > 0)
	{
		menusToCreate++;
	}
	
	for (int j = 0; j < menusToCreate; j++)
	{
		int maxRange = menuItemsPerPage;
		if ((j * menuItemsPerPage + menuItemsPerPage) > [menuItems count])
		{
			maxRange -=  (j * menuItemsPerPage + menuItemsPerPage) - [menuItems count];
		}
		
		NSArray *newMenuItems = [menuItems subarrayWithRange: NSMakeRange((j * menuItemsPerPage), maxRange)];
		CCMenu *menu = [CCMenu menuWithArray: newMenuItems];
		
		if (maxRange % 2 == 0)
		{
			[menu alignItemsInColumns: [NSNumber numberWithInt: maxRange / 4], [NSNumber numberWithInt: maxRange / 4], [NSNumber numberWithInt: maxRange / 4], [NSNumber numberWithInt: maxRange / 4], nil];
		}
		else
		{
			[menu alignItemsInColumns: [NSNumber numberWithInt: maxRange / 3], [NSNumber numberWithInt: maxRange / 3], [NSNumber numberWithInt: maxRange / 3], nil];
		}
		
		for (int i = 0; i < [menu.children count]; i++)
		{
			CCMenuItem *menuItem = [menu.children objectAtIndex: i];
			float randomYJitter = arc4random() % 12;
			randomYJitter -= 6;
			[menuItem setPosition: ccp(menuItem.position.x, menuItem.position.y + randomYJitter)];
			
			//Connecting ropes
			/*
			 if ((i + 1) % (menuItemsPerPage / 4) != 0)
			 {
			 CCSprite *rope = [CCSprite spriteWithFile: @"Media/buttons/general/button_levelselect_rope.png"];
			 float scale = (menuItem.contentSize.width * menuItem.scaleX) / (rope.contentSize.width);
			 [rope setScale: scale];
			 [rope setAnchorPoint: ccp(0, 0.5)];
			 [rope setPosition: ccp((j * s.width) + (s.width / 2) + menuItem.position.x, (s.height / 2) + menuItem.position.y)];
			 [rope setRotation: randomYJitter];
			 [self.selectionNode addChild: rope z: -2];
			 }*/
		}
		
		[menu setPosition:ccp( s.width/2 + (s.width * j), s.height/2)];
		
		[selectionNode addChild: menu z:-1];
	}
	
	[self createPageTurners];
}

- (void) showBotList
{
	[self createBotList];
}

- (NSArray *) botList
{
	NSMutableArray *botList = [NSMutableArray array];
	
	return botList;
}

#pragma mark PAGE CONTROLS

- (void) createPageTurners
{
	//Create the arrows to flip back and forth through the menus.
	CGSize s = [CCDirector sharedDirector].winSize;
	NSMutableArray *menuItems = [NSMutableArray array];
	CCMenuItemSprite *menuItem;
	CCSprite *menuItemSprite;
	CCSprite *menuItemSpriteSelected;
	
	menuItemSprite = [CCSprite spriteWithFile: @"Media/Buttons/general/button_dialog_next.png"];
	menuItemSpriteSelected = [CCSprite spriteWithFile: @"Media/Buttons/general/button_dialog_next.png"];
	menuItem = [CCMenuItemSprite itemWithNormalSprite: menuItemSprite selectedSprite: menuItemSpriteSelected block:^(id sender) {
		[self goToPreviousPage: menuItem];
	}];
	[menuItem setTag: 0];
	if ([Director shared].levelSelectPageNum <= 0)
	{
		[menuItem setVisible: NO];
	}
	[menuItem setPosition: ccp((-s.width / 2) + (menuItem.contentSize.width * menuItem.scaleX) / 2, 0)];
	[menuItems addObject: menuItem];
	
	menuItemSprite = [CCSprite spriteWithFile: @"Media/Buttons/general/button_dialog_next.png"];
	menuItemSpriteSelected = [CCSprite spriteWithFile: @"Media/Buttons/general/button_dialog_next.png"];
	menuItem = [CCMenuItemSprite itemWithNormalSprite: menuItemSprite selectedSprite: menuItemSpriteSelected block:^(id sender) {
		[self goToNextPage: menuItem];
	}];
	[menuItem setTag: 1];
	if ([Director shared].levelSelectPageNum >= totalMenuItems / menuItemsPerPage)
	{
		[menuItem setVisible: NO];
	}
	[menuItem setPosition: ccp((s.width / 2) - (menuItem.contentSize.width * menuItem.scaleX) / 2, 0)];
	[menuItems addObject: menuItem];
	
	pageMenu = [CCMenu menuWithArray: menuItems];
	[self addChild: pageMenu z: 8999];
}

- (void) goToPreviousPage: (id) caller
{
	if (pageTurning)
		return;
	
	[Director shared].levelSelectPageNum--;
	[[pageMenu getChildByTag: 1] setVisible: YES];
	
	if ([Director shared].levelSelectPageNum <= 0)
	{
		[[pageMenu getChildByTag: 0] setVisible: NO];
	}
	else
	{
		[[pageMenu getChildByTag: 0] setVisible: YES];
	}
	
	[self movePage];
}

- (void) goToNextPage: (id) caller
{
	if (pageTurning)
		return;
	
	[Director shared].levelSelectPageNum++;
	[[pageMenu getChildByTag: 0] setVisible: YES];
	
	if ([Director shared].levelSelectPageNum >= totalMenuItems / menuItemsPerPage)
	{
		[[pageMenu getChildByTag: 1] setVisible: NO];
	}
	else
	{
		[[pageMenu getChildByTag: 1] setVisible: YES];
	}
	
	[self movePage];
}

- (void) movePage
{
	pageTurning = YES;
	[self performSelector: @selector(stopPageTurning) withObject: nil afterDelay: 0.5];
	
	CGSize s = [CCDirector sharedDirector].winSize;
	CCMoveTo *action = [CCMoveTo actionWithDuration: 0.5 position: ccp((-[Director shared].levelSelectPageNum * s.width), selectionNode.position.y)];
	[selectionNode stopAllActions];
	[selectionNode runAction: action];
}

- (void) stopPageTurning
{
	pageTurning = NO;
}

- (void)handlePanGesture:(UIGestureRecognizer*)gestureRecognizer
{
	switch (gestureRecognizer.state)
	{
		case UIGestureRecognizerStateBegan:
		{
			break;
		}
		case UIGestureRecognizerStateChanged:
		{
			// Get pan gesture recognizer translation
			CGPoint translation = [(UIPanGestureRecognizer*)gestureRecognizer velocityInView: gestureRecognizer.view];
			
			// Invert Y since position and offset are calculated in gl coordinates
			translation = ccp(-translation.x, -translation.y);
			
			if (translation.x > 1000)
			{
				[self goToNextPage: nil];
			}
			else if (translation.x < -1000)
			{
				[self goToPreviousPage: nil];
			}
			
			//self.selectionNode.position = ccp(self.selectionNode.position.x - translation.x, self.selectionNode.position.y);
			
			// Refresh pan gesture recognizer
			[(UIPanGestureRecognizer*)gestureRecognizer setTranslation:CGPointZero inView:gestureRecognizer.view];
			
			break;
		}
		case UIGestureRecognizerStateEnded:
		{
			
			break;
		}
		default:
		{
			break;
		}
    }
}

#pragma mark GOTOS

- (void) goToMainMenu
{	
	CCDirector* director = [CCDirector sharedDirector];
	[[director openGLView] removeGestureRecognizer: pan];
	
	[[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration: 0.0 scene: [MainMenuLayer scene]]];
}

@end
