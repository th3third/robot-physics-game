//
//  StageLayer.m
//  chucktherobot
//
//  Created by Marshall on 03/01/2013.
//
//

#import "Layers.h"

#import "CCMenuMT.h"
#import "Stage.h"
#import "Director.h"
#import "Objects.h"
#import "TouchEvent.h"
#import "DialogLayer.h"
#import "MToolsFileManager.h"
#import "MToolsAppSettings.h"
#import "CCMenuAdvanced.h"

enum
{
	kTagParentNode = 1,
};

@interface StageLayer()
- (void) initPhysics;
- (void) createMenu;
@end

@implementation StageLayer

+ (CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	StageLayer *layer = [StageLayer node];
	
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
		self.isAccelerometerEnabled = NO;
		CGSize s = [CCDirector sharedDirector].winSize;
		
        //Drawing modes, snap dividers, and all those other defaults.
        self.drawingMode = 0;
		self.snapDivider = 4;
		self.motorSpeed = MOTOR_SPEED_SLOW;
		self.motorDirection = MOTOR_DIRECTION_CW;
        
		timeElapsedSinceStart = 0.0;
		levelCompleted = NO;
		helpPageNum = 0;
		
        [self loadStage];
        
		// create reset button
		[self createMenu];
		
		[self scheduleUpdate];
	}
	return self;
}

- (void) changeBackground
{
	[Director shared].stage.background++;
	
	[self createBackground];
}

- (void) createBackground
{
    if (background.parent)
		[background removeFromParentAndCleanup: YES];
	
	if ([Director shared].stage.background > [Director shared].numOfBackgrounds || [Director shared].stage.background <= 0)
	{
		[[Director shared].stage setBackground: 1];
	}
	
	CGSize size = [[CCDirector sharedDirector] winSize];
    
    background = [CCSprite spriteWithFile: [NSString stringWithFormat: @"Media/Backgrounds/wallpaper/%d.jpg", [Director shared].stage.background]];
    background.position = ccp(size.width / 2, size.height / 2);
    background.scaleX = size.width / background.contentSize.width;
    background.scaleY = size.height / background.contentSize.height;
    [self addChild: background z: -2];
}

-(void) createMenu
{
	CGSize s = [CCDirector sharedDirector].winSize;
	
	// Default font size will be 22 points.
	[CCMenuItemFont setFontSize: 22];
	
    CGSize size = [[CCDirector sharedDirector] winSize];
    float buttonSize = (size.width / 16);
    
	//Background
	CCSprite *topRightBackground = [CCSprite spriteWithFile: @"Media/Backgrounds/general/top-right_menu.png"];
	[topRightBackground setScaleX: (s.width * 0.25) / topRightBackground.contentSize.width ];
	[topRightBackground setScaleY: (s.height * 0.14) / topRightBackground.contentSize.height];
	[topRightBackground setAnchorPoint: ccp(0.5, 0.5)];
	[topRightBackground setPosition: ccp(s.width - (topRightBackground.contentSize.width * topRightBackground.scaleX) / 2, s.height - (topRightBackground.contentSize.height * topRightBackground.scaleY) / 2)];
	[topRightBackground setOpacity: 200];
	[self addChild: topRightBackground z: 8999];
	
    //Sound
	CCSprite *soundNormalImage;
	CCSprite *soundSelectedImage;
	if ([Director shared].soundEnabled)
	{
		soundNormalImage = [CCSprite spriteWithFile: @"Media/Buttons/general/button_sound_toggle.png"];
		soundSelectedImage = [CCSprite spriteWithFile: @"Media/Buttons/general/button_sound_toggle_off.png"];
	}
	else
	{
		soundNormalImage = [CCSprite spriteWithFile: @"Media/Buttons/general/button_sound_toggle_off.png"];
		soundSelectedImage = [CCSprite spriteWithFile: @"Media/Buttons/general/button_sound_toggle.png"];
	}
	
	sound = [CCMenuItemSprite itemWithNormalSprite: soundNormalImage  selectedSprite: soundSelectedImage block:^(id sender) {
        [self toggleSound];
    }];
	if (sound.contentSize.width > sound.contentSize.height)
		[sound setScale: buttonSize / sound.contentSize.width];
	else
		[sound setScale: buttonSize / sound.contentSize.height];
	[sound setPosition: ccp(topRightBackground.position.x + buttonSize * 1.1, topRightBackground.position.y - 5)];

    //Reset
	CCMenuItem *reset = [CCMenuItemImage itemWithNormalImage: @"Media/Buttons/general/button_restart.png" selectedImage: @"Media/Buttons/general/button_restart.png" block:^(id sender) {
		
		if ([Director shared].editing)
		{
			if (![Director shared].paused)
			{
				id ni = [CCSprite spriteWithTexture:[(CCSprite*)playButton.normalImage texture]];
				id si = [CCSprite spriteWithTexture:[(CCSprite*)playButton.selectedImage texture]];
				[playButton setNormalImage: si];
				[playButton setSelectedImage: ni];
			}
		}
		
        [self resetStage];
    }];
    if (reset.contentSize.width > reset.contentSize.height)
		[reset setScale: buttonSize / reset.contentSize.width];
	else
		[reset setScale: buttonSize / reset.contentSize.height];
	[reset setPosition: ccp(topRightBackground.position.x, topRightBackground.position.y - 5)];
    
    //Menu
	CCMenuItem *pause = [CCMenuItemImage itemWithNormalImage: @"Media/Buttons/general/button_pause.png" selectedImage: @"Media/Buttons/general/button_pause.png" block:^(id sender) {		
		
		if ([Director shared].editing)
		{
			if (![Director shared].paused)
			{
				[Director shared].paused = YES;
				DialogLayer *mainMenuConfirmDialog = [[DialogLayer alloc] initChoiceWithMessage: @"Are you sure you wish to go back to the menu? If your level is not saved it will be lost." callback: self selector: @selector(quitConfirm) selectorCancel: @selector(resumePlaying)];
				[self addChild: mainMenuConfirmDialog z: 9000];
			}
			else
			{
				DialogLayer *mainMenuConfirmDialog = [[DialogLayer alloc] initChoiceWithMessage: @"Are you sure you wish to go back to the menu? If your level is not saved it will be lost." callback: self selector: @selector(quitConfirm)];
				[self addChild: mainMenuConfirmDialog z: 9000];
			}
		}
		else if (![Director shared].online)
		{
			[Director shared].paused = YES;
			DialogLayer *mainMenuConfirmDialog = [[DialogLayer alloc] initChoiceWithMessage: [NSString stringWithFormat: @"You are playing level %d.\nAre you sure you wish to go back to level selection?", [Director shared].localLevelIndex + 1] callback: self selector: @selector(quitConfirm) selectorCancel: @selector(resumePlaying)];
			[self addChild: mainMenuConfirmDialog z: 9000];
		}
		else
		{
			if (![Director shared].paused)
			{
				[Director shared].paused = YES;
				DialogLayer *mainMenuConfirmDialog = [[DialogLayer alloc] initStageMenuWithHeader: @"ASDFASD" target: self selector: @selector(quitConfirm)];
				[self addChild: mainMenuConfirmDialog z: 9000];
			}
			else
			{
				DialogLayer *mainMenuConfirmDialog = [[DialogLayer alloc] initStageMenuWithHeader: @"ASDFASD" target: self selector: @selector(quitConfirm)];
				[self addChild: mainMenuConfirmDialog z: 9000];
			}
		}
    }];
    if (pause.contentSize.width > pause.contentSize.height)
		[pause setScale: buttonSize / pause.contentSize.width];
	else
		[pause setScale: buttonSize / pause.contentSize.height];
	[pause setPosition: ccp(topRightBackground.position.x - buttonSize * 1.1, topRightBackground.position.y - 5)];

	//Sound
	CCSprite *cheatNormalImage;
	CCSprite *cheatSelectedImage;
	cheatNormalImage = [CCSprite spriteWithFile: @"Media/Buttons/general/button_sound_toggle.png"];
	cheatSelectedImage = [CCSprite spriteWithFile: @"Media/Buttons/general/button_sound_toggle_off.png"];
	
	CCMenuItemSprite *cheat = [CCMenuItemSprite itemWithNormalSprite: cheatNormalImage  selectedSprite: cheatSelectedImage block:^(id sender) {
        [self winStage];
    }];
	if (cheat.contentSize.width > cheat.contentSize.height)
		[cheat setScale: buttonSize / cheat.contentSize.width];
	else
		[cheat setScale: buttonSize / cheat.contentSize.height];
	[cheat setPosition: ccp(topRightBackground.position.x - buttonSize * 2.2, topRightBackground.position.y - 5)];
	
	CCMenuMT *menu = [CCMenuMT menuWithItems: sound, reset, pause, cheat, nil];
	[menu setOpacity: 200];
	[menu setPosition: ccp(0, 0)];
	
	[self addChild: menu z: 9000];
}

