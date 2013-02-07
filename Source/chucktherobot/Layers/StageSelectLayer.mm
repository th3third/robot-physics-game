#import "Layers.h"

#define FONT_SIZE 24
#define TITLE_FONT_SIZE 32

@implementation StageSelectLayer

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
	
	[self addChild: self.selectionNode];
}

- (void) createLocalLevelList
{
	
    [CCMenuItemFont setFontSize: FONT_SIZE];
    
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

	int totalMenuItems = 18;
	int enabledMenuItems = 0;
	for (int i = 0; i < [levelsList count]; i++)
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
			[[Director shared] setStageName: [NSString stringWithFormat: @"defaults/%@", [levelName stringByDeletingPathExtension]]];
			[self goToStage];
		}];
		[menuItems addObject: menuItem];
		//[menuItem setAnchorPoint: ccp(0, 0)];
		//[menuItem setPosition: ccp(-[[CCDirector sharedDirector] winSize].width / 2, i * 24)];
		enabledMenuItems++;
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
	
	CCMenu *menu = [CCMenu menuWithArray: menuItems];
	[menu alignItemsInColumns: [NSNumber numberWithInt: 6], [NSNumber numberWithInt: 6], [NSNumber numberWithInt: 6], nil];
	
	CGSize size = [[CCDirector sharedDirector] winSize];
	[menu setPosition:ccp( size.width/2, size.height/2)];
	
	[self.selectionNode addChild: menu z:-1];
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

