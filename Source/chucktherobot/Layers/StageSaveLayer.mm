#import "Layers.h"

#define FONT_SIZE 24
#define TITLE_FONT_SIZE 32

@implementation StageSaveLayer

+ (CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	StageSaveLayer *layer = [StageSaveLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

- (id) init
{
	if( (self = [super init]))
    {
		//Create all the tag names.
		tagNames = [NSMutableArray array];
		[tagNames addObject: @"destructive"];
		[tagNames addObject: @"crazy"];
		[tagNames addObject: @"hard"];
		[tagNames addObject: @"bouncy"];
		[tagNames addObject: @"short"];
		[tagNames addObject: @"puzzle"];
		[tagNames addObject: @"artistic"];
		[tagNames addObject: @"timing"];
		
		self.isTouchEnabled = YES;
		
		CGSize size = [CCDirector sharedDirector].winSize;
		
		CCSprite *background = [CCSprite spriteWithFile: [NSString stringWithFormat: @"Media/Backgrounds/general/main_menu.jpg", [Director shared].stage.background]];
		background.position = ccp(size.width / 2, size.height / 2);
		background.scaleX = size.width / background.contentSize.width;
		background.scaleY = size.height / background.contentSize.height;
		[self addChild: background z: -2];
		
		[self createStageSaveInfo];
	}
	
	return self;
}

- (void) createStageSaveInfo
{
	CGSize s = [CCDirector sharedDirector].winSize;
	
	CCMenu *menu;
	CCMenuItemToggle *menuItem;
	CCLabelTTF *label;
	
	//NAME
	label = [CCLabelTTF labelWithString:@"Name" fontName: [Director shared].globalFont fontSize: TITLE_FONT_SIZE];
	[self addChild:label z:0];
	[label setColor:ccc3(255, 255, 255)];
	[label setAnchorPoint: ccp(0, 0)];
	label.position = ccp(0, s.height * .85);
	
	stageNameItem = [CCMenuItemFont itemWithString: [Director shared].stage.name block:^(id sender) {
		DialogLayer *dialogLayer = [[DialogLayer alloc] initWithHeader: @"Enter New Name" andLine1: @"Please enter a name for your level. If you use the same name as a previous level you have created it will be OVERWRITTEN." target: self selector: @selector(changeStageName:) textField: YES];
        [self addChild: dialogLayer z: 9000];
	}];
	[stageNameItem setFontName: [Director shared].globalFont];
	[stageNameItem setFontSize: TITLE_FONT_SIZE];
	[stageNameItem setAnchorPoint: ccp(0, 0)];
	[stageNameItem setPosition: ccp((-s.width / 2) + 150, (-s.height / 2) + s.height * .85)];
	menu = [CCMenu menuWithItems: stageNameItem, nil];
	[self addChild: menu];
	
	//CREATOR
	label = [CCLabelTTF labelWithString:@"Creator" fontName: [Director shared].globalFont fontSize: TITLE_FONT_SIZE];
	[self addChild:label z:0];
	[label setColor:ccc3(255, 255, 255)];
	[label setAnchorPoint: ccp(0, 0)];
	label.position = ccp(0, s.height * .70);
	
	label = [CCLabelTTF labelWithString: [Director shared].playerName fontName: [Director shared].globalFont fontSize: TITLE_FONT_SIZE];
	[self addChild:label z:0];
	[label setColor:ccc3(255, 255, 255)];
	[label setAnchorPoint: ccp(0, 0)];
	label.position = ccp(150, s.height * .70);
	
	//TAGS
	label = [CCLabelTTF labelWithString:@"Tags" fontName: [Director shared].globalFont fontSize: TITLE_FONT_SIZE];
	[self addChild:label z:0];
	[label setColor:ccc3(255, 255, 255)];
	[label setAnchorPoint: ccp(0, 0)];
	label.position = ccp(0, s.height * .55);
	
	NSMutableArray *menuItems = [NSMutableArray array];
	float rowStart = (s.height / 2) - label.position.y;
	int row = 0;
	int col = 0;
	for (int i = 0; i < [tagNames count]; i++)
	{
		NSString *tagFileName = [NSString stringWithFormat: @"Media/Buttons/general/tags/tag_%@.png", [tagNames objectAtIndex: i]];
		NSString *tagSelectedFileName = [NSString stringWithFormat: @"Media/Buttons/general/tags/tag_%@_selected.png", [tagNames objectAtIndex: i]];
		CCMenuItem *menuItemOn = [CCMenuItemImage itemWithNormalImage: tagFileName selectedImage: tagFileName];
		CCMenuItem *menuItemOff = [CCMenuItemImage itemWithNormalImage: tagSelectedFileName selectedImage: tagSelectedFileName];
		NSArray *toggleItems = [NSArray arrayWithObjects: menuItemOff, menuItemOn, nil];
		
		menuItem = [CCMenuItemToggle itemWithItems: toggleItems block:^(id sender) {
			[self toggleTag: [tagNames objectAtIndex: i]];
		}];
		float scale = ((s.width / ([tagNames count] / 2)) * 0.75) / menuItem.contentSize.width;
		[menuItem setScale: scale];
		
		if ((i * 2) >= (row + 1) * [tagNames count])
		{
			row++;
			col = 0;
		}
		
		[menuItem setPosition: ccp(s.width * 0.1 + (s.width / ([tagNames count] / 2)) * col, (row * s.height * 0.15))];
		col++;
		
		for (NSString *tag in [Director shared].stage.tags)
		{
			if ([tag isEqualToString: [tagNames objectAtIndex: i]])
			{
				[menuItem activate];
			}
		}
		
		[menuItems addObject: menuItem];
	}
	
	menu = [CCMenu menuWithArray: menuItems];
	[menu setPosition: ccp(0, s.height * 0.325)];
	[self addChild: menu];
	
	//SAVE TO FILE BUTTON
	CCMenuItemFont *menuItemFont = [CCMenuItemFont itemWithString: @"SAVE" block:^(id sender) {
		//TODO: Check for overwrite.
		if ([[Director shared].stage.name isEqualToString: @"Untitled"])
		{
			DialogLayer *dialogLayer = [[DialogLayer alloc] initWithHeader: @"Please name your level" andLine1: @"Please type in a name for your level." target: self selector: @selector(changeStageNameAndSave:) textField: YES];
			[self addChild: dialogLayer z: 9000];
		}
		else
		{
			[self scheduleOnce: @selector(goToSaveToFile) delay: 0.0];
		}
	}];
	[menuItemFont setFontName: [Director shared].globalFont];
	[menuItemFont setFontSize: TITLE_FONT_SIZE];
	[menuItemFont setAnchorPoint: ccp(0, 0)];
	[menuItemFont setPosition: ccp((-s.width / 2), (s.height / 2) - s.height * .85)];
	
	//BACK BUTTON
	CCMenuItemFont *menuItemBack = [CCMenuItemFont itemWithString: @"BACK" block:^(id sender) {
		//TODO: Check for overwrite.
		[self goToStage];
	}];
	[menuItemBack setFontName: [Director shared].globalFont];
	[menuItemBack setFontSize: TITLE_FONT_SIZE];
	[menuItemBack setAnchorPoint: ccp(1, 0)];
	[menuItemBack setPosition: ccp((s.width / 2), (s.height / 2) - s.height * .85)];
	
	menu = [CCMenu menuWithItems: menuItemFont, menuItemBack, nil];
	[self addChild: menu];
}

- (void) toggleTag: (NSString *) tagString
{
	NSLog(@"Toggled %@", tagString);
	if (!currentTags)
		currentTags = [NSMutableArray array];
	
	id tagToRemove;
	for (NSString *tag in currentTags)
	{
		if ([tag isEqualToString: tagString])
		{
			tagToRemove = tag;
		}
	}
	
	if (tagToRemove)
	{
		[currentTags removeObject: tagToRemove];
	}
	else
	{
		[currentTags addObject: tagString];
	}
}

- (void) changeStageName: (DialogLayer *) diaglayer
{
	if (!diaglayer.textField.text || [diaglayer.textField.text isEqualToString: @"Untitled"])
		return;
	
    [Director shared].stage.name = diaglayer.textField.text;
    [stageNameItem setString: [Director shared].stage.name];
}

- (void) changeStageNameAndSave: (DialogLayer *) diaglayer
{
	[self changeStageName: diaglayer];
	[self scheduleOnce: @selector(goToSaveToFile) delay: 0.0];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    return NO;
}

#pragma mark GOTOS

- (void) goToSaveToFile
{
	if (![Director shared].loggedIn)
	{
		[self addChild: [[Director shared] createLogInDialog] z: 9000];
		return;
	}
	
	//Add in the tags to the level.
	[Director shared].stage.tags = currentTags;
	
	[[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration: 0.0 scene: [StageSaveToFile scene]]];
}

- (void) goToStage
{
	[[CCDirector sharedDirector] replaceScene: [CCTransitionSlideInB transitionWithDuration: 0.5 scene: [StageLayer scene]]];
}

@end