//Creates the currently selected stage (by name). If there is no name, you get a blank stage.
- (void) loadStage
{
    bool needDownloadStage = NO;

	if ([Director shared].editing)
		[Director shared].paused = YES;
	else
		[Director shared].paused = NO;
	
    if (![Director shared].stageName && ![Director shared].stage)
    {
        [debug log: @"No stage name is present. Defaulting to blank in editor."];
        [Director shared].editing = YES;
		[Director shared].paused = YES;
		[[Director shared] loadBlankStage];
    }
	else if ([Director shared].stageName)
	{
		[[Director shared] loadCurrentStage];
	}
	
	//Play the appropriate music if we're in editing mode.
	if ([Director shared].editing)
	{
		[[Director shared] playMusic: [NSString stringWithFormat: @"Media/Audio/general/music/creator%d.mp3", arc4random() % 3]];
	}
	
    //Set the local chuck var that we check for the position.
	//This should ALWAYS be the first object. If it isn't, the map was saved wrongly.
	//TODO: Put in a check for the class? Maybe cycle through all the objects?
	if ([[[Director shared].stage objects] count] > 0)
	{
		chuck = [[[Director shared].stage objects] objectAtIndex: 0];
	}
	else
	{
		NSLog(@"WARNING: There were no objects in the loaded file. Creating defaults.");
		[[Director shared].stage createDefaults];
	}
    
    [self displayStageObjects];
    
    //If we're going to be editing the stage, put in the editing buttons.
    if ([Director shared].editing)
    {
        [self displayEditorBar];
    }
	
	//Put in the background - this is taken from the stage.
	//Background
	[self createBackground];
	
	[[CCTextureCache sharedTextureCache] removeUnusedTextures];
}

//Saves the current stage to the documents folder.
- (void) saveStage
{
	[self scheduleOnce:@selector(goToStageSave) delay:0];
}

- (void) displayStageObjects
{
    [debug log: @"Setting up level."];
    
    for (Object *object in [Director shared].stage.objects)
    {
		int z = 0;
		
		if (![object isKindOfClass: [Rope class]])
			z = object.z;
		
		[self addChild: object z: z];
		
		[object display];
    }
	
	[debug log: @"Finished setting up level."];
}

