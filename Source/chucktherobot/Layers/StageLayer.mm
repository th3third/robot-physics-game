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
		// enable events
		self.isTouchEnabled = YES;
		self.isAccelerometerEnabled = NO;
		CGSize s = [CCDirector sharedDirector].winSize;
        
        //Drawing modes, snap dividers, and all those other defaults.
        self.drawingMode = 0;
		self.snapDivider = 4;
		self.motorSpeed = MOTOR_SPEED_SLOW;
		self.motorDirection = MOTOR_DIRECTION_CW;
        
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
	// Default font size will be 22 points.
	[CCMenuItemFont setFontSize: 22];
	
    CGSize size = [[CCDirector sharedDirector] winSize];
    float buttonSize = (size.width / 16);
    
    //Sound
	CCMenuItem *sound = [CCMenuItemImage itemWithNormalImage: @"Media/Buttons/general/button_sound_toggle.png" selectedImage: @"Media/Buttons/general/button_sound_toggle.png" block:^(id sender) {
        NSLog(@"Sound toggle.");
        
    }];
    sound.scale = buttonSize / sound.contentSize.width;
    
    //Reset
	CCMenuItem *reset = [CCMenuItemImage itemWithNormalImage: @"Media/Buttons/general/button_restart.png" selectedImage: @"Media/Buttons/general/button_restart.png" block:^(id sender) {
        [self resetStage];
    }];
    reset.scale = buttonSize / reset.contentSize.width;
    
    //Menu
	CCMenuItem *pause = [CCMenuItemImage itemWithNormalImage: @"Media/Buttons/general/button_pause.png" selectedImage: @"Media/Buttons/general/button_pause.png" block:^(id sender) {
        [self scheduleOnce: @selector(goToMainMenu) delay: 0.0f];
    }];
    pause.scale = buttonSize / pause.contentSize.width;

	CCMenuMT *menu = [CCMenuMT menuWithItems: sound, reset, pause, nil];
    [menu alignItemsTopRightWithPadding: 10];
	
	[self addChild: menu z: -1];
}

//Creates the currently selected stage (by name). If there is no name, you get a blank stage.
- (void) loadStage
{
    bool needDownloadStage = NO;

	if ([Director shared].editing)
		[Director shared].paused = YES;
	else
		[Director shared].paused = NO;
	
    if (![Director shared].stageName)
    {
        [debug log: @"No stage name is present. Defaulting to blank in editor."];
        [Director shared].editing = YES;
		[Director shared].paused = YES;
        [Director shared].stageName = @"Untitled";
    }
	
	[[Director shared] loadCurrentStage];
	
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
}

//Saves the current stage to the documents folder.
//TODO: We're going to need to do stuff after it's done like ask to upload and junk.
- (void) saveStage
{
	[self scheduleOnce:@selector(goToStageSave) delay:0];
    //[[Director shared].stage saveToFile];
}

