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
		// enable events
		
		self.isTouchEnabled = YES;
		
		[self createStageSaveInfo];
	}
	
	return self;
}

- (void) createStageSaveInfo
{
	CGSize s = [CCDirector sharedDirector].winSize;
	
	CCMenu *menu;
	CCMenuItemSprite *menuItem;
	CCLabelTTF *label;
	
	//NAME
	label = [CCLabelTTF labelWithString:@"Name" fontName: [Director shared].globalFont fontSize: TITLE_FONT_SIZE];
	[self addChild:label z:0];
	[label setColor:ccc3(255, 255, 255)];
	[label setAnchorPoint: ccp(0, 0)];
	label.position = ccp(0, s.height * .85);
	
	stageNameItem = [CCMenuItemFont itemWithString: [Director shared].stage.name block:^(id sender) {
		DialogLayer *dialogLayer = [[DialogLayer alloc] initWithHeader: @"Enter New Name" andLine1: @"Please enter a name for your level. If you use the same name as a previous level it will be OVERWRITTEN." target: self selector: @selector(changeStageName:) textField: YES];
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
	int numberOfTags = 12;
	
	for (int i = 0; i < numberOfTags; i++)
	{
		CCSprite *tagSpriteNormal = [CCSprite spriteWithFile: @"Media/Buttons/general/button_tag.png"];
		CCSprite *tagSpriteSelected = [CCSprite spriteWithFile: @"Media/Buttons/general/button_tag_selected.png"];
		menuItem = [CCMenuItemSprite itemWithNormalSprite: tagSpriteNormal selectedSprite: tagSpriteSelected block:^(id sender)
		{
			
		}];
				  
		[menuItems addObject: menuItem];
	}
	
	menu = [CCMenu menuWithArray: menuItems];
	[menu setPosition: ccp(s.width / 2, s.height / 2 - 30)];
	[menu alignItemsInColumns: [NSNumber numberWithInt: 6], [NSNumber numberWithInt: 6], nil];
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
	menu = [CCMenu menuWithItems: menuItemFont, nil];
	[self addChild: menu];
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
	
	[[CCDirector sharedDirector] replaceScene: [CCTransitionSlideInR transitionWithDuration: 0.5 scene: [StageSaveToFile scene]]];
}

@end