- (void) displayEditorBar
{
	CGSize s = [CCDirector sharedDirector].winSize;
	NSMutableArray *menuItems = [NSMutableArray array];
	CCMenu *menu;
    CCMenuItem *menuItem;
	float scale;
	float editorButtonSize = s.width * 0.074;
	float editorLeftButtonSize = s.height * 0.09;
	float editorButtonPadding = 0;
	CGPoint startingPoint;
	
	if (editorBar)
	{
		[editorBar removeFromParentAndCleanup: YES];
	}
	
	editorBar = [[CCSprite alloc] init];
	editorBarBot = [[CCSprite alloc] init];
	editorBarLeft = [[CCSprite alloc] init];
	
	//THE AMAZING SPINNY GEAR
	CCSprite *gearSprite = [CCSprite spriteWithFile: @"Media/Buttons/general/button_gear.png"];
	CCSprite *gearSpriteSelected = [CCSprite spriteWithFile: @"Media/Buttons/general/button_gear.png"];
	gear = [CCMenuItemSprite itemWithNormalSprite: gearSprite selectedSprite: gearSpriteSelected block:^(id sender) {
		[self toggleEditorBars];
	}];
	scale = (s.width * .175) / gear.contentSize.width;
	[gear setScale: scale];
	[gear setAnchorPoint: ccp(0.5, 0.5)];
	[gear setPosition: ccp(0 + (gear.contentSize.width / 3.75) * scale, 0 + (gear.contentSize.height / 3.75) * scale)];
	menu = [CCMenu menuWithItems: gear, nil];
	[menu setPosition: CGPointZero];
	[editorBar addChild: menu z: 2];
	
	//BACKGROUND FOR BOTTOM EDITOR TOOLS
	botEditorBackground = [CCSprite spriteWithFile: @"Media/Buttons/general/button_editor_bot_background.png"];
	float scaleX = (s.width * .940) / botEditorBackground.contentSize.width;
	float scaleY = (editorButtonSize * 1.50) / botEditorBackground.contentSize.height;
	[botEditorBackground setScaleX: scaleX];
	[botEditorBackground setScaleY: scaleY];
	[botEditorBackground setAnchorPoint: ccp(0, 0.5)];
	[botEditorBackground setPosition: ccp(gear.position.x, gear.position.y + 2)];
	[editorBarBot addChild: botEditorBackground z: 1];
	
	//BACKGROUND FOR LEFT EDITOR TOOLS
	leftEditorBackground = [CCSprite spriteWithFile: @"Media/Buttons/general/button_editor_left_background.png"];
	scale = (s.height * 0.90) / leftEditorBackground.contentSize.height;
	[leftEditorBackground setScale: scale];
	[leftEditorBackground setAnchorPoint: ccp(0.5, 0)];
	[leftEditorBackground setPosition: ccp(gear.position.x + 9 * [Director shared].scaleFactor.width, gear.position.y)];
	[editorBarLeft addChild: leftEditorBackground z: 1];
	
	startingPoint = ccp(-(s.width / 2) + leftEditorBackground.position.x, -(s.height / 2) + botEditorBackground.position.y + 2);
	
	//-------//
	//BUTTONS//
	//-------//
	
    //RECTANGLE TOOL
	CGPoint menuItemPos = ccp((gear.contentSize.width / 1.5 * gear.scale) + startingPoint.x + ((editorButtonSize + editorButtonPadding) * [menuItems count]), startingPoint.y);
    menuItem = [CCMenuItemImage itemWithNormalImage: @"Media/Buttons/general/button_editor_rectangle.png" selectedImage: @"Media/Buttons/general/button_editor_rectangle.png" block:^(id sender) {
		[self setDrawingMode: DRAWING_MODE_RECTANGLE];
		[self moveButtonSelectorTo: menuItemPos inBar: 0];
    }];
	if (menuItem.contentSize.width > menuItem.contentSize.height)
		scale = editorButtonSize / menuItem.contentSize.width;
	else
		scale = editorButtonSize / menuItem.contentSize.height;
	[menuItem setScale: scale];
	[menuItem setAnchorPoint: ccp(0.5, 0.5)];
	[menuItem setPosition: menuItemPos];
    [menuItems addObject: menuItem];
    
    //CIRCLE TOOL
	menuItemPos = ccp((gear.contentSize.width / 1.5 * gear.scale) + startingPoint.x + ((editorButtonSize + editorButtonPadding) * [menuItems count]), startingPoint.y);
    menuItem = [CCMenuItemImage itemWithNormalImage: @"Media/Buttons/general/button_editor_circle.png" selectedImage: @"Media/Buttons/general/button_editor_circle.png" block:^(id sender) {
        [self setDrawingMode: DRAWING_MODE_CIRCLE];
		[self moveButtonSelectorTo: menuItemPos inBar: 0];
    }];
    if (menuItem.contentSize.width > menuItem.contentSize.height)
		scale = editorButtonSize / menuItem.contentSize.width;
	else
		scale = editorButtonSize / menuItem.contentSize.height;
	[menuItem setScale: scale];
	[menuItem setAnchorPoint: ccp(0.5, 0.5)];
	[menuItem setPosition: menuItemPos];
	[menuItems addObject: menuItem];
    
    //ROPE TOOL
	menuItemPos = ccp((gear.contentSize.width / 1.5 * gear.scale) + startingPoint.x + ((editorButtonSize + editorButtonPadding) * [menuItems count]), startingPoint.y);
    menuItem = [CCMenuItemImage itemWithNormalImage: @"Media/Buttons/general/button_editor_rope.png" selectedImage: @"Media/Buttons/general/button_editor_rope.png" block:^(id sender) {
        [self setDrawingMode: DRAWING_MODE_ROPE];
		[self moveButtonSelectorTo: menuItemPos inBar: 0];
    }];
    if (menuItem.contentSize.width > menuItem.contentSize.height)
		scale = editorButtonSize / menuItem.contentSize.width;
	else
		scale = editorButtonSize / menuItem.contentSize.height;
	[menuItem setScale: scale];
	[menuItem setAnchorPoint: ccp(0.5, 0.5)];
	[menuItem setPosition: menuItemPos];
	[menuItems addObject: menuItem];
    
    //BALLOON TOOL
	menuItemPos = ccp((gear.contentSize.width / 1.5 * gear.scale) + startingPoint.x + ((editorButtonSize + editorButtonPadding) * [menuItems count]), startingPoint.y);
    menuItem = [CCMenuItemImage itemWithNormalImage: @"Media/Buttons/general/button_editor_balloon.png" selectedImage: @"Media/Buttons/general/button_editor_balloon.png" block:^(id sender) {
        [self setDrawingMode: DRAWING_MODE_BALLOON];
		[self moveButtonSelectorTo: menuItemPos inBar: 0];
    }];
    if (menuItem.contentSize.width > menuItem.contentSize.height)
		scale = editorButtonSize / menuItem.contentSize.width;
	else
		scale = editorButtonSize / menuItem.contentSize.height;
	[menuItem setScale: scale];
	[menuItem setAnchorPoint: ccp(0.5, 0.5)];
	[menuItem setPosition: menuItemPos];
	[menuItems addObject: menuItem];
    
    //PIVOT TOOL
	menuItemPos = ccp((gear.contentSize.width / 1.5 * gear.scale) + startingPoint.x + ((editorButtonSize + editorButtonPadding) * [menuItems count]), startingPoint.y);
    menuItem = [CCMenuItemImage itemWithNormalImage: @"Media/Buttons/general/button_editor_pivot.png" selectedImage: @"Media/Buttons/general/button_editor_pivot.png" block:^(id sender) {
        [self setDrawingMode: DRAWING_MODE_PIVOT];
		[self moveButtonSelectorTo: menuItemPos inBar: 0];
    }];
    if (menuItem.contentSize.width > menuItem.contentSize.height)
		scale = editorButtonSize / menuItem.contentSize.width;
	else
		scale = editorButtonSize / menuItem.contentSize.height;
	[menuItem setScale: scale];
	[menuItem setAnchorPoint: ccp(0.5, 0.5)];
	[menuItem setPosition: menuItemPos];
	[menuItems addObject: menuItem];
    
    //STATIC TOOL
	menuItemPos = ccp((gear.contentSize.width / 1.5 * gear.scale) + startingPoint.x + ((editorButtonSize + editorButtonPadding) * [menuItems count]), startingPoint.y);
    menuItem = [CCMenuItemImage itemWithNormalImage: @"Media/Buttons/general/button_editor_static.png" selectedImage: @"Media/Buttons/general/button_editor_static.png" block:^(id sender) {
		[self setDrawingMode: DRAWING_MODE_STATIC];
		[self moveButtonSelectorTo: menuItemPos inBar: 0];
    }];
    if (menuItem.contentSize.width > menuItem.contentSize.height)
		scale = editorButtonSize / menuItem.contentSize.width;
	else
		scale = editorButtonSize / menuItem.contentSize.height;
	[menuItem setScale: scale];
	[menuItem setAnchorPoint: ccp(0.5, 0.5)];
	[menuItem setPosition: menuItemPos];
	[menuItems addObject: menuItem];
    
    //MOTOR TOOL
	menuItemPos = ccp((gear.contentSize.width / 1.5 * gear.scale) + startingPoint.x + ((editorButtonSize + editorButtonPadding) * [menuItems count]), startingPoint.y);
    menuItem = [CCMenuItemImage itemWithNormalImage: @"Media/Buttons/general/button_editor_motor.png" selectedImage: @"Media/Buttons/general/button_editor_motor.png" block:^(id sender) {
		if (self.drawingMode != DRAWING_MODE_MOTOR)
		{
			[self setDrawingMode: DRAWING_MODE_MOTOR];
		}
		else
		{
			self.motorSpeed++;
			if (self.motorSpeed > MOTOR_SPEED_FAST)
			{
				self.motorSpeed = MOTOR_SPEED_SLOW;
				
				if (self.motorDirection == MOTOR_DIRECTION_CCW)
					self.motorDirection = MOTOR_DIRECTION_CW;
				else
					self.motorDirection = MOTOR_DIRECTION_CCW;
			}
			
			[self drawMotorArrows];
		}
		[self moveButtonSelectorTo: menuItemPos inBar: 0];
    }];
    if (menuItem.contentSize.width > menuItem.contentSize.height)
		scale = editorButtonSize / menuItem.contentSize.width;
	else
		scale = editorButtonSize / menuItem.contentSize.height;
	[menuItem setTag: 0];
	[menuItem setScale: scale];
	[menuItem setAnchorPoint: ccp(0.5, 0.5)];
	[menuItem setPosition: menuItemPos];
	[menuItems addObject: menuItem];
    
    //WELD TOOL
	menuItemPos = ccp((gear.contentSize.width / 1.5 * gear.scale) + startingPoint.x + ((editorButtonSize + editorButtonPadding) * [menuItems count]), startingPoint.y);
    menuItem = [CCMenuItemImage itemWithNormalImage: @"Media/Buttons/general/button_editor_weld.png" selectedImage: @"Media/Buttons/general/button_editor_weld.png" block:^(id sender) {
        [self setDrawingMode: DRAWING_MODE_WELD];
		[self moveButtonSelectorTo: menuItemPos inBar: 0];
    }];
    if (menuItem.contentSize.width > menuItem.contentSize.height)
		scale = editorButtonSize / menuItem.contentSize.width;
	else
		scale = editorButtonSize / menuItem.contentSize.height;
	[menuItem setScale: scale];
	[menuItem setAnchorPoint: ccp(0.5, 0.5)];
	[menuItem setPosition: menuItemPos];
	[menuItems addObject: menuItem];
    
    //POPPABLE TOOL
	menuItemPos = ccp((gear.contentSize.width / 1.5 * gear.scale) + startingPoint.x + ((editorButtonSize + editorButtonPadding) * [menuItems count]), startingPoint.y);
    menuItem = [CCMenuItemImage itemWithNormalImage: @"Media/Buttons/general/button_editor_poppable.png" selectedImage: @"Media/Buttons/general/button_editor_poppable.png" block:^(id sender) {
        [self setDrawingMode: DRAWING_MODE_POPPABLE];
		[self moveButtonSelectorTo: menuItemPos inBar: 0];
    }];
    if (menuItem.contentSize.width > menuItem.contentSize.height)
		scale = editorButtonSize / menuItem.contentSize.width;
	else
		scale = editorButtonSize / menuItem.contentSize.height;
	[menuItem setScale: scale];
	[menuItem setAnchorPoint: ccp(0.5, 0.5)];
	[menuItem setPosition: menuItemPos];
	[menuItems addObject: menuItem];
    
    //BOUNCY TOOL
	menuItemPos = ccp((gear.contentSize.width / 1.5 * gear.scale) + startingPoint.x + ((editorButtonSize + editorButtonPadding) * [menuItems count]), startingPoint.y);
    menuItem = [CCMenuItemImage itemWithNormalImage: @"Media/Buttons/general/button_editor_bouncy.png" selectedImage: @"Media/Buttons/general/button_editor_bouncy.png" block:^(id sender) {
		[self setDrawingMode: DRAWING_MODE_BOUNCY];
		[self moveButtonSelectorTo: menuItemPos inBar: 0];
}];
    if (menuItem.contentSize.width > menuItem.contentSize.height)
		scale = editorButtonSize / menuItem.contentSize.width;
	else
		scale = editorButtonSize / menuItem.contentSize.height;
	[menuItem setScale: scale];
	[menuItem setAnchorPoint: ccp(0.5, 0.5)];
	[menuItem setPosition: menuItemPos];
	[menuItems addObject: menuItem];
    
    //HELP
	menuItemPos = ccp((gear.contentSize.width / 1.5 * gear.scale) + startingPoint.x + ((editorButtonSize + editorButtonPadding) * [menuItems count]), startingPoint.y);
    menuItem = [CCMenuItemImage itemWithNormalImage: @"Media/Buttons/general/button_editor_help.png" selectedImage: @"Media/Buttons/general/button_editor_help.png" block:^(id sender) {
		[self performSelector: @selector(createLoadingBox)];
        [self performSelector: @selector(showHelpMenu) withObject: Nil afterDelay: 0.2];
    }];
    if (menuItem.contentSize.width > menuItem.contentSize.height)
		scale = editorButtonSize / menuItem.contentSize.width;
	else
		scale = editorButtonSize / menuItem.contentSize.height;
	[menuItem setScale: scale];
	[menuItem setAnchorPoint: ccp(0.5, 0.5)];
	[menuItem setPosition: menuItemPos];
	[menuItems addObject: menuItem];
    
    menu = [CCMenu menuWithArray: menuItems];
	[menu setTag: 1];
    [editorBarBot addChild: menu  z: 2];
	
	[self addChild: editorBar z: 8999];
	
	[self drawMotorArrows];
	
    //---------//
    //LEFT MENU//
    //---------//
    
    menuItems = [NSMutableArray array];
	//startingPoint = ccp((-s.width / 2) + (gear.contentSize.width / 2) * gear.scale, (-s.height / 2) + ((gear.contentSize.height) * gear.scale));
	
	//PLAY
	menuItemPos = ccp(startingPoint.x, (gear.contentSize.height / 1.5 * gear.scale) + startingPoint.y + ((editorLeftButtonSize + editorButtonPadding) * [menuItems count]));
    playButton = [CCMenuItemImage itemWithNormalImage: @"Media/Buttons/general/button_editor_play.png" selectedImage: @"Media/Buttons/general/button_editor_stop.png" block:^(id sender) {
		if ([Director shared].paused)
		{
			[Director shared].paused = NO;
		}
		else
		{
			[Director shared].paused = YES;
			[self resetStage];
		}
		
		id ni = [CCSprite spriteWithTexture:[(CCSprite*)playButton.normalImage texture]];
		id si = [CCSprite spriteWithTexture:[(CCSprite*)playButton.selectedImage texture]];
		[playButton setNormalImage: si];
		[playButton setSelectedImage: ni];
    }];
	if (menuItem.contentSize.width > menuItem.contentSize.height)
		scale = editorLeftButtonSize / menuItem.contentSize.width;
	else
		scale = editorLeftButtonSize / menuItem.contentSize.height;
	[playButton setScale: scale];
	[playButton setAnchorPoint: ccp(0.5, 0.5)];
	[playButton setPosition: menuItemPos];
    [menuItems addObject: playButton];
	
	//SAVE
	menuItemPos = ccp(startingPoint.x, (gear.contentSize.height / 1.5 * gear.scale) + startingPoint.y + ((editorLeftButtonSize + editorButtonPadding) * [menuItems count]));
    menuItem = [CCMenuItemImage itemWithNormalImage: @"Media/Buttons/general/button_editor_save.png" selectedImage: @"Media/Buttons/general/button_editor_save.png" block:^(id sender) {
		if ([Director shared].loggedIn)
		{
			[self createStageSaveInfo];
		}
		else
		{
			if (![Director shared].fullVersion)
			{
				DialogLayer *purchaseFullVersionDialog = [[DialogLayer alloc] initNotificationWithMessage: @"In order to save your levels and share them online you must purchase the Full Version in-app purchase." callback: self selector: @selector(openPurchaseDialog)];
				[self addChild: purchaseFullVersionDialog z: 9000];
			}
			else
			{
				DialogLayer *loginDialog = [[DialogLayer alloc] initLoginWithCallbackObj: self selector: @selector(logInWithUsername:andPassword:)];
				[self addChild: loginDialog z: 9000];
			}
		}
    }];
	if (menuItem.contentSize.width > menuItem.contentSize.height)
		scale = editorLeftButtonSize / menuItem.contentSize.width;
	else
		scale = editorLeftButtonSize / menuItem.contentSize.height;
	[menuItem setScale: scale];
	[menuItem setAnchorPoint: ccp(0.5, 0.5)];
	[menuItem setPosition: menuItemPos];
	[menuItems addObject: menuItem];
	
	//BACKGROUND
	menuItemPos = ccp(startingPoint.x, (gear.contentSize.height / 1.5 * gear.scale) + startingPoint.y + ((editorLeftButtonSize + editorButtonPadding) * [menuItems count]));
    menuItem = [CCMenuItemImage itemWithNormalImage: @"Media/Buttons/general/button_editor_grid.png" selectedImage: @"Media/Buttons/general/button_editor_grid.png" block:^(id sender) {
		[self changeBackground];
    }];
	if (menuItem.contentSize.width > menuItem.contentSize.height)
		scale = editorLeftButtonSize / menuItem.contentSize.width;
	else
		scale = editorLeftButtonSize / menuItem.contentSize.height;
	[menuItem setScale: scale];
	[menuItem setAnchorPoint: ccp(0.5, 0.5)];
	[menuItem setPosition: menuItemPos];
	[menuItems addObject: menuItem];
	
	//ROTATE
	menuItemPos = ccp(startingPoint.x, (gear.contentSize.height / 1.5 * gear.scale) + startingPoint.y + ((editorLeftButtonSize + editorButtonPadding) * [menuItems count]));
    menuItem = [CCMenuItemImage itemWithNormalImage: @"Media/Buttons/general/button_editor_rotate.png" selectedImage: @"Media/Buttons/general/button_editor_rotate.png" block:^(id sender) {
		[self setDrawingMode: DRAWING_MODE_ROTATE];
		[self moveButtonSelectorTo: menuItemPos inBar: 1];
    }];
	if (menuItem.contentSize.width > menuItem.contentSize.height)
		scale = editorLeftButtonSize / menuItem.contentSize.width;
	else
		scale = editorLeftButtonSize / menuItem.contentSize.height;
	[menuItem setScale: scale];
	[menuItem setAnchorPoint: ccp(0.5, 0.5)];
	[menuItem setPosition: menuItemPos];
	[menuItems addObject: menuItem];
	
	//DELETE
	menuItemPos = ccp(startingPoint.x, (gear.contentSize.height / 1.5 * gear.scale) + startingPoint.y + ((editorLeftButtonSize + editorButtonPadding) * [menuItems count]));
    menuItem = [CCMenuItemImage itemWithNormalImage: @"Media/Buttons/general/button_editor_trashcan.png" selectedImage: @"Media/Buttons/general/button_editor_trashcan.png" block:^(id sender) {
		[self setDrawingMode: DRAWING_MODE_DELETE];
		[self moveButtonSelectorTo: menuItemPos inBar: 1];
    }];
	if (menuItem.contentSize.width > menuItem.contentSize.height)
		scale = editorLeftButtonSize / menuItem.contentSize.width;
	else
		scale = editorLeftButtonSize / menuItem.contentSize.height;
	[menuItem setScale: scale];
	[menuItem setAnchorPoint: ccp(0.5, 0.5)];
	[menuItem setPosition: menuItemPos];
	[menuItems addObject: menuItem];
	
	//COPY
	menuItemPos = ccp(startingPoint.x, (gear.contentSize.height / 1.5 * gear.scale) + startingPoint.y + ((editorLeftButtonSize + editorButtonPadding) * [menuItems count]));
    menuItem = [CCMenuItemImage itemWithNormalImage: @"Media/Buttons/general/button_editor_plus.png" selectedImage: @"Media/Buttons/general/button_editor_plus.png" block:^(id sender) {
		[self setDrawingMode: DRAWING_MODE_COPY];
		[self moveButtonSelectorTo: menuItemPos inBar: 1];
    }];
	if (menuItem.contentSize.width > menuItem.contentSize.height)
		scale = editorLeftButtonSize / menuItem.contentSize.width;
	else
		scale = editorLeftButtonSize / menuItem.contentSize.height;
	[menuItem setScale: scale];
	[menuItem setAnchorPoint: ccp(0.5, 0.5)];
	[menuItem setPosition: menuItemPos];
	[menuItems addObject: menuItem];
	
	//UNDO
	menuItemPos = ccp(startingPoint.x, (gear.contentSize.height / 1.5 * gear.scale) + startingPoint.y + ((editorLeftButtonSize + editorButtonPadding) * [menuItems count]));
    menuItem = [CCMenuItemImage itemWithNormalImage: @"Media/Buttons/general/button_editor_undo.png" selectedImage: @"Media/Buttons/general/button_editor_undo.png" block:^(id sender) {
		[self undoLastObject];
    }];
	if (menuItem.contentSize.width > menuItem.contentSize.height)
		scale = editorLeftButtonSize / menuItem.contentSize.width;
	else
		scale = editorLeftButtonSize / menuItem.contentSize.height;
	[menuItem setScale: scale];
	[menuItem setAnchorPoint: ccp(0.5, 0.5)];
	[menuItem setPosition: menuItemPos];
	[menuItems addObject: menuItem];
	
	//MOVE
	menuItemPos = ccp(startingPoint.x, (gear.contentSize.height / 1.5 * gear.scale) + startingPoint.y + ((editorLeftButtonSize + editorButtonPadding) * [menuItems count]));
    menuItem = [CCMenuItemImage itemWithNormalImage: @"Media/Buttons/general/button_editor_select.png" selectedImage: @"Media/Buttons/general/button_editor_select.png" block:^(id sender) {
		[self setDrawingMode: DRAWING_MODE_SELECTION];
		[self moveButtonSelectorTo: menuItemPos inBar: 1];
    }];
	if (menuItem.contentSize.width > menuItem.contentSize.height)
		scale = editorLeftButtonSize / menuItem.contentSize.width;
	else
		scale = editorLeftButtonSize / menuItem.contentSize.height;
	[menuItem setScale: scale];
	[menuItem setAnchorPoint: ccp(0.5, 0.5)];
	[menuItem setPosition: menuItemPos];
	[menuItems addObject: menuItem];
    
    //Stage name.
    /*stageNameItem = [CCMenuItemFont itemWithString: [Director shared].stageName block:^(id sender) {
        DialogLayer *dialogLayer = [[DialogLayer alloc] initWithHeader: @"Name Level" andLine1: @"Please type in the new name of your level." target: self selector: @selector(changeStageName:) textField: YES];
        [self addChild: dialogLayer z: 9000];
        
    }];
    [stageNameItem setAnchorPoint: ccp (0, 0)];
    [menuItems addObject: stageNameItem];*/
    
    menu = [CCMenu menuWithArray: menuItems];
    [editorBarLeft addChild: menu z: 2];
	
	//Add both editor bars to the main bar.
	//They will be moved off the screen to prepare for the toggle.
	[editorBar addChild: editorBarBot];
	[editorBar addChild: editorBarLeft];
	[editorBarBot setPosition: ccp(-(editorBarBot.contentSize.width * editorBarBot.scale), editorBarBot.position.y)];
}
- (void) toggleEditorBars
{
	float actionDuration = 0.5f;
	float timeToToggle = actionDuration;
	CGSize s = [CCDirector sharedDirector].winSize;
	
	[gear stopAllActions];
	[editorBarLeft stopAllActions];
	[editorBarBot stopAllActions];
	
	CCActionTween *gearSpinTween;
	if (gear.rotation == 0)
	{
		timeToToggle = actionDuration - (((((int)gear.rotation % 360) / 360.0f)) * actionDuration);
		gearSpinTween = [CCActionTween actionWithDuration: timeToToggle key: @"rotation" from: gear.rotation to: 360];
	}
	else
	{
		timeToToggle = actionDuration - (((((int)(360 - gear.rotation) % 360) / 360.0f)) * actionDuration);
		gearSpinTween = [CCActionTween actionWithDuration: timeToToggle key: @"rotation" from: gear.rotation to: 0];
	}

	[gear runAction: gearSpinTween];
	
	CCMoveTo *editorBarBotMoveTo;
	if (editorBarBot.position.x != 0)
	{
		editorBarBotMoveTo = [CCMoveTo actionWithDuration: timeToToggle position: ccp(0, 0)];
	}
	else
	{
		editorBarBotMoveTo = [CCMoveTo actionWithDuration: timeToToggle position: ccp(-s.width, 0)];
	}
	[editorBarBot runAction: editorBarBotMoveTo];
	
	CCMoveTo *editorBarLeftMoveTo;
	if (editorBarLeft.position.y != 0)
	{
		editorBarLeftMoveTo = [CCMoveTo actionWithDuration: timeToToggle position: ccp(0, 0)];
	}
	else
	{
		editorBarLeftMoveTo = [CCMoveTo actionWithDuration: timeToToggle position: ccp(0, -s.height)];
	}
	[editorBarLeft runAction: editorBarLeftMoveTo];
}