- (void) displayStageObjects
{
    [debug log: @"Setting up level."];
    
    for (Object *object in [Director shared].stage.objects)
    {
        [self addChild: object];
		[object display];
    }
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
	float botEditorOffset = 12;
	float leftEditorOffset = 10;
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
	[leftEditorBackground setPosition: ccp(gear.position.x + 7, gear.position.y)];
	[editorBarLeft addChild: leftEditorBackground z: 1];
	
	startingPoint = ccp(-(s.width / 2) + leftEditorBackground.position.x, -(s.height / 2) + botEditorBackground.position.y + 2);
	
	//-------//
	//BUTTONS//
	//-------//
	
    //RECTANGLE TOOL
    menuItem = [CCMenuItemImage itemWithNormalImage: @"Media/Buttons/general/button_editor_rectangle.png" selectedImage: @"Media/Buttons/general/button_editor_rectangle.png" block:^(id sender) {
		[self setDrawingMode: DRAWING_MODE_RECTANGLE];
    }];
	if (menuItem.contentSize.width > menuItem.contentSize.height)
		scale = editorButtonSize / menuItem.contentSize.width;
	else
		scale = editorButtonSize / menuItem.contentSize.height;
	[menuItem setScale: scale];
	[menuItem setAnchorPoint: ccp(0.5, 0.5)];
	[menuItem setPosition: ccp((gear.contentSize.width / 1.5 * gear.scale) + startingPoint.x + ((editorButtonSize + editorButtonPadding) * [menuItems count]), startingPoint.y)];
    [menuItems addObject: menuItem];
    
    //CIRCLE TOOL
    menuItem = [CCMenuItemImage itemWithNormalImage: @"Media/Buttons/general/button_editor_circle.png" selectedImage: @"Media/Buttons/general/button_editor_circle.png" block:^(id sender) {
        [self setDrawingMode: DRAWING_MODE_CIRCLE];
    }];
    if (menuItem.contentSize.width > menuItem.contentSize.height)
		scale = editorButtonSize / menuItem.contentSize.width;
	else
		scale = editorButtonSize / menuItem.contentSize.height;
	[menuItem setScale: scale];
	[menuItem setAnchorPoint: ccp(0.5, 0.5)];
	[menuItem setPosition: ccp((gear.contentSize.width / 1.5 * gear.scale) + startingPoint.x + ((editorButtonSize + editorButtonPadding) * [menuItems count]), startingPoint.y)];
    [menuItems addObject: menuItem];
    
    //ROPE TOOL
    menuItem = [CCMenuItemImage itemWithNormalImage: @"Media/Buttons/general/button_editor_rope.png" selectedImage: @"Media/Buttons/general/button_editor_rope.png" block:^(id sender) {
        [self setDrawingMode: DRAWING_MODE_ROPE];
    }];
    if (menuItem.contentSize.width > menuItem.contentSize.height)
		scale = editorButtonSize / menuItem.contentSize.width;
	else
		scale = editorButtonSize / menuItem.contentSize.height;
	[menuItem setScale: scale];
	[menuItem setAnchorPoint: ccp(0.5, 0.5)];
	[menuItem setPosition: ccp((gear.contentSize.width / 1.5 * gear.scale) + startingPoint.x + ((editorButtonSize + editorButtonPadding) * [menuItems count]), startingPoint.y)];
    [menuItems addObject: menuItem];
    
    //BALLOON TOOL
    menuItem = [CCMenuItemImage itemWithNormalImage: @"Media/Buttons/general/button_editor_balloon.png" selectedImage: @"Media/Buttons/general/button_editor_balloon.png" block:^(id sender) {
        [self setDrawingMode: DRAWING_MODE_BALLOON];
    }];
    if (menuItem.contentSize.width > menuItem.contentSize.height)
		scale = editorButtonSize / menuItem.contentSize.width;
	else
		scale = editorButtonSize / menuItem.contentSize.height;
	[menuItem setScale: scale];
	[menuItem setAnchorPoint: ccp(0.5, 0.5)];
	[menuItem setPosition: ccp((gear.contentSize.width / 1.5 * gear.scale) + startingPoint.x + ((editorButtonSize + editorButtonPadding) * [menuItems count]), startingPoint.y)];
    [menuItems addObject: menuItem];
    
    //PIVOT TOOL
    menuItem = [CCMenuItemImage itemWithNormalImage: @"Media/Buttons/general/button_editor_pivot.png" selectedImage: @"Media/Buttons/general/button_editor_pivot.png" block:^(id sender) {
        [self setDrawingMode: DRAWING_MODE_PIVOT];
    }];
    if (menuItem.contentSize.width > menuItem.contentSize.height)
		scale = editorButtonSize / menuItem.contentSize.width;
	else
		scale = editorButtonSize / menuItem.contentSize.height;
	[menuItem setScale: scale];
	[menuItem setAnchorPoint: ccp(0.5, 0.5)];
	[menuItem setPosition: ccp((gear.contentSize.width / 1.5 * gear.scale) + startingPoint.x + ((editorButtonSize + editorButtonPadding) * [menuItems count]), startingPoint.y)];
    [menuItems addObject: menuItem];
    
    //STATIC TOOL
    menuItem = [CCMenuItemImage itemWithNormalImage: @"Media/Buttons/general/button_editor_static.png" selectedImage: @"Media/Buttons/general/button_editor_static.png" block:^(id sender) {
		[self setDrawingMode: DRAWING_MODE_STATIC];
    }];
    if (menuItem.contentSize.width > menuItem.contentSize.height)
		scale = editorButtonSize / menuItem.contentSize.width;
	else
		scale = editorButtonSize / menuItem.contentSize.height;
	[menuItem setScale: scale];
	[menuItem setAnchorPoint: ccp(0.5, 0.5)];
	[menuItem setPosition: ccp((gear.contentSize.width / 1.5 * gear.scale) + startingPoint.x + ((editorButtonSize + editorButtonPadding) * [menuItems count]), startingPoint.y)];
    [menuItems addObject: menuItem];
    
    //MOTOR TOOL
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
    }];
    if (menuItem.contentSize.width > menuItem.contentSize.height)
		scale = editorButtonSize / menuItem.contentSize.width;
	else
		scale = editorButtonSize / menuItem.contentSize.height;
	[menuItem setTag: 0];
	[menuItem setScale: scale];
	[menuItem setAnchorPoint: ccp(0.5, 0.5)];
	[menuItem setPosition: ccp((gear.contentSize.width / 1.5 * gear.scale) + startingPoint.x + ((editorButtonSize + editorButtonPadding) * [menuItems count]), startingPoint.y)];
    [menuItems addObject: menuItem];
    
    //WELD TOOL
    menuItem = [CCMenuItemImage itemWithNormalImage: @"Media/Buttons/general/button_editor_weld.png" selectedImage: @"Media/Buttons/general/button_editor_weld.png" block:^(id sender) {
        [self setDrawingMode: DRAWING_MODE_WELD];
    }];
    if (menuItem.contentSize.width > menuItem.contentSize.height)
		scale = editorButtonSize / menuItem.contentSize.width;
	else
		scale = editorButtonSize / menuItem.contentSize.height;
	[menuItem setScale: scale];
	[menuItem setAnchorPoint: ccp(0.5, 0.5)];
	[menuItem setPosition: ccp((gear.contentSize.width / 1.5 * gear.scale) + startingPoint.x + ((editorButtonSize + editorButtonPadding) * [menuItems count]), startingPoint.y)];
    [menuItems addObject: menuItem];
    
    //POPPABLE TOOL
    menuItem = [CCMenuItemImage itemWithNormalImage: @"Media/Buttons/general/button_editor_poppable.png" selectedImage: @"Media/Buttons/general/button_editor_poppable.png" block:^(id sender) {
        [self setDrawingMode: DRAWING_MODE_POPPABLE];
    }];
    if (menuItem.contentSize.width > menuItem.contentSize.height)
		scale = editorButtonSize / menuItem.contentSize.width;
	else
		scale = editorButtonSize / menuItem.contentSize.height;
	[menuItem setScale: scale];
	[menuItem setAnchorPoint: ccp(0.5, 0.5)];
	[menuItem setPosition: ccp((gear.contentSize.width / 1.5 * gear.scale) + startingPoint.x + ((editorButtonSize + editorButtonPadding) * [menuItems count]), startingPoint.y)];
    [menuItems addObject: menuItem];
    
    //BOUNCY TOOL
    menuItem = [CCMenuItemImage itemWithNormalImage: @"Media/Buttons/general/button_editor_bouncy.png" selectedImage: @"Media/Buttons/general/button_editor_bouncy.png" block:^(id sender) {
		[self setDrawingMode: DRAWING_MODE_BOUNCY];
}];
    if (menuItem.contentSize.width > menuItem.contentSize.height)
		scale = editorButtonSize / menuItem.contentSize.width;
	else
		scale = editorButtonSize / menuItem.contentSize.height;
	[menuItem setScale: scale];
	[menuItem setAnchorPoint: ccp(0.5, 0.5)];
	[menuItem setPosition: ccp((gear.contentSize.width / 1.5 * gear.scale) + startingPoint.x + ((editorButtonSize + editorButtonPadding) * [menuItems count]), startingPoint.y)];
    [menuItems addObject: menuItem];
    
    //HELP
    menuItem = [CCMenuItemImage itemWithNormalImage: @"Media/Buttons/general/button_editor_help.png" selectedImage: @"Media/Buttons/general/button_editor_help.png" block:^(id sender) {
        //TODO: Make this pop up the help when hit.
    }];
    if (menuItem.contentSize.width > menuItem.contentSize.height)
		scale = editorButtonSize / menuItem.contentSize.width;
	else
		scale = editorButtonSize / menuItem.contentSize.height;
	[menuItem setScale: scale];
	[menuItem setAnchorPoint: ccp(0.5, 0.5)];
	[menuItem setPosition: ccp((gear.contentSize.width / 1.5 * gear.scale) + startingPoint.x + ((editorButtonSize + editorButtonPadding) * [menuItems count]), startingPoint.y)];
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
    menuItem = [CCMenuItemImage itemWithNormalImage: @"Media/Buttons/general/button_editor_play.png" selectedImage: @"Media/Buttons/general/button_editor_play.png" block:^(id sender) {
		[Director shared].paused = NO;
    }];
	if (menuItem.contentSize.width > menuItem.contentSize.height)
		scale = editorLeftButtonSize / menuItem.contentSize.width;
	else
		scale = editorLeftButtonSize / menuItem.contentSize.height;
	[menuItem setScale: scale];
	[menuItem setAnchorPoint: ccp(0.5, 0.5)];
	[menuItem setPosition: ccp(startingPoint.x, (gear.contentSize.height / 1.5 * gear.scale) + startingPoint.y + ((editorLeftButtonSize + editorButtonPadding) * [menuItems count]))];
    [menuItems addObject: menuItem];
	
	//SAVE
    menuItem = [CCMenuItemImage itemWithNormalImage: @"Media/Buttons/general/button_editor_save.png" selectedImage: @"Media/Buttons/general/button_editor_save.png" block:^(id sender) {
		[self saveStage];
    }];
	if (menuItem.contentSize.width > menuItem.contentSize.height)
		scale = editorLeftButtonSize / menuItem.contentSize.width;
	else
		scale = editorLeftButtonSize / menuItem.contentSize.height;
	[menuItem setScale: scale];
	[menuItem setAnchorPoint: ccp(0.5, 0.5)];
	[menuItem setPosition: ccp(startingPoint.x, (gear.contentSize.height / 1.5 * gear.scale) + startingPoint.y + ((editorLeftButtonSize + editorButtonPadding) * [menuItems count]))];
    [menuItems addObject: menuItem];
	
	//BACKGROUND
    menuItem = [CCMenuItemImage itemWithNormalImage: @"Media/Buttons/general/button_editor_grid.png" selectedImage: @"Media/Buttons/general/button_editor_grid.png" block:^(id sender) {
		[self changeBackground];
    }];
	if (menuItem.contentSize.width > menuItem.contentSize.height)
		scale = editorLeftButtonSize / menuItem.contentSize.width;
	else
		scale = editorLeftButtonSize / menuItem.contentSize.height;
	[menuItem setScale: scale];
	[menuItem setAnchorPoint: ccp(0.5, 0.5)];
	[menuItem setPosition: ccp(startingPoint.x, (gear.contentSize.height / 1.5 * gear.scale) + startingPoint.y + ((editorLeftButtonSize + editorButtonPadding) * [menuItems count]))];
    [menuItems addObject: menuItem];
	
	//ROTATE
    menuItem = [CCMenuItemImage itemWithNormalImage: @"Media/Buttons/general/button_editor_rotate.png" selectedImage: @"Media/Buttons/general/button_editor_rotate.png" block:^(id sender) {
		[self setDrawingMode: DRAWING_MODE_ROTATE];
    }];
	if (menuItem.contentSize.width > menuItem.contentSize.height)
		scale = editorLeftButtonSize / menuItem.contentSize.width;
	else
		scale = editorLeftButtonSize / menuItem.contentSize.height;
	[menuItem setScale: scale];
	[menuItem setAnchorPoint: ccp(0.5, 0.5)];
	[menuItem setPosition: ccp(startingPoint.x, (gear.contentSize.height / 1.5 * gear.scale) + startingPoint.y + ((editorLeftButtonSize + editorButtonPadding) * [menuItems count]))];
    [menuItems addObject: menuItem];
	
	//DELETE
    menuItem = [CCMenuItemImage itemWithNormalImage: @"Media/Buttons/general/button_editor_trashcan.png" selectedImage: @"Media/Buttons/general/button_editor_trashcan.png" block:^(id sender) {
		[self setDrawingMode: DRAWING_MODE_DELETE];
    }];
	if (menuItem.contentSize.width > menuItem.contentSize.height)
		scale = editorLeftButtonSize / menuItem.contentSize.width;
	else
		scale = editorLeftButtonSize / menuItem.contentSize.height;
	[menuItem setScale: scale];
	[menuItem setAnchorPoint: ccp(0.5, 0.5)];
	[menuItem setPosition: ccp(startingPoint.x, (gear.contentSize.height / 1.5 * gear.scale) + startingPoint.y + ((editorLeftButtonSize + editorButtonPadding) * [menuItems count]))];
    [menuItems addObject: menuItem];
	
	//COPY
    menuItem = [CCMenuItemImage itemWithNormalImage: @"Media/Buttons/general/button_editor_plus.png" selectedImage: @"Media/Buttons/general/button_editor_plus.png" block:^(id sender) {
		[self setDrawingMode: DRAWING_MODE_COPY];
    }];
	if (menuItem.contentSize.width > menuItem.contentSize.height)
		scale = editorLeftButtonSize / menuItem.contentSize.width;
	else
		scale = editorLeftButtonSize / menuItem.contentSize.height;
	[menuItem setScale: scale];
	[menuItem setAnchorPoint: ccp(0.5, 0.5)];
	[menuItem setPosition: ccp(startingPoint.x, (gear.contentSize.height / 1.5 * gear.scale) + startingPoint.y + ((editorLeftButtonSize + editorButtonPadding) * [menuItems count]))];
    [menuItems addObject: menuItem];
	
	//UNDO
    menuItem = [CCMenuItemImage itemWithNormalImage: @"Media/Buttons/general/button_editor_undo.png" selectedImage: @"Media/Buttons/general/button_editor_undo.png" block:^(id sender) {
		[self undoLastObject];
    }];
	if (menuItem.contentSize.width > menuItem.contentSize.height)
		scale = editorLeftButtonSize / menuItem.contentSize.width;
	else
		scale = editorLeftButtonSize / menuItem.contentSize.height;
	[menuItem setScale: scale];
	[menuItem setAnchorPoint: ccp(0.5, 0.5)];
	[menuItem setPosition: ccp(startingPoint.x, (gear.contentSize.height / 1.5 * gear.scale) + startingPoint.y + ((editorLeftButtonSize + editorButtonPadding) * [menuItems count]))];
    [menuItems addObject: menuItem];
	
	//MOVE
    menuItem = [CCMenuItemImage itemWithNormalImage: @"Media/Buttons/general/button_editor_select.png" selectedImage: @"Media/Buttons/general/button_editor_select.png" block:^(id sender) {
		[self setDrawingMode: DRAWING_MODE_SELECTION];
    }];
	if (menuItem.contentSize.width > menuItem.contentSize.height)
		scale = editorLeftButtonSize / menuItem.contentSize.width;
	else
		scale = editorLeftButtonSize / menuItem.contentSize.height;
	[menuItem setScale: scale];
	[menuItem setAnchorPoint: ccp(0.5, 0.5)];
	[menuItem setPosition: ccp(startingPoint.x, (gear.contentSize.height / 1.5 * gear.scale) + startingPoint.y + ((editorLeftButtonSize + editorButtonPadding) * [menuItems count]))];
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

