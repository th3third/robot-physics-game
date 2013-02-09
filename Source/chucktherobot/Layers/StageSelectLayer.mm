#import "Layers.h"
#import "MToolsAppSettings.h"

#define FONT_SIZE 24
#define FONT_SIZE_LEVEL 102
#define TITLE_FONT_SIZE 32

@implementation StageSelectLayer

@synthesize pageMenu;

+ (CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	StageSelectLayer *layer = [StageSelectLayer node];
	
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
		totalMenuItems = [[self localLevelsList] count];
		
		//Pan gesture recognizer for swiping the menu.
		UIPanGestureRecognizer* pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
		CCDirector* director = [CCDirector sharedDirector];
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
		[self showLevelList];
		
		//Blank out the existing stage, since we're selecting a new one.
		[Director shared].stage = nil;
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

- (void) showLevelList
{
	CGSize size = [CCDirector sharedDirector].winSize;
	
	if (self.selectionNode)
	{
		[self.selectionNode removeAllChildrenWithCleanup: YES];
	}
	self.selectionNode = [[CCNode alloc] init];
	
	if ([Director shared].online)
	{
		[self createOnlineLevelList];
	}
	else
	{
		[self createLocalLevelList];
	}
	
	[self.selectionNode setPosition: ccp((-[Director shared].levelSelectPageNum * size.width), size.height * 0.25)];
	
	[self addChild: self.selectionNode];
}

- (void) createLocalLevelList
{
	
    [CCMenuItemFont setFontSize: FONT_SIZE];
    
	CGSize s = [CCDirector sharedDirector].winSize;
    NSMutableArray *menuItems = [NSMutableArray array];
    CCMenuItemSprite *menuItem;
    
	NSArray *levelsList;
    switch (self.selectType)
    {
        default:
        case SelectTypeLocal:
        {
			levelsList = [NSArray arrayWithArray: [self localLevelsList]];
            break;
        }
		case SelectTypeWorld:
		{
			
			break;
		}
    }
	
	//Calculate the maximum number of levels the player has reached.
	
	//Do we have a level progress entry? If not, we need to create it.
	if (![MToolsAppSettings getValueWithName: @"levelProgress"])
	{
		NSMutableDictionary *levelProgress = [NSMutableDictionary dictionary];
		for (NSString *levelName in [self localLevelsList])
		{
			[levelProgress setObject: [NSNumber numberWithInt: 0] forKey: levelName];
		}
		
		[MToolsAppSettings setValue: levelProgress withName: @"levelProgress"];
	}
	
	int enabledMenuItems = 0;
	for (id key in [MToolsAppSettings getValueWithName: @"levelProgress"])
	{
		if ([[[MToolsAppSettings getValueWithName: @"levelProgress"] objectForKey: key] intValue] > 0)
		{
			enabledMenuItems++;
		}
	}
	
	//TODO: Remove this before live to test out unlocking levels.
	//enabledMenuItems = totalMenuItems;
	
	if (!enabledMenuItems)
		enabledMenuItems = 0;
	
	enabledMenuItems += 2;
	
	NSDictionary *levelProgress = [MToolsAppSettings getValueWithName: @"levelProgress"];
	for (int i = 0; i < enabledMenuItems; i++)
	{
		NSString *levelName = [levelsList objectAtIndex: i];
		
		CCSprite *menuItemSprite = [CCSprite spriteWithFile: @"Media/Buttons/general/button_levelselect_background.png"];
		CCSprite *menuItemSpriteSelected = [CCSprite spriteWithFile: @"Media/Buttons/general/button_levelselect_background.png"];
		
		CCLabelTTF *label = [CCLabelTTF labelWithString: [NSString stringWithFormat: @"%d", i + 1] fontName: [Director shared].globalFont fontSize: FONT_SIZE_LEVEL];
		[label setColor: ccBLACK];
		[label setAnchorPoint: ccp(0.5, 0.5)];
		[label setPosition: ccp((menuItemSprite.contentSize.width / 2 + 3) * menuItemSprite.scale, (menuItemSprite.contentSize.height / 2 - 3) * menuItemSprite.scale)];
		[menuItemSprite addChild: label];
		
		label = [CCLabelTTF labelWithString: [NSString stringWithFormat: @"%d", i + 1] fontName: [Director shared].globalFont fontSize: FONT_SIZE_LEVEL];
		[label setColor: ccWHITE];
		[label setAnchorPoint: ccp(0.5, 0.5)];
		[label setPosition: ccp((menuItemSprite.contentSize.width / 2) * menuItemSprite.scale, (menuItemSprite.contentSize.height / 2) * menuItemSprite.scale)];
		[menuItemSprite addChild: label];
		
		menuItem = [CCMenuItemSprite itemWithNormalSprite: menuItemSprite selectedSprite: menuItemSpriteSelected block:^(id sender)
		{
			[Director shared].online = NO;
			[[Director shared] setStageName: [NSString stringWithFormat: @"defaults/%@", [levelName stringByDeletingPathExtension]]];
			[self goToStage];
		}];
		float scale = (s.width * 0.1) / menuItem.contentSize.width;
		[menuItem setScale: scale];
		[menuItem setUserObject: levelName];
		[menuItems addObject: menuItem];
	}
	
	for (int i = enabledMenuItems; i < totalMenuItems; i++)
	{
		CCSprite *menuItemSprite = [CCSprite spriteWithFile: @"Media/Buttons/general/button_levelselect_background_locked.png"];
		CCSprite *menuItemSpriteSelected = [CCSprite spriteWithFile: @"Media/Buttons/general/button_levelselect_background_locked.png"];
		
		menuItem = [CCMenuItemSprite itemWithNormalSprite: menuItemSprite selectedSprite: menuItemSpriteSelected block:^(id sender)
					{
					}];
		float scale = (s.width * 0.1) / menuItem.contentSize.width;
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
			
			//Create stars.
			if (menuItem.userObject)
			{
				for (int stars = 1; stars <= 3; stars++)
				{
					CCSprite *star;
					if ([[levelProgress objectForKey: menuItem.userObject] intValue] >= stars)
					{
						star = [CCSprite spriteWithFile: @"Media/Buttons/general/button_levelselect_star.png"];
					}
					else
					{
						star = [CCSprite spriteWithFile: @"Media/Buttons/general/button_levelselect_star_empty.png"];
					}
					[star setPosition: ccp(
										   (j * s.width) + menuItem.position.x - (menuItem.contentSize.width * menuItem.scaleX) / 3 + ((stars - 1) * ((menuItem.contentSize.width * menuItem.scaleX) / 3)),
										   menuItem.position.y - (menuItem.contentSize.height * menuItem.scaleY) / 3
										   )];
					[star setPosition: ccp(star.position.x + s.width / 2, star.position.y + s.height / 2)];
					[star setScale: ((menuItem.contentSize.width / 2.5) * menuItem.scaleX) / star.contentSize.width];
					
					[self.selectionNode addChild: star z: 66];
				}
			}
			
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
		
		[self.selectionNode addChild: menu z:-1];
	}
	
	[self createPageTurners];
}

- (void) createOnlineLevelList
{	
    [CCMenuItemFont setFontSize: FONT_SIZE];
	CGSize s = [CCDirector sharedDirector].winSize;
    
    NSMutableArray *menuItems = [NSMutableArray array];
    CCMenuItemLabel *menuItem;
    
	NSArray *levelsList;
    switch (self.selectType)
    {
        default:
        case SelectTypeLocal:
        {
			levelsList = [NSArray arrayWithArray: [self onlineLevelsList]];
            break;
        }
		case SelectTypeWorld:
		{
			
			break;
		}
    }
	
	for (int i = 0; i < [levelsList count]; i++)
	{
		NSString *levelName = [levelsList objectAtIndex: i];
		//Level name
		CCLabelTTF *label = [CCLabelTTF labelWithString: [levelName stringByDeletingPathExtension] dimensions: CGSizeMake(s.width / 2, FONT_SIZE * 1.5) hAlignment: kCCTextAlignmentLeft fontName: [Director shared].globalFont fontSize: FONT_SIZE];
		menuItem = [CCMenuItemFont itemWithLabel: label block:^(id sender){
			[Director shared].online = YES;
			[[Director shared] setStageName: [levelName stringByDeletingPathExtension]];
			[self goToStageLoadingLevel];
		}];
		[menuItems addObject: menuItem];
		//[menuItem setAnchorPoint: ccp(0, 0)];
		//[menuItem setPosition: ccp(-[[CCDirector sharedDirector] winSize].width / 2, -i * 24)];
	}
	
	CCMenuAdvanced *menu = [CCMenuAdvanced menuWithArray: menuItems];
	[menu alignItemsVerticallyWithPadding: 0 bottomToTop: YES];
	[menu setBoundaryRect: CGRectMake(-s.width * 0.5, 24, s.width, s.height * 0.9)];
	[menu fixPosition];
	//[menu setPosition:ccp( size.width/2, size.height/2)];
	
	[self.selectionNode addChild: menu z:-1];
}

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

- (NSArray *) localLevelsList
{
	NSMutableArray *levelsList = [NSMutableArray array];
	NSFileManager *fm = [NSFileManager defaultManager];
    
	NSError *error;
	[levelsList addObjectsFromArray: [Director shared].defaultLevelsList];
	
	if (error)
	{
		NSLog(@"CRITICAL ERROR: Could not find anything in the local levels directory: %@", error);
	}
	
	//Removes all "levels" found that don't have the .ctr extension.
	//Sometimes random files crop up in this folder that shouldn't be included with the levels.
	NSMutableArray *levelsToRemove = [NSMutableArray arrayWithCapacity: 1];
	for (NSString *levelName in levelsList)
	{
		if (![[levelName pathExtension] isEqualToString: @"ctr"])
		{
			[levelsToRemove addObject: levelName];
		}
	}
	[levelsList removeObjectsInArray: levelsToRemove];
	
	return levelsList;
}

- (NSArray *) onlineLevelsList
{
	NSMutableArray *levelsList = [NSMutableArray array];
	[levelsList addObjectsFromArray: [[Director shared] onlineLevelsList: 200 withSorting: 0]];
	
	return levelsList;
}

#pragma mark PAGE CONTROLS
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
	CCMoveTo *action = [CCMoveTo actionWithDuration: 0.5 position: ccp((-[Director shared].levelSelectPageNum * s.width), self.selectionNode.position.y)];
	[self.selectionNode stopAllActions];
	[self.selectionNode runAction: action];
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

- (void) goToStage
{
	if (pageTurning)
	{
		return;
	}
	
	[Director shared].editing = NO;
	[[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration: 0.5 scene: [StageLayer scene]]];
}

- (void) goToMainMenu
{
	[[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration: 0.0 scene: [MainMenuLayer scene]]];
}

- (void) goToStageLoadingLevel
{
	[Director shared].editing = NO;
	[[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration: 0.0 scene: [StageLoadingLevel scene]]];
}

@end