- (void) moveButtonSelectorTo: (CGPoint) pos inBar: (int) bar
{
	CGSize s = [CCDirector sharedDirector].winSize;
	float editorLeftButtonSize = s.height * 0.09;
	float scale = 1.0;
	
	//Adjust the position for the menu anchor point.
	pos.x += (s.width / 2);
	pos.y += (s.height / 2);
	
	if (!buttonSelector)
	{
		buttonSelector = [CCSprite spriteWithFile: @"Media/Buttons/general/button_selector.png"];
	}
	
	[buttonSelector removeFromParentAndCleanup: YES];
	
	if (buttonSelector.contentSize.width > buttonSelector.contentSize.height)
		scale = editorLeftButtonSize / buttonSelector.contentSize.width;
	else
		scale = editorLeftButtonSize / buttonSelector.contentSize.height;
	
	if (bar == 0)
	{
		[editorBarBot addChild: buttonSelector z: 8998];
	}
	else
	{
		[editorBarLeft addChild: buttonSelector z: 8998];
	}
	
	[buttonSelector setScale: scale];
	[buttonSelector setPosition: pos];
}

- (void) drawMotorArrows
{
	CCMenu *menu = (CCMenu *)[editorBarBot getChildByTag: 1];
	CCSprite *motorToolButton = (CCSprite *)[menu getChildByTag: 0];
	
	if (!motorToolButton)
		return;
	
	if (motorArrows.parent)
	{
		[motorArrows removeFromParentAndCleanup: YES];
	}
	
	//MOTOR TOOL ARROWS
	CCRenderTexture *arrowsTexture = [CCRenderTexture renderTextureWithWidth: (motorToolButton.contentSize.width * motorToolButton.scale) height: (motorToolButton.contentSize.height * motorToolButton.scale)];
	[arrowsTexture begin];
	
	CCSprite *arrow = [CCSprite spriteWithFile: @"Media/Buttons/general/button_editor_motor_arrow.png"];
	[arrow setScale: motorToolButton.scale];
	[arrow setAnchorPoint: ccp(0.5, 0.5)];
	[arrow setPosition: ccp((((arrow.contentSize.width / 2) * arrow.scale) + ((motorToolButton.contentSize.width * motorToolButton.scale) * 0.15)), ((arrow.contentSize.height / 2) * arrow.scale))];
	for (int i = 0; i <= self.motorSpeed; i++)
	{
		if (self.motorDirection == MOTOR_DIRECTION_CCW)
		{
			[arrow setRotation: 180];
		}
		[arrow setPosition: ccp(arrow.position.x + (MIN(i, 1) * (arrow.contentSize.width * arrow.scale)), arrow.position.y)];
		[arrow visit];
	}
	
	[arrowsTexture end];
	motorArrows = [CCSprite spriteWithTexture: arrowsTexture.sprite.texture];
	[motorArrows setAnchorPoint: ccp(0.5, -.25)];
	[motorArrows setPosition: ccp(motorToolButton.position.x + menu.position.x, 0)];
	
	if (!motorArrows.parent)
		[editorBarBot addChild: motorArrows z: 8999];
}