- (void) changeStageName: (DialogLayer *) diaglayer
{
    [Director shared].stage.name = diaglayer.textField.text;
    [stageNameItem setString: [Director shared].stage.name];
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
	//It is recommended that a fixed time step is used with Box2D for stability
	//of the simulation, however, we are using a variable time step here.
	//You need to make an informed choice, the following URL is useful
	//http://gafferongames.com/game-physics/fix-your-timestep/
	
	// Instruct the world to perform a single step of simulation. It is
	// generally best to keep the time step and iterations fixed.
    if (![Director shared].paused)
    {
        dt = 1.0 / 60.0;
        [self worldTick: dt];
    }
}

- (void) worldTick: (ccTime) dt
{
    int32 velocityIterations = 8;
    int32 positionIterations = 1;
    
    [Director shared].world->Step(dt, velocityIterations, positionIterations);
    
    for (Object *object in [[Director shared].stage objects])
    {
        if (object.alive)
            [object tick: dt];
    }
    
    //Check and see if Chuck has dropped out of the stage. If so, reset or win.
    if (chuck.body)
    {
        float yPos = chuck.body->GetTransform().p.y;
        float xPos = chuck.body->GetTransform().p.x;
        
        if (yPos <= 0 || yPos > ([CCDirector sharedDirector].winSize.height + chuck->height) / PTM_RATIO || xPos <= 0 - chuck->height / PTM_RATIO || xPos >= ([CCDirector sharedDirector].winSize.width + chuck->height) / PTM_RATIO)
        {
            [self winStage];
        }
    }
    //NSLog(@"%f of %f", chuck.curPos.y, self.boundingBox.size.height);
}

