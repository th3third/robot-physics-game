#import "Layers.h"
#import "MToolsAppSettings.h"

#define FONT_SIZE 24
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
		menuItemsPerPage = 18;
		totalMenuItems = 0;
		
		CGSize s = [CCDirector sharedDirector].winSize;
		
		CCLabelTTF *label = [CCLabelTTF labelWithString:@"Select a Level" fontName: [Director shared].globalFont fontSize: TITLE_FONT_SIZE];
		[self addChild:label z:0];
		[label setColor:ccc3(255, 255, 255)];
		label.position = ccp( s.width/2, s.height-50);
		
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
	
	[self.selectionNode setPosition: ccp((-[Director shared].levelSelectPageNum * size.width), 0)];
	
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

	totalMenuItems = [levelsList count];
	int enabledMenuItems = [[MToolsAppSettings getValueWithName: @"maxLevelReached"] intValue];
	//TODO: Remove this before live to test out unlocking levels.
	enabledMenuItems = totalMenuItems;
	
	if (!enabledMenuItems || enabledMenuItems <= 1)
		enabledMenuItems = 2;
	
	for (int i = 0; i < enabledMenuItems; i++)
	{
		NSString *levelName = [levelsList objectAtIndex: i];
		
		CCSprite *menuItemSprite = [CCSprite spriteWithFile: @"Media/Buttons/general/stage_select_button.png"];
		CCSprite *menuItemSpriteSelected = [CCSprite spriteWithFile: @"Media/Buttons/general/stage_select_button_selected.png"];
		CCLabelTTF *label = [CCLabelTTF labelWithString: [NSString stringWithFormat: @"%d", i + 1] fontName: [Director shared].globalFont fontSize: 24];
		[label setColor: ccBLACK];
		[label setAnchorPoint: ccp(0.5, 0.5)];
		[label setPosition: ccp((menuItemSprite.contentSize.width / 2) * menuItemSprite.scale, (menuItemSprite.contentSize.height / 2) * menuItemSprite.scale)];
		[menuItemSprite addChild: label];
		
		menuItem = [CCMenuItemSprite itemWithNormalSprite: menuItemSprite selectedSprite: menuItemSpriteSelected block:^(id sender)
		{
			[Director shared].online = NO;
			[[Director shared] setStageName: [NSString stringWithFormat: @"defaults/%@", [levelName stringByDeletingPathExtension]]];
			[self goToStage];
		}];
		[menuItems addObject: menuItem];
		//[menuItem setAnchorPoint: ccp(0, 0)];
		//[menuItem setPosition: ccp(-[[CCDirector sharedDirector] winSize].width / 2, i * 24)];z
	}
	
	for (int i = enabledMenuItems; i < totalMenuItems; i++)
	{
		CCSprite *menuItemSprite = [CCSprite spriteWithFile: @"Media/Buttons/general/stage_select_button_disabled.png"];
		CCSprite *menuItemSpriteSelected = [CCSprite spriteWithFile: @"Media/Buttons/general/stage_select_button_selected.png"];
		
		menuItem = [CCMenuItemSprite itemWithNormalSprite: menuItemSprite selectedSprite: menuItemSpriteSelected block:^(id sender)
					{
					}];
		[menuItems addObject: menuItem];
	}
	
	for (int j = 0; j < MAX(1, round(totalMenuItems / menuItemsPerPage)); j++)
	{
		NSArray *newMenuItems = [menuItems subarrayWithRange: NSMakeRange((j * menuItemsPerPage), menuItemsPerPage)];
		CCMenu *menu = [CCMenu menuWithArray: newMenuItems];
		[menu alignItemsInColumns: [NSNumber numberWithInt: [newMenuItems count] / 3], [NSNumber numberWithInt: [newMenuItems count] / 3], [NSNumber numberWithInt: [newMenuItems count] / 3], nil];
		
		CGSize size = [[CCDirector sharedDirector] winSize];
		[menu setPosition:ccp( size.width/2 + (size.width * j), size.height/2)];
		
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
	[menuItems addObject: menuItem];
	
	pageMenu = [CCMenu menuWithArray: menuItems];
	[pageMenu alignItemsInRows: [NSNumber numberWithInt: 1], [NSNumber numberWithInt: 1], nil];
	[pageMenu setPosition: ccp(s.width / 2, s.height * 0.15)];
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
	CGSize s = [CCDirector sharedDirector].winSize;
	CCMoveTo *action = [CCMoveTo actionWithDuration: 0.5 position: ccp((-[Director shared].levelSelectPageNum * s.width), self.selectionNode.position.y)];
	[self.selectionNode stopAllActions];
	[self.selectionNode runAction: action];
}

#pragma mark GOTOS

- (void) goToStage
{
	[Director shared].editing = NO;
	[[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration: 0.5 scene: [StageLayer scene]]];
}

- (void) goToMainMenu
{
	[[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration: 0.5 scene: [MainMenuLayer scene]]];
}

- (void) goToStageLoadingLevel
{
	[Director shared].editing = NO;
	[[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration: 0.0 scene: [StageLoadingLevel scene]]];
}

@end