- (void) setDrawingMode:(int)drawingMode
{
    //[MToolsDebug log: [NSString stringWithFormat: @"Drawing mode changed to %d", drawingMode]];
    _drawingMode = drawingMode;
}

-(void) draw
{
	//
	// IMPORTANT:
	// This is only for debug purposes
	// It is recommend to disable it
	//
	[super draw];
	
	ccGLEnableVertexAttribs( kCCVertexAttribFlag_Position );
	
	kmGLPushMatrix();
	
	if ([Director shared].drawDebugData)
		[Director shared].world->DrawDebugData();
	
	kmGLPopMatrix();
}

- (void) update: (ccTime) dt
{
    if (![Director shared].paused)
    {		
		timeElapsedSinceStart += dt;
        dt = 1.0 / 60.0;
		
		for (Object *object in [[Director shared].stage objects])
		{
			if (object.alive)
				[object tick: dt];
		}
		
        [self worldTick: dt];
    }
}

- (void) worldTick: (ccTime) dt
{
    int32 velocityIterations = 8;
    int32 positionIterations = 1;
    
    [Director shared].world->Step(dt, velocityIterations, positionIterations);
    
    //Check and see if Chuck has dropped out of the stage. If so, reset or win.
    if (chuck.body)
    {
        float yPos = chuck.body->GetTransform().p.y;
        float xPos = chuck.body->GetTransform().p.x;
        
        if (!levelCompleted && (yPos <= 0 || yPos > ([CCDirector sharedDirector].winSize.height + chuck->height)  / (PTM_RATIO * [Director shared].scaleFactor.width) || xPos <= 0 - (chuck->height / (PTM_RATIO * [Director shared].scaleFactor.width)) || xPos >= ([CCDirector sharedDirector].winSize.width + chuck->height) / (PTM_RATIO * [Director shared].scaleFactor.width)))
        {
            [self winStage];
        }
    }
}

- (void) resumePlaying
{
	[Director shared].paused = NO;
}

- (void) winStage
{
	if ([Director shared].editing)
	{
		[self resetStage];
	}
	else
	{
		[[SimpleAudioEngine sharedEngine] playEffect: @"Media/Audio/general/music/level_complete.mp3"];
		
		if (![Director shared].online)
		{
			float maxTime = [[Director shared] getScoreForLevel: [NSString stringWithFormat: @"%@.ctr", [Director shared].stage.name]];

			if (timeElapsedSinceStart < maxTime)
			{
				score = 3;
			}
			else if (timeElapsedSinceStart < maxTime * 1.5)
			{
				score = 2;
			}
			else
			{
				score = 1;
			}

			NSMutableDictionary *levelProgress = [NSMutableDictionary dictionaryWithDictionary: [MToolsAppSettings getValueWithName: @"levelProgress"]];
			if (score > [[levelProgress objectForKey: [NSString stringWithFormat: @"%@.ctr", [Director shared].stage.name]] intValue])
			{
				[levelProgress setObject: [NSNumber numberWithInt: score] forKey: [NSString stringWithFormat: @"%@.ctr", [Director shared].stage.name]];
				[MToolsAppSettings setValue: levelProgress withName: @"levelProgress"];
				[debug log: @"Saving score..."];
			}
		}
		
		levelCompleted = YES;
		[self showWinScreen];
	}
}

- (void) showWinScreen
{
	DialogLayer *winDialog = [[DialogLayer alloc] initWinnerWithHeader: @"" target: self selector: @selector(goToNextStage:) andTimeElapsed: timeElapsedSinceStart andScore: score];
	[self addChild: winDialog z: 9000];
}

- (void) flagButtonPressed
{
	DialogLayer *flaggerDialog = [[DialogLayer alloc] initChoiceWithMessage: @"You are about to flag this level for inappropriate content." callback: self selector: @selector(flagConfirm) selectorCancel: @selector(showWinScreen)];
	[self addChild: flaggerDialog z: 9000];
}

- (void) flagConfirm
{
	[[Director shared] flagLevel: [Director shared].stage.name];
	DialogLayer *flaggerDialog = [[DialogLayer alloc] initNotificationWithMessage: @"Thank you for notifying us about this level's inappropriate contents." callback: self selector: @selector(showWinScreen)];
	[self addChild: flaggerDialog z: 9000];
}

- (void) goToNextStage: (NSNumber *) retry
{
	if (![retry boolValue] && [Director shared].online)
	{
		[self goToStageSelect];
	}
	else if (![retry boolValue] && ![Director shared].online)
	{
		if (![Director shared].fullVersion && [Director shared].localLevelIndex >= 14)
		{
			[self goToStageSelect];
		}
		else
		{
			if ([Director shared].localLevelIndex >= 59)
			{
				[self scheduleOnce: @selector(goToStageSelect) delay: 0.0];
			}
			else
			{
				[[Director shared] nextLocalLevel];
				[self scheduleOnce: @selector(goToStageLoading) delay: 0.0];
			}
		}
	}
	else
	{
		[self resetStage];
	}
}

- (void) resetStage
{
	timeElapsedSinceStart = 0.0;
	levelCompleted = NO;
	
	if (winDialog)
	{
		[winDialog removeFromParentAndCleanup: YES];
	}
	
	if ([Director shared].editing)
	{
		[Director shared].paused = YES;
    }
		
    for (Object *object in [[Director shared].stage objects])
    {
        [object reset];
    } 
}

#pragma mark OBJECT ADDITION/REMOVAL

- (void) addNewObject: (Object *) object
{
    [self addNewObjectAtPosition: object.position];
}