- (void) winStage
{
	if ([Director shared].editing)
	{
		[self resetStage];
	}
	else
	{
		[self showWinScreen];
		[Director shared].paused = YES;
	}
}

- (void) showWinScreen
{
	DialogLayer *winDialog = [[DialogLayer alloc] initWithHeader: @"A WINNER IS YOU!" andLine1: @"Stage win message!" target: self selector: @selector(goToNextStage) textField: NO];
	[self addChild: winDialog z: 9000];
}

- (void) goToNextStage
{
	[self goToStageSelect];
}

- (void) resetStage
{
	if ([Director shared].editing)
	{
		[Director shared].paused = YES;
    }
		
    for (Object *object in [[Director shared].stage objects])
    {
        [object reset];
        //world->Step(0.0001, 0, 1);
        
        /*for (Object *object in [[Director shared].stage objects])
        {
            [object tick: 0.0001];
        }*/
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
            Object *obj = (Object *)selectedObject;
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
        if (CGRectContainsPoint([object.bodyVisible boundingBox], location))
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
				
				if (object.restitution != 0.9f)
					 [object setRestitution: 0.9f];
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
        }
        
        if (!selector)
        {
            selector = [CCSprite spriteWithFile: @"Media/Objects/selector.png"];
            [self addChild: selector z: 8999];
        }
        
        Object *object = (Object *)selectedObject;
        
        if (selectedObject)
        {
            selector.position = object.centerPos;
            selector.visible = YES;
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
            float dx = (object.curPos.x + object.widthAbs / 2) - location.x;
            float dy = (object.curPos.y + object.heightAbs / 2) - location.y;
            float angle = atan2(dy, dx);
            
            object.rotationAngle = angle;
            
            touchStart = location;
            
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
        {
            //Add a new point to the touches array so we can track where the rope is going.            
            [drawPoints addObject: touch];
            
            break;
        }
            
        //Balloon
        case DRAWING_MODE_BALLOON:
        {      
            
            
            break;
        }
    }
    
    Object *object = (Object *)selectedObject;
    selector.position = object.centerPos;
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
            
    }

    selectedObject = nil;
    selectedObject2 = nil;
    
    selector.visible = NO;
}

