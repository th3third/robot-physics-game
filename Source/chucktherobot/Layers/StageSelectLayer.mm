#import "Layers.h"
#import "MToolsAppSettings.h"

#define FONT_SIZE 24
#define FONT_SIZE_LEVEL 11
#define FONT_SIZE_LEVEL_LARGE 102
#define FONT_SIZE_TITLE 18
#define FONT_SIZE_TAG 8
#define FONT_SIZE_FILTER 11
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
		[[CCTextureCache sharedTextureCache] removeUnusedTextures];
		
		// enable events
		self.isTouchEnabled = YES;
		
		//Defaults
		filterType = 0;
		
		//Pan gesture recognizer for swiping the menu.
		pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
		CCDirector* director = [CCDirector sharedDirector];
		[[director openGLView] addGestureRecognizer:pan];
		
		CGSize s = [CCDirector sharedDirector].winSize;
		
		//Create the background.
		CCSprite *background = [CCSprite spriteWithFile: @"Media/Backgrounds/general/main_menu.jpg"];
		float scaleX = s.width / background.contentSize.width;
		float scaleY = s.height / background.contentSize.height;
		[background setAnchorPoint: ccp(0, 0)];
		[background setScaleX: scaleX];
		[background setScaleY: scaleY];
		[self addChild: background z: -3];
		
		//Create the list of levels.
		
		//Show the storyboard if this is the first time going to this screen.
		if (![[MToolsAppSettings getValueWithName: @"storyboardPlayed"] boolValue])
		{
			[self startStoryboard];
			[MToolsAppSettings setValue: [NSNumber numberWithBool: YES] withName: @"storyboardPlayed"];
		}
		else
		{
			[self showLevelList];
		}
		
		//Blank out the existing stage, since we're selecting a new one.
		[Director shared].stage = nil;
	}
	return self;
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
		menuItemsPerPage = 10;
		totalMenuItems = 9000;
		[self createOnlineLevelList];
	}
	else
	{
		menuItemsPerPage = 20;
		totalMenuItems = [[self localLevelsList] count];
		[self createLocalLevelList];
	}
	
	[self.selectionNode setPosition: ccp((-[Director shared].levelSelectPageNum * size.width), (size.height * .25) / [Director shared].scaleFactor.height)];
	
	[self addChild: self.selectionNode];
}