- (void) addNewObjectAtPosition: (CGPoint) location
{
    Object *object;
    switch (self.drawingMode)
    {
        //Selection
        case DRAWING_MODE_SELECTION:
        {
            selectedObject = nil;
            selectedObject2 = nil;
            break;
        }
            
        //Rectangle
        case DRAWING_MODE_RECTANGLE:
        {
            object = [Rectangle rectangleWithStart: location andEnd: ccp(location.x + self.snapDivider, location.y + self.snapDivider)];
            selectedObject = object;
            selectedObject2 = nil;
            break;
        }
        
        //Circle
        case DRAWING_MODE_CIRCLE:
        {
            object = [Circle circleWithStart: location andRadius: 1];
            selectedObject = object;
            selectedObject2 = nil;
            break;
        }
            
        //Rope
        case DRAWING_MODE_ROPE:
        {
            if (!selectedObject || !selectedObject2)
            {
                [debug log: @"Rope was not attached to two objects."];
                return;
            }
            
            Object *obj1 = (Object *)selectedObject;
            Object *obj2 = (Object *)selectedObject2;
            Rope *rope = [Rope ropeWithBodyA: obj1 andBodyB: obj2 andTouches: drawPoints];
			[rope setZ: 0];
            rope.bodyA = obj1;
            rope.bodyB = obj2;
            selectedObject = nil;
            selectedObject2 = nil;
            drawPoints = [NSMutableArray array];
            object = rope;
            break;
        }
            
        //Pivot
        case DRAWING_MODE_PIVOT:
        {
			if (!selectedObject)
			{
				[debug log: @"Did not find anything to pivot."];
				return;
			}
			
            Object *obj = (Object *)selectedObject;
			
			if ([obj isKindOfClass: [Chuck class]])
			{
				[debug log: @"Tried to attach a pivot to Chuck - you can't do that."];
				return;
			}
			
			Pivot *pivot = [Pivot pivotWithBodyA: obj];
            selectedObject = nil;
            selectedObject2 = nil;
            object = pivot;
            
            break;
        }
            
        //Balloon
        case DRAWING_MODE_BALLOON:
        {
            object = [Balloon balloonWithStart: location andRadius: 1];
            selectedObject = object;
            selectedObject2 = nil;
            
            break;
        }
            
        //Weld
        case DRAWING_MODE_WELD:
        {
            if (!selectedObject || !selectedObject2)
            {
                [debug log: @"Weld was not attached to two objects."];
                return;
            }
            
            Object *obj1 = (Object *)selectedObject;
            Object *obj2 = (Object *)selectedObject2;
            Weld *weld = [Weld weldWithBodyA: obj1 andBodyB: obj2];
            weld.bodyA = obj1;
            weld.bodyB = obj2;
            selectedObject = nil;
            selectedObject2 = nil;
            object = weld;
            
            break;
        }
			
		//Motor
		case DRAWING_MODE_MOTOR:
		{
			if (!selectedObject2)
            {
                [debug log: @"Did not find anything to motor."];
                return;
            }
            
			float forceConstant = 20;
			float force = (forceConstant * (self.motorSpeed + 1));
			
			if (self.motorDirection == MOTOR_DIRECTION_CCW)
			{
				force *= -1;
			}
			
            Object *obj = (Object *)selectedObject2;
			
			if ([obj isKindOfClass: [Chuck class]])
			{
				[debug log: @"Tried to attach a motor to Chuck - you can't do that."];
				return;
			}
			
			Motor *motor = [Motor motorWithBody: obj andForce: force];
            selectedObject = nil;
            selectedObject2 = nil;
            object = motor;
            
            break;
		}
    }
    
    if (object)
    {        
        [[Director shared].stage addObject: object];
        [self addChild: object z: object.z];
		[object display];
        //[self resetStage];
    }
    else
    {
        [debug log: @"There was an error adding an object."];
    }
}

- (void) removeObject: (Object *) object
{
    if ([object isKindOfClass: [Chuck class]])
         return;
         
    [object removeFromParentAndCleanup: YES];
    [[Director shared].stage removeObject: object];
}

- (void) undoLastObject
{
	[self removeObject: [[Director shared].stage.objects lastObject]];
}

#pragma mark TOUCH EVENTS