- (CGPoint) snapLocation: (CGPoint) location
{
	float gridSpacing = self.snapDivider;
	float gridOffset = 0;
	
	location.x -= ((int)location.x % (int)gridSpacing);
	location.y -= ((int)location.y % (int)gridSpacing);
	
	//location.x = nearbyintf((location.x - gridOffset) / gridSpacing) * gridSpacing + gridOffset;
	//location.y = nearbyintf((location.y - gridOffset) / gridSpacing) * gridSpacing + gridOffset;
	
	return location;
}

#pragma mark GOTOS

- (void) goToMainMenu
{
	DialogLayer *quitConfirm = [[DialogLayer alloc] initWithHeader: @"Confirm" andLine1: @"Are you sure you want to exit to the main menu?" target: self selector: @selector(quitConfirm) textField: NO andExistingText: @"" andCancelButton: YES];
	[self addChild: quitConfirm z: 9000];
}

- (void) quitConfirm
{
	[Director shared].stage = nil;
	[Director shared].stageName = nil;
	[[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration: 0.5 scene: [MainMenuLayer scene]]];
}

- (void) goToStageSave
{
	[[CCDirector sharedDirector] replaceScene: [CCTransitionSlideInT transitionWithDuration: 0.5 scene: [StageSaveLayer scene]]];
}

- (void) goToStageSelect
{
	[[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration: 0.5 scene: [StageSelectLayer scene]]];
}

#pragma mark SETTERS/GETTERS


@end