- (void) createLocalLevelList
{    
	CGSize s = [CCDirector sharedDirector].winSize;
    NSMutableArray *menuItems = [NSMutableArray array];
    CCMenuItemSprite *menuItem;
    
	botBounds = CGRectMake(
						   s.width * .5, 0,
						   s.width * .95, s.height * .15);
	CGPoint botButtonStart = ccp((s.width - botBounds.size.width) / 2, 0);
	
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
	int highestLevel = 0;
	int totalStars = 0;
	for (id key in [MToolsAppSettings getValueWithName: @"levelProgress"])
	{
		if ([[[MToolsAppSettings getValueWithName: @"levelProgress"] objectForKey: key] intValue] > 0)
		{
			totalStars += [[[MToolsAppSettings getValueWithName: @"levelProgress"] objectForKey: key] intValue];
			NSString *keyName = [key stringByDeletingPathExtension];
			int levelNum = [[keyName substringFromIndex: [keyName length] - 2] intValue];
			if (levelNum > highestLevel)
			{
				highestLevel = levelNum;
			}
		}
	}
	
	//TODO: CHEAT FOR DEV PURPOSES
	highestLevel = 60;
	
	enabledMenuItems = MIN(totalMenuItems, highestLevel + 2);
	
	if (![Director shared].fullVersion)
	{
		enabledMenuItems = MIN(15, enabledMenuItems);
	}
	
	NSDictionary *levelProgress = [MToolsAppSettings getValueWithName: @"levelProgress"];
	for (int i = 0; i < enabledMenuItems; i++)
	{
		NSString *levelName = [levelsList objectAtIndex: i];
		
		CCSprite *menuItemSprite = [CCSprite spriteWithFile: @"Media/Buttons/general/button_levelselect_background.png"];
		CCSprite *menuItemSpriteSelected = [CCSprite spriteWithFile: @"Media/Buttons/general/button_levelselect_background.png"];
		
		int fontSize = menuItemSprite.contentSize.width * 0.5;
		CCLabelTTF *label = [CCLabelTTF labelWithString: [NSString stringWithFormat: @"%d", i + 1] fontName: [Director shared].globalFont fontSize: fontSize];
		[label setColor: ccBLACK];
		[label setAnchorPoint: ccp(0.5, 0.5)];
		[label setPosition: ccp((menuItemSprite.contentSize.width / 2 + 3) * menuItemSprite.scale, (menuItemSprite.contentSize.height / 2 - 3) * menuItemSprite.scale)];
		[menuItemSprite addChild: label];
		
		label = [CCLabelTTF labelWithString: [NSString stringWithFormat: @"%d", i + 1] fontName: [Director shared].globalFont fontSize: fontSize];
		[label setColor: ccWHITE];
		[label setAnchorPoint: ccp(0.5, 0.5)];
		[label setPosition: ccp((menuItemSprite.contentSize.width / 2) * menuItemSprite.scale, (menuItemSprite.contentSize.height / 2) * menuItemSprite.scale)];
		[menuItemSprite addChild: label];
		
		menuItem = [CCMenuItemSprite itemWithNormalSprite: menuItemSprite selectedSprite: menuItemSpriteSelected block:^(id sender)
		{
			[Director shared].localLevelIndex = i;
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
		
		if (i >= 15 && ![Director shared].fullVersion)
		{
			menuItem = [CCMenuItemSprite itemWithNormalSprite: menuItemSprite selectedSprite: menuItemSpriteSelected block:^(id sender)
						{
							[self openPurchaseAd];
						}];
		}
		else
		{
			menuItem = [CCMenuItemSprite itemWithNormalSprite: menuItemSprite selectedSprite: menuItemSpriteSelected block:^(id sender)
					{
					}];
		}
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
		
		[menu setPosition:ccp( s.width/2 + (s.width * j), (s.height / 2))];
		
		[self.selectionNode addChild: menu z:-1];
	}
	
	//BUTTONS FOR SELECTION FILTERING
	//BACK BUTTON (ON SAME BOUNDS AS FILTERING BUTTONS)
	CCSprite *backToMainSprite = [CCSprite spriteWithFile: @"Media/Buttons/general/level_select/button_online_bot_background_1.png"];
	CCSprite *backToMainSpriteSelected = [CCSprite spriteWithFile: @"Media/Buttons/general/level_select/button_online_bot_background_1.png"];
	CCMenuItemSprite *backToMainMenuItem = [CCMenuItemSprite itemWithNormalSprite: backToMainSprite selectedSprite: backToMainSpriteSelected block:^(id sender) {
		[self goToMainMenu];
	}];
	[backToMainMenuItem setScale: ((botBounds.size.width * .25) / backToMainMenuItem.contentSize.width)];
	[backToMainMenuItem setPosition: ccp(botButtonStart.x + (botBounds.size.width * .10), 0)];
	CCLabelTTF *backToMainLabel = [DialogLayer createShadowHeaderWithString: @"MAIN MENU"
																   position: ccp(backToMainMenuItem.position.x, - ((backToMainMenuItem.contentSize.height * backToMainMenuItem.scale) * 0.15))
															   shadowOffset: CGSizeMake(1, -1)
																	  color: ccWHITE
																shadowColor: ccBLACK
																 dimensions: CGSizeMake(backToMainMenuItem.contentSize.width * backToMainMenuItem.scaleX, backToMainMenuItem.contentSize.height * backToMainMenuItem.scaleY)
																 hAlignment: kCCTextAlignmentCenter
															  lineBreakMode: kCCLineBreakModeMiddleTruncation
																   fontSize: FONT_SIZE_FILTER * [Director shared].scaleFactor.width
								   ];
	[backToMainLabel setAnchorPoint: ccp(0.5, 0.5)];
	[self addChild: backToMainLabel z: 101];
	
	CCMenu *botMenu = [CCMenu menuWithItems: backToMainMenuItem, nil];
	[botMenu setAnchorPoint: ccp(0, 0)];
	[botMenu setPosition: CGPointZero];
	[self addChild: botMenu];
	
	[self createPageTurners];
	
	if (![Director shared].fullVersion && enabledMenuItems >= 15)
	{
		[self openPurchaseAd];
	}
	else
	{
		if (enabledMenuItems >= 60)
		{
			if (![MToolsAppSettings getValueWithName: @"completedAllLevels"])
			{
				DialogLayer *winnerDialog = [[DialogLayer alloc] initAllLevelsCompletedWithStars: NO];
				[self addChild: winnerDialog z: 9000];
			}
			
			if (![MToolsAppSettings getValueWithName: @"completedAllLevelsWithStars"] && totalStars >= 180)
			{
				DialogLayer *winnerDialog = [[DialogLayer alloc] initAllLevelsCompletedWithStars: YES];
				[self addChild: winnerDialog z: 9000];
			}
		}
	}
}

- (void) createOnlineLevelList
{
	//Loading elements.
	[self createSpinner];
	
    [CCMenuItemFont setFontSize: FONT_SIZE];
	CGSize s = [CCDirector sharedDirector].winSize;
    
	levelsList = [NSArray arrayWithArray: [self onlineLevelsList]];
	getNewListFromServer = NO;
    
	topBounds = CGRectMake(
								  s.width * .5, s.height * .875,
								  s.width * .95, s.height * .25);
	midBounds = CGRectMake(
								  s.width * .5, s.height * .475,
								  s.width * .95, s.height * .55);
	arrowBounds = CGRectMake(
									s.width * .5, s.height * .15,
									s.width * .95, s.height * .1);
	float arrowBuffer = 2 * [Director shared].scaleFactor.width;
	
	botBounds = CGRectMake(
								  s.width * .5, 0,
								  s.width * .95, s.height * .15);
	CGPoint botButtonStart = ccp((s.width - botBounds.size.width) / 2, 0);
	
	//TOP INFORMATION
	CCSprite *topBackground = [CCSprite spriteWithFile: @"Media/Buttons/general/level_select/button_online_top_background.png"];
	[topBackground setScaleX: topBounds.size.width / topBackground.contentSize.width];
	[topBackground setScaleY: topBounds.size.height / topBackground.contentSize.height];
	[topBackground setPosition: ccp(topBounds.origin.x, topBounds.origin.y)];
	[self addChild: topBackground];
	
	//Level name background.
	titleBackground = [CCSprite spriteWithFile: @"Media/Buttons/general/level_select/button_online_level_name_background.png"];
	[titleBackground setScaleX: (topBounds.size.width * 0.45 / titleBackground.contentSize.width)];
	[titleBackground setScaleY: (topBounds.size.height * 0.45 / titleBackground.contentSize.height)];
	[titleBackground setAnchorPoint: ccp(0, 1)];
	[titleBackground setPosition: ccp(topBounds.origin.x - topBounds.size.width * 0.45, topBounds.origin.y + topBounds.size.height * 0.45)];
	[self addChild: titleBackground];
	
	//Level creator background.
	creatorBackground = [CCSprite spriteWithFile: @"Media/Buttons/general/level_select/button_online_creator_name_background.png"];
	[creatorBackground setScaleX: (topBounds.size.width * 0.45 / creatorBackground.contentSize.width)];
	[creatorBackground setScaleY: (topBounds.size.height * 0.45 / creatorBackground.contentSize.height)];
	[creatorBackground setAnchorPoint: ccp(1, 1)];
	[creatorBackground setPosition: ccp(topBounds.origin.x + topBounds.size.width * 0.45, topBounds.origin.y + topBounds.size.height * 0.45)];
	[self addChild: creatorBackground];
	
	//Thumbs up rating background.
	thumbsUpBackground = [CCSprite spriteWithFile: @"Media/Buttons/general/level_select/button_online_creator_name_background.png"];
	[thumbsUpBackground setScaleX: (topBounds.size.width * 0.20 / thumbsUpBackground.contentSize.width)];
	[thumbsUpBackground setScaleY: (topBounds.size.height * 0.425 / thumbsUpBackground.contentSize.height)];
	[thumbsUpBackground setAnchorPoint: ccp(0, 1)];
	[thumbsUpBackground setPosition: ccp(topBounds.origin.x, topBounds.origin.y)];
	[self addChild: thumbsUpBackground];
	
	//Thumbs up symbol.
	CCSprite *thumbsUpSymbol = [CCSprite spriteWithFile: @"Media/Buttons/general/button_thumbs_up.png"];
	[thumbsUpSymbol setScale: (topBounds.size.height * 0.30 / thumbsUpSymbol.contentSize.height)];
	[thumbsUpSymbol setAnchorPoint: ccp(0, 1)];
	[thumbsUpSymbol setPosition: ccp(topBounds.origin.x, topBounds.origin.y - topBounds.size.height * 0.025)];
	[self addChild: thumbsUpSymbol];
	
	//MIDDLE LEVEL SELECTION
	midBackground = [CCSprite spriteWithFile: @"Media/Buttons/general/level_select/button_online_main_background.png"];
	[midBackground setScaleX: midBounds.size.width / midBackground.contentSize.width];
	[midBackground setScaleY: midBounds.size.height / midBackground.contentSize.height];
	[midBackground setPosition: ccp(midBounds.origin.x, midBounds.origin.y)];
	[self addChild: midBackground z: -1];
	
	//Titles for the level browser.
	CCLabelTTF *nameTitle = [DialogLayer createShadowHeaderWithString: @"LEVEL NAME"
															 position: ccp(midBounds.origin.x - midBounds.size.width * 0.45, midBounds.origin.y - midBounds.size.height * 0.05)
														 shadowOffset: CGSizeMake(1, -1)
																color: ccWHITE
														  shadowColor: ccBLACK
														   dimensions: CGSizeMake(midBounds.size.width * 0.25, midBounds.size.height)
														   hAlignment: kCCTextAlignmentLeft
														lineBreakMode: kCCLineBreakModeMiddleTruncation
															 fontSize: FONT_SIZE_LEVEL * [Director shared].scaleFactor.width
							 ];
	[nameTitle setAnchorPoint: ccp(0, 0.5)];
	[nameTitle setZOrder: 2];
	[self addChild: nameTitle];
	
	CCLabelTTF *creatorTitle = [DialogLayer createShadowHeaderWithString: @"CREATOR"
															 position: ccp(midBounds.origin.x - midBounds.size.width * 0.20, midBounds.origin.y - midBounds.size.height * 0.05)
														 shadowOffset: CGSizeMake(1, -1)
																color: ccWHITE
														  shadowColor: ccBLACK
														   dimensions: CGSizeMake(midBounds.size.width * 0.25, midBounds.size.height)
														   hAlignment: kCCTextAlignmentLeft
														lineBreakMode: kCCLineBreakModeMiddleTruncation
															 fontSize: FONT_SIZE_LEVEL * [Director shared].scaleFactor.width
							 ];
	[creatorTitle setAnchorPoint: ccp(0, 0.5)];
	[creatorTitle setZOrder: 2];
	[self addChild: creatorTitle];
	
	CCLabelTTF *ratingTitle = [DialogLayer createShadowHeaderWithString: @"THUMBS UP"
																position: ccp(midBounds.origin.x, midBounds.origin.y - midBounds.size.height * 0.05)
															shadowOffset: CGSizeMake(1, -1)
																   color: ccWHITE
															 shadowColor: ccBLACK
															  dimensions: CGSizeMake(midBounds.size.width * 0.25, midBounds.size.height)
															  hAlignment: kCCTextAlignmentLeft
														   lineBreakMode: kCCLineBreakModeMiddleTruncation
																fontSize: FONT_SIZE_LEVEL * [Director shared].scaleFactor.width
								];
	[ratingTitle setAnchorPoint: ccp(0, 0.5)];
	[ratingTitle setZOrder: 2];
	[self addChild: ratingTitle];
	
	CCLabelTTF *dateTitle = [DialogLayer createShadowHeaderWithString: @"CREATED"
																position: ccp(midBounds.origin.x + midBounds.size.width * 0.20, midBounds.origin.y - midBounds.size.height * 0.05)
															shadowOffset: CGSizeMake(1, -1)
																   color: ccWHITE
															 shadowColor: ccBLACK
															  dimensions: CGSizeMake(midBounds.size.width * 0.25, midBounds.size.height)
															  hAlignment: kCCTextAlignmentLeft
														   lineBreakMode: kCCLineBreakModeMiddleTruncation
																fontSize: FONT_SIZE_LEVEL * [Director shared].scaleFactor.width
								];
	[dateTitle setAnchorPoint: ccp(0, 0.5)];
	[dateTitle setZOrder: 2];
	[self addChild: dateTitle];
	
	//Position the level selection list sprite, although we won't set it up quite yet.
	if (!onlineLevelListSprite)
		onlineLevelListSprite = [[CCSprite alloc] init];
	//[onlineLevelListSprite setPosition: ccp(midBounds.origin.x, midBounds.origin.y)];
	[self addChild: onlineLevelListSprite];
	
	//Position the level detail  sprite, although we won't set it up quite yet.
	if (!onlineLevelDetailsSprite)
		onlineLevelDetailsSprite = [[CCSprite alloc] init];
	[self addChild: onlineLevelDetailsSprite];
	
	//ARROWS FOR PAGE SELECTION	
	CCSprite *arrowLeftSprite = [CCSprite spriteWithFile: @"Media/Buttons/general/button_left_arrow.png"];
	CCSprite *arrowLeftSelectedSprite = [CCSprite spriteWithFile: @"Media/Buttons/general/button_left_arrow.png"];
	CCMenuItemSprite *arrowLeftMenuItem = [CCMenuItemSprite itemWithNormalSprite: arrowLeftSprite selectedSprite: arrowLeftSelectedSprite block:^(id sender) {
		[self goToPreviousPage: nil];
	}];
	
	[arrowLeftMenuItem setScale: (arrowBounds.size.height / arrowLeftMenuItem.contentSize.height)];
	[arrowLeftMenuItem setPosition: ccp(arrowBounds.origin.x - (arrowLeftMenuItem.contentSize.width * arrowLeftMenuItem.scaleX) - arrowBuffer, arrowBounds.origin.y)];
	[arrowLeftMenuItem setTag: 0];
	
	CCSprite *arrowRightSprite = [CCSprite spriteWithFile: @"Media/Buttons/general/button_right_arrow.png"];
	CCSprite *arrowRightSelectedSprite = [CCSprite spriteWithFile: @"Media/Buttons/general/button_right_arrow.png"];
	CCMenuItemSprite *arrowRightMenuItem = [CCMenuItemSprite itemWithNormalSprite: arrowRightSprite selectedSprite: arrowRightSelectedSprite block:^(id sender) {
		[self goToNextPage: nil];
	}];
	[arrowRightMenuItem setScale: (arrowBounds.size.height / arrowRightMenuItem.contentSize.height)];
	[arrowRightMenuItem setPosition: ccp(arrowBounds.origin.x + (arrowRightMenuItem.contentSize.width * arrowRightMenuItem.scaleX) + arrowBuffer, arrowBounds.origin.y)];
	[arrowRightMenuItem setTag: 1];
	
	CCMenu *arrowMenu = [CCMenu menuWithItems: arrowLeftMenuItem, arrowRightMenuItem, nil];
	[arrowMenu setAnchorPoint: ccp(0, 0)];
	[arrowMenu setPosition: CGPointZero];
	pageMenu = arrowMenu;
	[self addChild: arrowMenu];
	
	//BUTTONS FOR SELECTION FILTERING
	//BACK BUTTON (ON SAME BOUNDS AS FILTERING BUTTONS)
	CCSprite *backToMainSprite = [CCSprite spriteWithFile: @"Media/Buttons/general/level_select/button_online_bot_background_1.png"];
	CCSprite *backToMainSpriteSelected = [CCSprite spriteWithFile: @"Media/Buttons/general/level_select/button_online_bot_background_1.png"];
	CCMenuItemSprite *backToMainMenuItem = [CCMenuItemSprite itemWithNormalSprite: backToMainSprite selectedSprite: backToMainSpriteSelected block:^(id sender) {
		[self goToMainMenu];
	}];
	[backToMainMenuItem setScale: ((botBounds.size.width * .25) / backToMainMenuItem.contentSize.width)];
	[backToMainMenuItem setPosition: ccp(botButtonStart.x + (botBounds.size.width * .10), 0)];
	CCLabelTTF *backToMainLabel = [DialogLayer createShadowHeaderWithString: @"MAIN MENU"
																   position: ccp(backToMainMenuItem.position.x, - ((backToMainMenuItem.contentSize.height * backToMainMenuItem.scale) * 0.15))
															   shadowOffset: CGSizeMake(1, -1)
																	  color: ccWHITE
																shadowColor: ccBLACK
																 dimensions: CGSizeMake(backToMainMenuItem.contentSize.width * backToMainMenuItem.scaleX, backToMainMenuItem.contentSize.height * backToMainMenuItem.scaleY)
																 hAlignment: kCCTextAlignmentCenter
															  lineBreakMode: kCCLineBreakModeMiddleTruncation
																   fontSize: FONT_SIZE_FILTER * [Director shared].scaleFactor.width
								   ];
	[backToMainLabel setAnchorPoint: ccp(0.5, 0.5)];
	[self addChild: backToMainLabel z: 101];
	
	//Newest levels filter (default)
	CCSprite *newestLevelsSprite = [CCSprite spriteWithFile: @"Media/Buttons/general/level_select/button_online_bot_background_2.png"];
	CCSprite *newestLevelsSelectedSprite = [CCSprite spriteWithFile: @"Media/Buttons/general/level_select/button_online_bot_background_2.png"];
	CCMenuItemSprite *newestLevelsMenuItem = [CCMenuItemSprite itemWithNormalSprite: newestLevelsSprite selectedSprite: newestLevelsSelectedSprite block:^(id sender) {
		[self setFilter: 0];
	}];
	[newestLevelsMenuItem setScale: ((botBounds.size.width * .2) / backToMainMenuItem.contentSize.width)];
	[newestLevelsMenuItem setPosition: ccp(botButtonStart.x + (botBounds.size.width * .50), 0)];
	CCLabelTTF *newestLevelsLabel = [DialogLayer createShadowHeaderWithString: @"NEWEST"
																   position: ccp(newestLevelsMenuItem.position.x, - ((newestLevelsMenuItem.contentSize.height * newestLevelsMenuItem.scale) * 0.15))
															   shadowOffset: CGSizeMake(1, -1)
																	  color: ccWHITE
																shadowColor: ccBLACK
																 dimensions: CGSizeMake(backToMainMenuItem.contentSize.width * backToMainMenuItem.scaleX, backToMainMenuItem.contentSize.height * backToMainMenuItem.scaleY)
																 hAlignment: kCCTextAlignmentCenter
															  lineBreakMode: kCCLineBreakModeMiddleTruncation
																   fontSize: (FONT_SIZE_FILTER * [Director shared].scaleFactor.width)
								   ];
	[newestLevelsLabel setAnchorPoint: ccp(0.5, 0.5)];
	[self addChild: newestLevelsLabel z: 101];
	
	//Popular levels filter
	CCSprite *popularLevelsSprite = [CCSprite spriteWithFile: @"Media/Buttons/general/level_select/button_online_bot_background_1.png"];
	CCSprite *popularLevelsSelectedSprite = [CCSprite spriteWithFile: @"Media/Buttons/general/level_select/button_online_bot_background_1.png"];
	CCMenuItemSprite *popularLevelsMenuItem = [CCMenuItemSprite itemWithNormalSprite: popularLevelsSprite selectedSprite: popularLevelsSelectedSprite block:^(id sender) {
		[self setFilter: 1];
	}];
	[popularLevelsMenuItem setScale: ((botBounds.size.width * .2) / backToMainMenuItem.contentSize.width)];
	[popularLevelsMenuItem setPosition: ccp(botButtonStart.x + (botBounds.size.width * .70), 0)];
	CCLabelTTF *popularLevelsLabel = [DialogLayer createShadowHeaderWithString: @"POPULAR"
																	 position: ccp(popularLevelsMenuItem.position.x, - ((popularLevelsMenuItem.contentSize.height * popularLevelsMenuItem.scale) * 0.15))
																 shadowOffset: CGSizeMake(1, -1)
																		color: ccWHITE
																  shadowColor: ccBLACK
																   dimensions: CGSizeMake(backToMainMenuItem.contentSize.width * backToMainMenuItem.scaleX, backToMainMenuItem.contentSize.height * backToMainMenuItem.scaleY)
																   hAlignment: kCCTextAlignmentCenter
																lineBreakMode: kCCLineBreakModeMiddleTruncation
																	 fontSize: (FONT_SIZE_FILTER * [Director shared].scaleFactor.width)
									 ];
	[popularLevelsLabel setAnchorPoint: ccp(0.5, 0.5)];
	[self addChild: popularLevelsLabel z: 101];
	
	//Best rated
	CCSprite *bestRatedLevelsSprite = [CCSprite spriteWithFile: @"Media/Buttons/general/level_select/button_online_bot_background_2.png"];
	CCSprite *bestRatedLevelsSelectedSprite = [CCSprite spriteWithFile: @"Media/Buttons/general/level_select/button_online_bot_background_2.png"];
	CCMenuItemSprite *bestRatedLevelsMenuItem = [CCMenuItemSprite itemWithNormalSprite: bestRatedLevelsSprite selectedSprite: bestRatedLevelsSelectedSprite block:^(id sender) {
		[self setFilter: 2];
	}];
	[bestRatedLevelsMenuItem setScale: ((botBounds.size.width * .2) / backToMainMenuItem.contentSize.width)];
	[bestRatedLevelsMenuItem setPosition: ccp(botButtonStart.x + (botBounds.size.width * .90), 0)];
	CCLabelTTF *bestRatedLevelsLabel = [DialogLayer createShadowHeaderWithString: @"TOP RATED"
																	  position: ccp(bestRatedLevelsMenuItem.position.x, - ((bestRatedLevelsMenuItem.contentSize.height * bestRatedLevelsMenuItem.scale) * 0.15))
																  shadowOffset: CGSizeMake(1, -1)
																		 color: ccWHITE
																   shadowColor: ccBLACK
																	dimensions: CGSizeMake(backToMainMenuItem.contentSize.width * backToMainMenuItem.scaleX, backToMainMenuItem.contentSize.height * backToMainMenuItem.scaleY)
																	hAlignment: kCCTextAlignmentCenter
																 lineBreakMode: kCCLineBreakModeMiddleTruncation
																	  fontSize: (FONT_SIZE_FILTER * [Director shared].scaleFactor.width)
									  ];
	[bestRatedLevelsLabel setAnchorPoint: ccp(0.5, 0.5)];
	[self addChild: bestRatedLevelsLabel z: 101];
	
	CCMenu *botMenu = [CCMenu menuWithItems: backToMainMenuItem, newestLevelsMenuItem, popularLevelsMenuItem, bestRatedLevelsMenuItem, nil];
	[botMenu setAnchorPoint: ccp(0, 0)];
	[botMenu setPosition: CGPointZero];
	[self addChild: botMenu];
	
	//Update all the menus!
	if ([levelsList count] > 0)
	{
		NSArray *level = [levelsList objectAtIndex: 0];
		[self setOnlineLevelName: [level objectAtIndex: 0]];
		selectedLevelIndex = 0;
		[self performSelectorInBackground: @selector(setUpdating:) withObject: [NSNumber numberWithBool: YES]];
		[self updateOnlineLevelList];
	}
}

- (void) updateOnlineLevelList
{	
	//Flushing out the online level list needs to be done or we'll get artifacts.
	[onlineLevelListSprite removeAllChildrenWithCleanup: YES];
	
	CGSize s = [CCDirector sharedDirector].winSize;
	
	if (getNewListFromServer)
		levelsList = [self onlineLevelsList];
	
	if (!levelsList || [levelsList count] <= 0)
	{
		DialogLayer *noLevelsDialog = [[DialogLayer alloc] initNotificationWithMessage: @"No levels were obtained from the server. You probably reached the end of the list."];
		[self addChild: noLevelsDialog z: 9000];
		 return;
	}
	
	NSMutableArray *menuItems = [NSMutableArray array];
	
	for (int i = 0; i < [levelsList count]; i++)
	{
		NSArray *level = [levelsList objectAtIndex: i];
		
		//Begin the render texture. We're going to draw all the elements in a single texture so it will fit nicer.
		CCRenderTexture *renderTextureNormal = [CCRenderTexture renderTextureWithWidth: midBounds.size.width * 0.9 height: midBounds.size.height * 0.075];
		
		if (selectedLevelIndex == i)
			[renderTextureNormal beginWithClear: 1 g: 1 b: 1 a: 0.3];
		else
			[renderTextureNormal beginWithClear: 1 g: 1 b: 1 a: 0];
		
		//Level name		
		CCLabelTTF *name = [DialogLayer createShadowHeaderWithString: [level objectAtIndex: 0]
															position: ccp(0, -s.height / 2)
														shadowOffset: CGSizeMake(1, -1)
															   color: ccWHITE
														 shadowColor: ccBLACK
														  dimensions: CGSizeMake(midBounds.size.width * 0.25, midBounds.size.height)
														  hAlignment: kCCTextAlignmentLeft
													   lineBreakMode: kCCLineBreakModeMiddleTruncation
															fontSize: FONT_SIZE_LEVEL * [Director shared].scaleFactor.width
							];
		[name setAnchorPoint:ccp(0, 0)];
		[name visit];
		
		//Creator
		CCLabelTTF *creator = [DialogLayer createShadowHeaderWithString: [level objectAtIndex: 1]
															position: ccp(midBounds.size.width * 0.25, -s.height / 2)
														shadowOffset: CGSizeMake(1, -1)
															   color: ccWHITE
														 shadowColor: ccBLACK
														  dimensions: CGSizeMake(midBounds.size.width * 0.25, midBounds.size.height)
														  hAlignment: kCCTextAlignmentLeft
													   lineBreakMode: kCCLineBreakModeMiddleTruncation
															fontSize: FONT_SIZE_LEVEL * [Director shared].scaleFactor.width
							];
		[creator setAnchorPoint:ccp(0, 0)];
		[creator visit];
		
		//Rating
		CCLabelTTF *rating = [DialogLayer createShadowHeaderWithString: [NSString stringWithFormat: @"%2@%%", [level objectAtIndex: 2]]
															   position: ccp(midBounds.size.width * 0.50, -s.height / 2)
														   shadowOffset: CGSizeMake(1, -1)
																  color: ccWHITE
															shadowColor: ccBLACK
															 dimensions: CGSizeMake(midBounds.size.width * 0.15, midBounds.size.height)
															 hAlignment: kCCTextAlignmentLeft
														  lineBreakMode: kCCLineBreakModeMiddleTruncation
															   fontSize: FONT_SIZE_LEVEL * [Director shared].scaleFactor.width
							   ];
		[rating setAnchorPoint:ccp(0, 0)];
		[rating visit];
		
		//Date modified
		NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
		[dateFormat setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
		NSDate *formattedDate = [dateFormat dateFromString: [level objectAtIndex: 3]];
		[dateFormat setDateFormat: @"MMM d, yyyy"];
		NSString *formattedDateString = [dateFormat stringFromDate: formattedDate];
		
		CCLabelTTF *date = [DialogLayer createShadowHeaderWithString: formattedDateString
															   position: ccp(midBounds.size.width * 0.65, -s.height / 2)
														   shadowOffset: CGSizeMake(1, -1)
																  color: ccWHITE
															shadowColor: ccBLACK
															 dimensions: CGSizeMake(midBounds.size.width * 0.35, midBounds.size.height)
															 hAlignment: kCCTextAlignmentLeft
														  lineBreakMode: kCCLineBreakModeMiddleTruncation
															   fontSize: FONT_SIZE_LEVEL * [Director shared].scaleFactor.width
							   ];
		[date setAnchorPoint:ccp(0, 0)];
		[date visit];
		
		//End render texture.
		[renderTextureNormal end];
		
		CCSprite *itemSpriteNormal = [CCSprite spriteWithTexture: renderTextureNormal.sprite.texture];
		CCSprite *itemSpriteSelected = [CCSprite spriteWithTexture: renderTextureNormal.sprite.texture];
		CCMenuItemSprite *menuItem = [CCMenuItemSprite itemWithNormalSprite: itemSpriteNormal selectedSprite: itemSpriteSelected block:^(id sender) {
			[self updateLevelDetails: level];
			[self setOnlineLevelName: [level objectAtIndex: 0]];
			selectedLevelIndex = i;
			getNewListFromServer = NO;
			[self updateOnlineLevelList];
		}];
		[menuItem setScaleY: -1];
		[menuItem setPosition: ccp(0, -(midBounds.size.height * 0.0425) -(midBounds.size.height * 0.075) * i)];
		[menuItems addObject: menuItem];
	}
	
	CCMenu *menu = [CCMenu menuWithArray: menuItems];
	[menu setPosition: ccp(s.width / 2, midBounds.origin.y + (midBounds.size.height * 0.375))];
	
	[onlineLevelListSprite addChild: menu];
	[onlineLevelListSprite setZOrder: 2];
	[midBackground setZOrder: 1];
	
	//Update the details.
	[self updateLevelDetails: [levelsList objectAtIndex: selectedLevelIndex]];
	
	[[pageMenu getChildByTag: 0] setVisible: YES];
	[[pageMenu getChildByTag: 1] setVisible: YES];
	
	if ([Director shared].levelSelectPageNum <= 0)
	{
		[[pageMenu getChildByTag: 0] setVisible: NO];
	}
	if ([levelsList count] < 10)
	{
		[[pageMenu getChildByTag: 1] setVisible: NO];
	}
}

- (void) updateLevelDetails: (NSArray *) level
{
	CGSize s = [CCDirector sharedDirector].winSize;
	
	[onlineLevelDetailsSprite removeAllChildrenWithCleanup: YES];
	
	//Level name.
	CCLabelTTF *levelName = [DialogLayer createShadowHeaderWithString: [level objectAtIndex: 0]
															 position: ccp(titleBackground.position.x + (topBounds.size.width * 0.025), titleBackground.position.y - (topBounds.size.height * 0.225))
														 shadowOffset: CGSizeMake(1, -1)
																color: ccWHITE
														  shadowColor: ccBLACK
														   dimensions: CGSizeMake(titleBackground.contentSize.width * titleBackground.scaleX, titleBackground.contentSize.height * titleBackground.scaleY)
														   hAlignment: kCCTextAlignmentLeft
														lineBreakMode: kCCLineBreakModeMiddleTruncation
															 fontSize: FONT_SIZE_TITLE * [Director shared].scaleFactor.width
							 ];
	[levelName setAnchorPoint: ccp(0, 0.5)];
	[onlineLevelDetailsSprite addChild: levelName];
	
	//Creator name.
	CCLabelTTF *creatorName = [DialogLayer createShadowHeaderWithString: [NSString stringWithFormat: @"By: %@", [level objectAtIndex: 1]]
															 position: ccp(creatorBackground.position.x + (topBounds.size.width * 0.025), creatorBackground.position.y - (topBounds.size.height * 0.225))
														 shadowOffset: CGSizeMake(1, -1)
																color: ccWHITE
														  shadowColor: ccBLACK
														   dimensions: CGSizeMake(creatorBackground.contentSize.width * creatorBackground.scaleX, creatorBackground.contentSize.height * creatorBackground.scaleY)
														   hAlignment: kCCTextAlignmentLeft
														lineBreakMode: kCCLineBreakModeMiddleTruncation
															 fontSize: FONT_SIZE_TITLE * [Director shared].scaleFactor.width
							 ];
	[creatorName setAnchorPoint: ccp(1, 0.5)];
	[onlineLevelDetailsSprite addChild: creatorName];
	
	//Tags.
	NSArray *tags = [[level objectAtIndex: 4] componentsSeparatedByString: @","];
	
	int row = 0;
	int col = 0;
	for (NSString *tag in tags)
	{
		if (![tag isEqualToString: @""])
		{
			CCSprite *tagSprite;
			
			if (col % 2 == 0)
				tagSprite = [CCSprite spriteWithFile: @"Media/Buttons/general/tags/tag_blank_1.png"];
			else
				tagSprite = [CCSprite spriteWithFile: @"Media/Buttons/general/tags/tag_blank_2.png"];
			
			[tagSprite setScaleX: topBounds.size.width * 0.1125 / tagSprite.contentSize.width];
			[tagSprite setScaleY: topBounds.size.height * 0.225 / tagSprite.contentSize.height];
			[tagSprite setPosition: ccp(topBounds.origin.x - topBounds.size.width * 0.40 + (col * topBounds.size.width * .1125), topBounds.origin.y - topBounds.size.height * 0.08 - (row * topBounds.size.height * .205))];
			[tagSprite setAnchorPoint: ccp(0.5, 0.5)];
			[onlineLevelDetailsSprite addChild: tagSprite];
			
			CCLabelTTF *tagLabel = [DialogLayer createShadowHeaderWithString: tag
																	position: ccp(tagSprite.position.x, tagSprite.position.y - topBounds.size.height * 0.09)
																shadowOffset: CGSizeMake(1, -1)
																	   color: ccWHITE
																 shadowColor: ccBLACK
																  dimensions: CGSizeMake(creatorBackground.contentSize.width * creatorBackground.scaleX, creatorBackground.contentSize.height * creatorBackground.scaleY)
																  hAlignment: kCCTextAlignmentCenter
															   lineBreakMode: kCCLineBreakModeMiddleTruncation
																	fontSize: FONT_SIZE_TAG * [Director shared].scaleFactor.width
									];
			[tagLabel setAnchorPoint: ccp(0.5, 0.5)];
			[onlineLevelDetailsSprite addChild: tagLabel];
			
			col++;
			
			if (col == 4)
			{
				col = 0;
				row++;
			}
		}
	}
	
	//Thumbs up rating.
	CCLabelTTF *thumbsUpAmount = [DialogLayer createShadowHeaderWithString: [NSString stringWithFormat: @"%@%%", [level objectAtIndex: 2]]
															   position: ccp(topBounds.origin.x + topBounds.size.width * -0.025, topBounds.origin.y + topBounds.size.height * 0.025)
														   shadowOffset: CGSizeMake(1, -1)
																  color: ccWHITE
															shadowColor: ccBLACK
															 dimensions: CGSizeMake(thumbsUpBackground.contentSize.width * thumbsUpBackground.scaleX, thumbsUpBackground.contentSize.height * creatorBackground.scaleY)
															 hAlignment: kCCTextAlignmentRight
														  lineBreakMode: kCCLineBreakModeMiddleTruncation
															   fontSize: FONT_SIZE_TITLE * [Director shared].scaleFactor.width
							   ];
	[thumbsUpAmount setAnchorPoint: ccp(0, 1)];
	[onlineLevelDetailsSprite addChild: thumbsUpAmount];
	
	//Play button and menu.
	CCSprite *playButton = [CCSprite spriteWithFile: @"Media/Buttons/general/level_select/button_online_play.png"];
	CCSprite *playButtonSelected = [CCSprite spriteWithFile: @"Media/Buttons/general/level_select/button_online_play.png"];
	
	CCMenuItemSprite *playButtonMenuItem = [CCMenuItemSprite itemWithNormalSprite: playButton selectedSprite: playButtonSelected block:^(id sender) {
		[Director shared].online = YES;
		[self goToStage];
	}];
	[playButtonMenuItem setScaleX: (topBounds.size.width * 0.15 / playButtonMenuItem.contentSize.width)];
	[playButtonMenuItem setScaleY: (topBounds.size.height * 0.425 / playButtonMenuItem.contentSize.height)];
	[playButtonMenuItem setAnchorPoint: ccp(1, 1)];
	[playButtonMenuItem setPosition: ccp(topBounds.origin.x + topBounds.size.width * 0.45, topBounds.origin.y)];
	
	CCMenu *playLevelMenu = [CCMenu menuWithItems: playButtonMenuItem, nil];
	[playLevelMenu setPosition: ccp(0, 0)];
	[onlineLevelDetailsSprite addChild: playLevelMenu z: 66];
}

- (void) createPageTurners
{
	//Create the arrows to flip back and forth through the menus.
	CGSize s = [CCDirector sharedDirector].winSize;
	NSMutableArray *menuItems = [NSMutableArray array];
	CCMenuItemSprite *menuItem;
	CCSprite *menuItemSprite;
	CCSprite *menuItemSpriteSelected;
	
	menuItemSprite = [CCSprite spriteWithFile: @"Media/Buttons/general/button_left_arrow.png"];
	menuItemSpriteSelected = [CCSprite spriteWithFile: @"Media/Buttons/general/button_left_arrow.png"];
	menuItem = [CCMenuItemSprite itemWithNormalSprite: menuItemSprite selectedSprite: menuItemSpriteSelected block:^(id sender) {
		[self goToPreviousPage: menuItem];
	}];
	[menuItem setTag: 0];
	if ([Director shared].levelSelectPageNum <= 0)
	{
		[menuItem setVisible: NO];
	}
	[menuItem setScale: ((s.width * 0.1) / menuItem.contentSize.width)];
	[menuItem setPosition: ccp((-s.width / 2) + (menuItem.contentSize.width * menuItem.scaleX) / 2, 0)];
	[menuItems addObject: menuItem];
	
	menuItemSprite = [CCSprite spriteWithFile: @"Media/Buttons/general/button_right_arrow.png"];
	menuItemSpriteSelected = [CCSprite spriteWithFile: @"Media/Buttons/general/button_right_arrow.png"];
	menuItem = [CCMenuItemSprite itemWithNormalSprite: menuItemSprite selectedSprite: menuItemSpriteSelected block:^(id sender) {
		[self goToNextPage: menuItem];
	}];
	[menuItem setTag: 1];
	if ([Director shared].levelSelectPageNum >= totalMenuItems / menuItemsPerPage)
	{
		[menuItem setVisible: NO];
	}
	[menuItem setScale: ((s.width * 0.1) / menuItem.contentSize.width)];
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
	NSArray *newLevels = [[Director shared] onlineLevelsList: ([Director shared].levelSelectPageNum * 10) withSorting: filterType];
	
	if (!newLevels || [newLevels count] <= 0)
	{
		DialogLayer *noLevelsDialog = [[DialogLayer alloc] initNotificationWithMessage: @"No levels were obtained from the server. There may be issues right now, sorry!"];
		[self addChild: noLevelsDialog z: 9000];
		return nil;
	}
	
	[levelsList addObjectsFromArray: newLevels];
	
	return levelsList;
}

#pragma mark STORYBOARD

//Display the storyboard and start off all of the other methods that we will need to advance through it.
//This should play automatically the first time they run the game.
- (void) startStoryboard
{
	playingStoryboard = YES;
	
	CCSprite *container = [[CCSprite alloc] init];
	
	CGSize s = [CCDirector sharedDirector].winSize;

	CCSprite *storyboardBackground = [CCSprite spriteWithFile: @"Media/Backgrounds/wallpaper/1.jpg"];
	CCSprite *panel1 = [CCSprite spriteWithFile: @"Media/Backgrounds/general/storyboard/1.png"];
	CCSprite *panel2 = [CCSprite spriteWithFile: @"Media/Backgrounds/general/storyboard/2.png"];
	CCSprite *panel3 = [CCSprite spriteWithFile: @"Media/Backgrounds/general/storyboard/3.png"];
	CCSprite *panel4 = [CCSprite spriteWithFile: @"Media/Backgrounds/general/storyboard/4.png"];
	CCSprite *panel5 = [CCSprite spriteWithFile: @"Media/Backgrounds/general/storyboard/5.png"];
	
	//Add all the sprites to the container.
	[container addChild: storyboardBackground z: 0];
	[container addChild: panel1 z: 5];
	[container addChild: panel2 z: 4];
	[container addChild: panel3 z: 3];
	[container addChild: panel4 z: 2];
	[container addChild: panel5 z: 1];
	
	//Tag the panels to keep track of them.
	[storyboardBackground setTag: 0];
	[panel1 setTag: 1];
	[panel2 setTag: 2];
	[panel3 setTag: 3];
	[panel4 setTag: 4];
	[panel5 setTag: 5];
	
	//Positioning for all the elements.
	[storyboardBackground setPosition: ccp(s.width * 0.5, s.height * 0.5)];
	[panel1 setPosition:ccp(123 * [Director shared].scaleFactor.width, (320 - 84) * [Director shared].scaleFactor.height)];
	[panel2 setPosition:ccp(337 * [Director shared].scaleFactor.width, (320 - 90) * [Director shared].scaleFactor.height)];
	[panel3 setPosition:ccp(323 * [Director shared].scaleFactor.width, (320 - 189) * [Director shared].scaleFactor.height)];
	[panel4 setPosition:ccp(110 * [Director shared].scaleFactor.width, (320 - 215) * [Director shared].scaleFactor.height)];
	[panel5 setPosition:ccp(257 * [Director shared].scaleFactor.width, (320 - 284) * [Director shared].scaleFactor.height)];
	
	//Scaling for everyone!
	float scale = ((0.46f * s.width) / panel1.contentSize.width);
	[storyboardBackground setScaleX: (s.width / storyboardBackground.contentSize.width)];
	[storyboardBackground setScaleY: (s.height / storyboardBackground.contentSize.height)];
	[panel1 setScale: scale];
	[panel2 setScale: scale];
	[panel3 setScale: scale];
	[panel4 setScale: scale];
	[panel5 setScale: scale];
	
	//Opacity for everyone starts at 0.
	[panel1 setOpacity: 0];
	[panel2 setOpacity: 0];
	[panel3 setOpacity: 0];
	[panel4 setOpacity: 0];
	[panel5 setOpacity: 0];
	
	CCSprite *itemSprite = [CCSprite spriteWithFile: @"Media/Backgrounds/blank.jpg"];
	CCSprite *itemSpriteSelected = [CCSprite spriteWithFile: @"Media/Backgrounds/blank.jpg"];
	CCMenuItemSprite *containerMenuItem = [CCMenuItemSprite itemWithNormalSprite: itemSprite selectedSprite: itemSpriteSelected block:^(id sender) {
		for (int i = 0; i < [[container children] count]; i++)
		{			
			CCSprite *child = (CCSprite *)[container getChildByTag: i];
			if (child.tag != 0 && child.opacity <= 0)
			{
				[DialogLayer playButtonSound];
				CCSprite *prevChild = (CCSprite *)[container getChildByTag: i - 1];
				[prevChild setOpacity: 255];
				
				[self fadeInSprite: child duration: 1.0f];
				
				return;
			}
			
			if (i == [[container children] count] - 1)
			{
				[DialogLayer playButtonSound];
				playingStoryboard = NO;
				[container removeFromParentAndCleanup: YES];
				[self showLevelList];
				
				return;
			}
		}
	}];
	[containerMenuItem setScaleX: (s.width / containerMenuItem.contentSize.width)];
	[containerMenuItem setScaleY: (s.height / containerMenuItem.contentSize.height)];
	[containerMenuItem setOpacity: 0];
	[containerMenuItem setPosition: ccp(s.width * 0.5, s.height * 0.5)];
	
	CCMenu *menu = [CCMenu menuWithItems: containerMenuItem, nil];
	[menu setAnchorPoint: ccp(0, 0)];
	[menu setPosition: CGPointZero];
	
	[self addChild: container z: 8999];
	[self performSelector: @selector(fadeInSprite:duration:) withObject: panel1 afterDelay: 1.0f];
	
	[container addChild: menu z: 9000];
}

- (void) fadeInSprite: (CCSprite *) sprite duration: (float) duration
{
	if (!sprite)
		return;

	if (!duration || duration <= 0.01f)
		duration = 1.0f;

	CCActionTween *tween = [CCActionTween actionWithDuration: duration key: @"opacity" from: 0 to: 255];
	[sprite runAction: tween];
}

- (void) fadeOutSprite: (CCSprite *) sprite duration: (float) duration
{
	if (!sprite)
		return;
	
	if (!duration || duration <= 0.01f)
		duration = 1.0f;
	
	CCActionTween *tween = [CCActionTween actionWithDuration: duration key: @"opacity" from: 255 to: 0];
	[sprite runAction: tween];
}

#pragma mark ONLINE LEVEL CONTROLS

- (void) setFilter: (int) newFilter
{
	[Director shared].levelSelectPageNum = 0;
	filterType = newFilter;
	[onlineLevelListSprite removeAllChildrenWithCleanup: YES];
	[midBackground setZOrder: -1];
	selectedLevelIndex = 0;
	getNewListFromServer = YES;
	[self performSelector: @selector(updateOnlineLevelList) withObject: nil afterDelay: 0.1];
}

- (void) setOnlineLevelName: (NSString *) name
{
	[[Director shared] setStageName: name];
}

#pragma  mark LOADING SPINNER

- (void) setUpdating: (NSNumber *) value
{
	updatingLevelList = [value boolValue];
	
	if (updatingLevelList)
	{
		[spinner setVisible: YES];
	}
	else
	{
		[spinner setVisible: NO];
	}
}

- (void) createSpinner
{
	CGSize s = [CCDirector sharedDirector].winSize;
	
	CCLabelTTF *spinnerLabel = [DialogLayer createShadowHeaderWithString: @"Loading..."
																position: ccp(s.width * 0.5, s.height * 0.5)
															shadowOffset: CGSizeMake(1, -1)
																   color: ccWHITE
															 shadowColor: ccBLACK
															  dimensions: CGSizeMake(midBackground.contentSize.width * midBackground.scaleX, midBackground.contentSize.height * midBackground.scaleY)
															  hAlignment: kCCTextAlignmentCenter
								vAlignment: kCCVerticalTextAlignmentCenter
														   lineBreakMode: kCCLineBreakModeMiddleTruncation
																fontSize: FONT_SIZE_LEVEL * 2 * [Director shared].scaleFactor.width
								];
	
	[self addChild: spinnerLabel z: 0];
}

#pragma mark PAGE CONTROLS
- (void) goToPreviousPage: (id) caller
{
	if (pageTurning || [Director shared].levelSelectPageNum <= 0 || playingStoryboard)
		return;
	
	[Director shared].levelSelectPageNum = MAX(0, [Director shared].levelSelectPageNum - 1);
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
	if (pageTurning || [Director shared].levelSelectPageNum >= (totalMenuItems - 1) / menuItemsPerPage || playingStoryboard)
		return;
	
	[Director shared].levelSelectPageNum = ([Director shared].levelSelectPageNum + 1);
	[[pageMenu getChildByTag: 0] setVisible: YES];
	
	if ([Director shared].levelSelectPageNum >= (totalMenuItems - 1) / menuItemsPerPage)
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
	
	if ([Director shared].online)
	{
		[onlineLevelListSprite removeAllChildrenWithCleanup: YES];
		[midBackground setZOrder: -1];
		selectedLevelIndex = 0;
		getNewListFromServer = YES;
		[self performSelector: @selector(updateOnlineLevelList) withObject: nil afterDelay: 0.1];
	}
	else
	{
		CGSize s = [CCDirector sharedDirector].winSize;
		CCMoveTo *action = [CCMoveTo actionWithDuration: 0.5 position: ccp((-[Director shared].levelSelectPageNum * s.width), self.selectionNode.position.y)];
		[self.selectionNode stopAllActions];
		[self.selectionNode runAction: action];
	}
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

#pragma mark PURCHASING

- (void) openPurchaseAd
{
	DialogLayer *purchaseDialog = [[DialogLayer alloc] initNotificationWithMessage: @"To play more than 15 levels you will need the full game, available from the in-app purchase menu." callback: self selector: @selector(openPurchaseDialog)];
	[self addChild: purchaseDialog z: 9000];
}

- (void) openPurchaseDialog
{
	DialogLayer *purchaseDialog = [[DialogLayer alloc] initPurchaseWithCallbackObj: self selector: @selector(madePurchase:)];
	[self addChild: purchaseDialog z: 9000];
}


#pragma mark GOTOS

- (void) goToStage
{
	if (pageTurning)
	{
		return;
	}
	
	[DialogLayer playButtonSound];
	[[Director shared] stopMusic];
	
	CCDirector* director = [CCDirector sharedDirector];
	[[director openGLView] removeGestureRecognizer: pan];
	
	[Director shared].editing = NO;
	[[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration: 0.0 scene: [StageLoadingLevel scene]]];
}

- (void) goToMainMenu
{
	[DialogLayer playButtonSound];
	
	CCDirector* director = [CCDirector sharedDirector];
	[[director openGLView] removeGestureRecognizer: pan];
	
	[[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration: 0.5 scene: [MainMenuLayer scene]]];
}

- (void) goToStageLoadingLevel
{
	[DialogLayer playButtonSound];
	[[Director shared] stopMusic];
	
	CCDirector* director = [CCDirector sharedDirector];
	[[director openGLView] removeGestureRecognizer: pan];
	
	[Director shared].editing = NO;
	[Director shared].online = YES;
	[[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration: 0.0 scene: [StageLoadingLevel scene]]];
}

@end