- (Object *) getObjectAtTouch: (UITouch *) touch
{
	NSMutableArray *touchedObjects = [NSMutableArray array];
    CGPoint location = [touch locationInView: [touch view]];
    location = [[CCDirector sharedDirector] convertToGL: location];
	
    for (Object *object in [[Director shared].stage objects])
    {
		float additionalWidth;
		float additionalHeight;
		CGRect adjustedRect;
		float targetSize = 35;
		
		if (object.bodyVisible.boundingBox.size.width <= targetSize )
		{
			additionalWidth = (targetSize - object.bodyVisible.boundingBox.size.width);
		}
		else
		{
			additionalWidth = 0;
		}
		if (object.bodyVisible.boundingBox.size.height <= targetSize)
		{
			additionalHeight = (targetSize - object.bodyVisible.boundingBox.size.height);
		}
		else
		{
			additionalHeight = 0;
		}
		
		adjustedRect = CGRectMake(object.bodyVisible.boundingBox.origin.x - (additionalWidth * 0.5), object.bodyVisible.boundingBox.origin.y - (additionalHeight * 0.5), object.bodyVisible.boundingBox.size.width + additionalWidth, object.bodyVisible.boundingBox.size.height + additionalHeight);
		
        if (CGRectContainsPoint(adjustedRect, location))
        {
			GLubyte pColor[4];
			CGPoint newpoint = (location);
			glReadPixels(newpoint.x, newpoint.y, 1, 1, GL_RGBA, GL_UNSIGNED_BYTE, &pColor[3]);
			//if (pColor[3] != 0x00)
			{
				touchStart = location;
				[touchedObjects addObject: object];
			}
        }
    }
	
	Object *objectToReturn = NULL;
	int highestZ = -1;
	for (Object *object in touchedObjects)
	{
		if (object.z > highestZ)
		{
			if ([Director shared].paused || (![Director shared].paused && object.poppable && object.alive))
			{
				objectToReturn = object;
				highestZ = object.z;
			}
		}
	}
	
    return objectToReturn;
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	CGPoint location = [touch locationInView: [touch view]];
	location = [[CCDirector sharedDirector] convertToGL: location];
	
    if ([Director shared].paused)
    {
		//Snap the location.
		location = [self snapLocation: location];
		
        switch (self.drawingMode)
        {
            //Delete
            case DRAWING_MODE_DELETE:
            {
                [self removeObject: [self getObjectAtTouch: [touches anyObject]]];
                
                break;
            }
                
            //Rotation
            case DRAWING_MODE_ROTATE:
            {
                //Maybe we need some sort of indicator to show that it's selected? A bounding box or something?
                //Also, should there be a tool bar that pops up near the object or do we want the rotate, scale, etc, tools all on another panel?
                selectedObject = [self getObjectAtTouch: [touches anyObject]];
                
                break;
            }
                
            //Selection
            case DRAWING_MODE_SELECTION:
            {
                //Maybe we need some sort of indicator to show that it's selected? A bounding box or something?
                //Also, should there be a tool bar that pops up near the object or do we want the rotate, scale, etc, tools all on another panel?
                selectedObject = [self getObjectAtTouch: [touches anyObject]];
                
                break;
            }
                
                
            //Rectangle
            case DRAWING_MODE_RECTANGLE:
            {                
                [self addNewObjectAtPosition: location];
                
                break;
            }
                
            //Circle
            case DRAWING_MODE_CIRCLE:
            {                
                [self addNewObjectAtPosition: location];
                
                break;
            }
                
            //Rope
            case DRAWING_MODE_ROPE:
            {
                drawPoints = [NSMutableArray array];
                TouchEvent *touchEvent = [[TouchEvent alloc] init];
                touchEvent.x = location.x;
                touchEvent.y = location.y;
                
                [drawPoints addObject: touchEvent];
                selectedObject = [self getObjectAtTouch: touch];
                
                break;
            }
                
			//Pivot
			case DRAWING_MODE_PIVOT:
			{				
				for (Object *object in [[Director shared].stage objects])
				{
					if (CGRectContainsPoint([object.bodyVisible boundingBox], location))
					{
						selectedObject = object;
					}
				}
				
				[self addNewObjectAtPosition: location];
				
				break;
			}
                
            //Balloon
            case DRAWING_MODE_BALLOON:
            {                
                [self addNewObjectAtPosition: location];
                
                break;
            }
                
            //Weld
            case DRAWING_MODE_WELD:
            {
                selectedObject = [self getObjectAtTouch: [touches anyObject]];
                
                break;
            }
				
			//Poppable
			case DRAWING_MODE_POPPABLE:
			{
				Object *object = [self getObjectAtTouch: [touches anyObject]];
				[object setPoppable: ![object poppable]];
				
				break;
			}
				
			//Static
			case DRAWING_MODE_STATIC:
			{
				Object *object = [self getObjectAtTouch: [touches anyObject]];
				[object setMovable: ![object movable]];
				
				break;
			}
				
			//Bouncy
			case DRAWING_MODE_BOUNCY:
			{
				Object *object = [self getObjectAtTouch: [touches anyObject]];
				
				if (object.restitution != 0.7f)
					 [object setRestitution: 0.7f];
				else
					 [object setRestitution: 0.2f];
			
				break;
			}
				
			//Copy
			case DRAWING_MODE_COPY:
			{
				Object *object = [self getObjectAtTouch: [touches anyObject]];
				
				if (!object)
				{
					return;
				}
				
				Object *copy = [object copy];
				[copy moveByX: self.snapDivider andY: self.snapDivider];
				
				[[Director shared].stage addObject: copy];
				[self addChild: copy];
				[copy display];
				
				break;
			}
			default:
			{
				return;
			}
        }
        
		if (selectedObject)
		{
			Object *object = (Object *)selectedObject;
			if (object)
			{
				selector = [self sizeSelector: selector WithObject: object];
			}
		}
    }
    //Since we're not in editing mode, we're playing the game.
    else
    {        
        [[self getObjectAtTouch: [touches anyObject]] pop];
    }
}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (![Director shared].paused)
        return;
    
	UITouch *touch = [touches anyObject];
	CGPoint location = [touch locationInView: [touch view]];
	location = [[CCDirector sharedDirector] convertToGL: location];
	
	//Snap the location.
	location = [self snapLocation: location];
	
    switch (self.drawingMode)
    {		
        //Rotation
        case DRAWING_MODE_ROTATE:
        {
            Object *object = selectedObject;
			
			if (![object isKindOfClass: [Chuck class]])
			{
				float dx = (object.curPos.x + object.widthAbs / 2) - location.x;
				float dy = (object.curPos.y + object.heightAbs / 2) - location.y;
				float angle = atan2(dy, dx);
				
				object.rotationAngle = angle;
				
				touchStart = location;
				
				selector = [self sizeSelector: selector WithObject: object];
			}
            
            break;
        }
            
        //Selection
        case DRAWING_MODE_SELECTION:
        {
            float dx = location.x - touchStart.x;
            float dy = location.y - touchStart.y;
            
            Object *object = selectedObject;
            [object moveByX: dx andY: dy];
            
            touchStart = location;
            
            break;
        }
            
        //Rectangle
        case DRAWING_MODE_RECTANGLE:
        {       
            Rectangle *object = (Rectangle *)selectedObject;
            [object setEndPos: location];
            [object display];
            
            break;
        }
            
        //Circle
        case DRAWING_MODE_CIRCLE:
        {           
            Circle *object = (Circle *)selectedObject;
            float dx = object.curPos.x - location.x;
            float dy = object.curPos.y - location.y;
            float distance = sqrt(dx * dx + dy * dy);
            object.radius = abs(distance);
            [object display];

            break;
        }
            
        //Rope
        case DRAWING_MODE_ROPE:
		case DRAWING_MODE_WELD:
        {
            //Add a new point to the touches array so we can track where the rope is going.            
            [drawPoints addObject: touch];
			
			selectedObject2 = [self getObjectAtTouch: touch];
			if (selectedObject2)
			{
				Object *object = selectedObject2;
				selector2 = [self sizeSelector: selector2 WithObject: object];
			}
			else
			{
				[selector2 removeFromParentAndCleanup: YES];
			}
            
            break;
        }
            
        //Balloon
        case DRAWING_MODE_BALLOON:
        {        
            break;
        }
		default:
		{
			return;
		}
    }
    
	if (selectedObject)
	{
		Object *object = (Object *)selectedObject;
		if (object)
		{
			selector = [self sizeSelector: selector WithObject: object];
		}
	}
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (![Director shared].paused)
        return;
    
	UITouch *touch = [touches anyObject];
	CGPoint location = [touch locationInView: [touch view]];
	location = [[CCDirector sharedDirector] convertToGL: location];
	
	//Snap the location.
	location = [self snapLocation: location];
	
    switch (self.drawingMode)
    {
        //Selection
        case DRAWING_MODE_SELECTION:
            break;
            
        //Rectangle
        case DRAWING_MODE_RECTANGLE:
        {
            Rectangle *object = (Rectangle *)selectedObject;
            
            break;
        }
            
        //Circle
        case DRAWING_MODE_CIRCLE:
        {
            Circle *object = (Circle *)selectedObject;
            
            break;
        }
            
        //Rope
        case DRAWING_MODE_ROPE:
        {
            //What we do here is put in the final touch and see which objects are at the start and end of the drawing path.
            //We'll need to pass the points to the rope so it can calculate where it needs to go, how long it needs to be , etc.
            UITouch *touch = [touches anyObject];            
            [drawPoints addObject: touch];
            
            selectedObject2 = [self getObjectAtTouch: touch];
            
            [self addNewObjectAtPosition: ccp(0, 0)];
            
            break;
        }
            
        //Balloon
        case DRAWING_MODE_BALLOON:
        {
            Balloon *object = (Balloon *)selectedObject;
            
            break;
        }
            
        //Weld
        case DRAWING_MODE_WELD:
        {            
            for (Object *object in [[Director shared].stage objects])
            {
                if (CGRectContainsPoint([object.bodyVisible boundingBox], location))
                {
                    selectedObject2 = object;
                }
            }
            
            [self addNewObjectAtPosition: ccp(0, 0)];
            
            break;
        }
			
		//Motor
		case DRAWING_MODE_MOTOR:
		{            
            for (Object *object in [[Director shared].stage objects])
            {
                if (CGRectContainsPoint([object.bodyVisible boundingBox], location))
                {
                    selectedObject2 = object;
                }
            }
            
            [self addNewObjectAtPosition: location];
            
            break;
		}
		default:
		{
			return;
		}
            
    }

    selectedObject = nil;
    selectedObject2 = nil;
    
	if (selector)
		selector.visible = NO;
	
	if (selector2)
		selector2.visible = NO;
}

- (CGPoint) snapLocation: (CGPoint) location
{
	float gridSpacing = self.snapDivider;
	
	location.x -= ((int)location.x % (int)gridSpacing);
	location.y -= ((int)location.y % (int)gridSpacing);
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		if (location.y > ([CCDirector sharedDirector].winSize.height - 80))
		{
			location.y -= (location.y - ([CCDirector sharedDirector].winSize.height - 80));
		}
	}
	
	return location;
}

- (CCSprite *) sizeSelector: (CCSprite *) selectorNum WithObject: (Object *) object
{
	[selectorNum removeFromParentAndCleanup: YES];
	
	if ([object isKindOfClass: [Rectangle class]] ||
		[object isKindOfClass: [Chuck class]])
	{
		selectorNum = [CCSprite spriteWithFile: @"Media/Objects/rectangle_selector.png"];
		selectorNum.scaleX = (object.bodyVisible.contentSize.width * object.scaleX * 1.05) / selectorNum.contentSize.width;
		selectorNum.scaleY = (object.bodyVisible.contentSize.height * object.scaleY * 1.05) / selectorNum.contentSize.height;
	}
	else if ([object isKindOfClass: [Circle class]] ||
			 [object isKindOfClass: [Pivot class]] ||
			 [object isKindOfClass: [Motor class]] ||
			 [object isKindOfClass: [Balloon class]])
	{
		Circle *circle = object;
		selectorNum = [CCSprite spriteWithFile: @"Media/Objects/circle_selector.png"];
		selectorNum.scaleX = ((circle.radius * 2) * object.scaleX * 1.1) / selectorNum.contentSize.width;
		selectorNum.scaleY = ((circle.radius * 2) * object.scaleY * 1.1) / selectorNum.contentSize.height;
	}
	else
	{
		return selectorNum;
	}
	
	selectorNum.position = object.centerPos;
	selectorNum.visible = YES;
	selectorNum.rotation = -CC_RADIANS_TO_DEGREES(object.rotationAngle);
	[self addChild: selectorNum z: object.z + 1];
	
	return selectorNum;
}

#pragma mark SOUND FUNCTIONS
- (void) toggleSound
{
	[[Director shared] toggleSound];
	[MToolsAppSettings setValue: [NSNumber numberWithBool: ![[SimpleAudioEngine sharedEngine] mute]] withName: @"soundEnabled"];
	
	id ni = [CCSprite spriteWithTexture:[(CCSprite*)sound.normalImage texture]];
	id si = [CCSprite spriteWithTexture:[(CCSprite*)sound.selectedImage texture]];
	[sound setNormalImage: si];
	[sound setSelectedImage: ni];
}

#pragma  mark PURCHASE FUNCTIONS

- (void) openPurchaseDialog
{
	DialogLayer *purchaseDialog = [[DialogLayer alloc] initPurchaseWithCallbackObj: self selector: @selector(madePurchase:)];
	[self addChild: purchaseDialog z: 9000];
}

#pragma mark SAVE FUNCTIONS

- (void) createStageSaveInfo
{
	DialogLayer *saveDialog = [[DialogLayer alloc] initSaveWithCallbackObj: self selector: @selector(changeStageNameAndSave:)];
	[self addChild: saveDialog z: 9000];
}

- (void) changeStageNameAndSave: (NSMutableArray *) tagNames
{
	[Director shared].stage.tags = tagNames;
	[self scheduleOnce: @selector(goToSaveToFile) delay: 0.0];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    return NO;
}

#pragma mark HELP

//Loads up the help popups.
- (void) createLoadingBox
{
	CGSize s = [CCDirector sharedDirector].winSize;
	
	loadingBackground = [CCSprite spriteWithFile: @"Media/Backgrounds/blank.jpg"];
	[loadingBackground setScaleX: (s.width / loadingBackground.contentSize.width)];
	[loadingBackground setScaleY: (s.height / loadingBackground.contentSize.height)];
	[loadingBackground setOpacity: 100];
	[loadingBackground setPosition: ccp(s.width * 0.5, s.height * 0.5)];
	[self addChild: loadingBackground z: 8999];
	
	loadingLabel = [DialogLayer createShadowHeaderWithString: @"Loading..."
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

- (void) showHelpMenu
{
	CCDirector* director = [CCDirector sharedDirector];
	
	if (!pan)
		pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
	
	if (helpMenu && helpMenu.parent)
	{
		CCDirector* director = [CCDirector sharedDirector];
		[[director view] removeGestureRecognizer: pan];
		
		[helpCloseMenu removeFromParentAndCleanup: NO];
		[pageMenu removeFromParentAndCleanup: NO];
		[helpMenu removeFromParentAndCleanup: YES];
		[loadingBackground removeFromParentAndCleanup: YES];
		[loadingLabel removeFromParentAndCleanup: YES];
		return;
	}
	else if (helpMenu && !helpMenu.parent)
	{
		//Pan gesture recognizer for swiping the menu.
		[[director view] addGestureRecognizer:pan];
		
		[self addChild: helpMenu z: 9000];
		[self addChild: helpCloseMenu z: 8999];
		[self addChild: pageMenu z: 9000];
		[loadingBackground removeFromParentAndCleanup: YES];
		[loadingLabel removeFromParentAndCleanup: YES];
		return;
	}
	
	//Pan gesture recognizer for swiping the menu.
	[[director view] addGestureRecognizer:pan];
	
	CGSize s = [CCDirector sharedDirector].winSize;
	NSMutableArray *menuItems = [NSMutableArray array];

	for (int i = 0; i <= 16; i++)
	{
		NSString *helpFilePath = [NSString stringWithFormat: @"Media/Backgrounds/general/help/%d.png", i];
		CCMenuItemImage *helpMenuItem = [CCMenuItemImage itemWithNormalImage: helpFilePath selectedImage: helpFilePath block:^(id sender) {
			//[self advanceHelpMenu];
		}];
		[helpMenuItem setScale: (s.width * 0.75) / helpMenuItem.contentSize.width];
		[helpMenuItem setAnchorPoint: ccp(0.5, 0.5)];
		[helpMenuItem setPosition: ccp(i * s.width + s.width * 0.5, s.height * 0.5)];
		[menuItems addObject: helpMenuItem];
	}
	
	helpMenu = [CCMenu menuWithArray: menuItems];
	[helpMenu setAnchorPoint: ccp(0, 0)];
	[helpMenu setPosition: CGPointZero];
	[self addChild: helpMenu z: 9000];
	
	[self createHelpMenuCloser];
	[self createPageTurners];
	
	[loadingBackground removeFromParentAndCleanup: YES];
	[loadingLabel removeFromParentAndCleanup: YES];
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
		[self goToPreviousPage];
	}];
	[menuItem setTag: 0];
	if (helpPageNum <= 0)
	{
		[menuItem setVisible: NO];
	}
	[menuItem setScale: ((s.width * 0.1) / menuItem.contentSize.width)];
	[menuItem setPosition: ccp((-s.width / 2) + (menuItem.contentSize.width * menuItem.scaleX) / 2, 0)];
	[menuItems addObject: menuItem];
	
	menuItemSprite = [CCSprite spriteWithFile: @"Media/Buttons/general/button_right_arrow.png"];
	menuItemSpriteSelected = [CCSprite spriteWithFile: @"Media/Buttons/general/button_right_arrow.png"];
	menuItem = [CCMenuItemSprite itemWithNormalSprite: menuItemSprite selectedSprite: menuItemSpriteSelected block:^(id sender) {
		[self goToNextPage];
	}];
	[menuItem setTag: 1];
	if (helpPageNum >= 16)
	{
		[menuItem setVisible: NO];
	}
	[menuItem setScale: ((s.width * 0.1) / menuItem.contentSize.width)];
	[menuItem setPosition: ccp((s.width / 2) - (menuItem.contentSize.width * menuItem.scaleX) / 2, 0)];
	[menuItems addObject: menuItem];
	
	pageMenu = [CCMenu menuWithArray: menuItems];
	[self addChild: pageMenu z: 9000];
}

- (void) createHelpMenuCloser
{
	CGSize s = [CCDirector sharedDirector].winSize;
	
	//This is the invisible closing background which will remove the notification window if hit.
	CCMenuItemImage *closeMenuItem = [CCMenuItemImage itemWithNormalImage: @"Media/Backgrounds/blank.jpg" selectedImage: @"Media/Backgrounds/blank.jpg" target: self selector: @selector(showHelpMenu)];
	[closeMenuItem setScaleX: (s.width / closeMenuItem.contentSize.width)];
	[closeMenuItem setScaleY: (s.height / closeMenuItem.contentSize.height)];
	[closeMenuItem setOpacity: 100];
	
	helpCloseMenu = [CCMenu menuWithItems: closeMenuItem, nil];
	[self addChild: helpCloseMenu z: 8999];
}

- (void) finishedAdvancingHelpMenu
{
	pageTurning = NO;
}

- (void) goToNextPage
{
	if (pageTurning)
		return;
	
	if (helpPageNum >= 16)
	{		
		return;
	}
	
	pageTurning = YES;
	helpPageNum++;
	
	[self performSelector: @selector(finishedAdvancingHelpMenu) withObject: nil afterDelay: 0.25];
	
	CGSize s = [CCDirector sharedDirector].winSize;
	CCMoveTo *action = [CCMoveTo actionWithDuration: 0.25 position: ccp((helpPageNum * -s.width), helpMenu.position.y)];
	[helpMenu stopAllActions];
	[helpMenu runAction: action];
	
	if (helpPageNum >= 16)
	{
		[[pageMenu getChildByTag: 1] setVisible: NO];
	}
	else
	{
		[[pageMenu getChildByTag: 1] setVisible: YES];
	}
	
	[[pageMenu getChildByTag: 0] setVisible: YES];
}

- (void) goToPreviousPage
{
	if (pageTurning)
		return;
	
	if (helpPageNum <= 0)
	{
		return;
	}
	
	pageTurning = YES;
	helpPageNum--;
	
	[self performSelector: @selector(finishedAdvancingHelpMenu) withObject: nil afterDelay: 0.15];
	
	CGSize s = [CCDirector sharedDirector].winSize;
	CCMoveTo *action = [CCMoveTo actionWithDuration: 0.15 position: ccp((helpPageNum * -s.width), helpMenu.position.y)];
	[helpMenu stopAllActions];
	[helpMenu runAction: action];
	
	if (helpPageNum <= 0)
	{
		[[pageMenu getChildByTag: 0] setVisible: NO];
	}
	else
	{
		[[pageMenu getChildByTag: 0] setVisible: YES];
	}
	
	[[pageMenu getChildByTag: 1] setVisible: YES];
}

- (void)handlePanGesture:(UIGestureRecognizer*)gestureRecognizer
{
	if (!helpMenu.parent)
		return;
	
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
				[self goToNextPage];
			}
			else if (translation.x < -1000)
			{
				[self goToPreviousPage];
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
	DialogLayer *quitConfirm = [[DialogLayer alloc] initStageMenuWithHeader: @"PAUSED" target: self selector: @selector(quitConfirm)];
	[self addChild: quitConfirm z: 9000];
}

- (void) quitConfirm
{
	CCDirector* director = [CCDirector sharedDirector];
	[[director view] removeGestureRecognizer: pan];
	
	[Director shared].stage = nil;
	[Director shared].stageName = nil;
	
	//Play the background music.
	[[Director shared] playMusic: @"Media/Audio/general/music/main_menu.mp3"];
	
	if ([Director shared].editing)
	{
		[[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration: 0.5 scene: [MainMenuLayer scene]]];
	}
	else
	{
		[[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration: 0.5 scene: [StageSelectLayer scene]]];
	}
}

- (void) goToStageSelect
{
	CCDirector* director = [CCDirector sharedDirector];
	[[director view] removeGestureRecognizer: pan];
	
	//Play the background music.
	[[Director shared] playMusic: @"Media/Audio/general/music/main_menu.mp3"];
	
	[[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration: 0.5 scene: [StageSelectLayer scene]]];
}

- (void) goToStageLoading
{
	CCDirector* director = [CCDirector sharedDirector];
	[[director openGLView] removeGestureRecognizer: pan];
	
	[[Director shared] stopMusic];
	[[CCDirector sharedDirector] replaceScene: [CCTransitionSlideInT transitionWithDuration: 0.0 scene: [StageLoadingLevel scene]]];
}

- (void) goToSaveToFile
{
	if (![Director shared].loggedIn)
	{
		DialogLayer *loginDialog = [[DialogLayer alloc] initLoginWithCallbackObj: [Director shared] selector: @selector(logInWith:)];
		[self addChild: loginDialog z: 9000];
		return;
	}
	
	[[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration: 0.0 scene: [StageSaveToFile scene]]];
}

#pragma mark SETTERS/GETTERS


@end
