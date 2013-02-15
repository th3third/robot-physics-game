//
//  DialogLayer.m
//  concentrate
//
//  Created by Paul Legato on 12/4/10.
//  Copyright 2010 Paul Legato. All rights reserved.
//

#import "DialogLayer.h"
#import "Director.h"
#import "Layers.h"
#import "MToolsPurchaseManager.h"
#import "MToolsAppSettings.h"

#define DIALOG_FONT @"Segoe Print"
#define DIALOG_FONT_SIZE 18
#define DIALOG_FONT_SIZE_TITLE 20
#define DIALOG_FONT_SIZE_TAG 36
#define DIALOG_FONT_SHADOW_OFFSET 0.5
#define DIALOG_FONT_OFFSET 5

@implementation DialogLayer

@synthesize callbackObj;
@synthesize selector;

- (id) init
{
	if (self = [super init])
	{
		if ([Director shared].currentDialog)
		{
			[[Director shared].currentDialog remove];
		}
		
		[Director shared].currentDialog = self;
	}
	
	return self;
}

- (id) initWithHeader:(NSString *)header andLine1:(NSString *)line1 target:(id)callbackObjNew selector:(SEL)selectorNew textField: (bool) doTextField
{
	return [self initWithHeader: header andLine1: line1 target: callbackObjNew selector: selectorNew textField: doTextField andExistingText: @"" andCancelButton: NO];
}

- (id) initWithHeader:(NSString *)headerIn andLine1:(NSString *)line1 target:(id)callbackObjNew selector:(SEL)selectorNew textField: (bool) doTextField andExistingText: (NSString *) existingText andCancelButton: (bool) addCancelButton
{
	self.dialogType = 0;
	
    if((self = [self init]))
    {
        header = headerIn;
        callbackObj = callbackObjNew;
        selector = selectorNew;
        
        CCSprite *background = [self createBackground];
        
        CCLabelTTF *line1Label = [CCLabelTTF labelWithString: line1 fontName: DIALOG_FONT fontSize: DIALOG_FONT_SIZE * [Director shared].scaleFactor.width];
        line1Label.color = ccBLACK;
        line1Label.scale = 0.84f;
        line1Label.dimensions = CGSizeMake(backgroundWidth * 0.9, backgroundHeight * 0.75);
        [line1Label setPosition:ccp(background.position.x, background.position.y + DIALOG_FONT_OFFSET)];
        [self addChild:line1Label];
        
		NSMutableArray *buttons = [NSMutableArray array];
		float okButtonPosX = background.position.x;
		if (addCancelButton)
		{
			okButtonPosX += backgroundWidth / 4;
			CCMenuItemImage *cancelButton = [CCMenuItemImage itemFromNormalImage:@"Media/Buttons/general/button_dialog_cancel.png" selectedImage:@"Media/Buttons/general/button_dialog_cancel.png" target:self selector:@selector(cancelButtonPressed:)];
			cancelButton.scale = (backgroundWidth * 0.2) / cancelButton.contentSize.width;
			[cancelButton setPosition: ccp(background.position.x - backgroundWidth / 4, background.position.y - backgroundHeight / 5)];
			[buttons addObject: cancelButton];
		}
		
		CCMenuItemImage *okButton = [CCMenuItemImage itemFromNormalImage:@"Media/Buttons/general/button_dialog_ok.png" selectedImage:@"Media/Buttons/general/button_dialog_ok.png" target:self selector:@selector(okButtonPressed:)];
		okButton.scale = (backgroundWidth * 0.2) / okButton.contentSize.width;
        [okButton setPosition: ccp(okButtonPosX, background.position.y - backgroundHeight / 5)];
		[buttons addObject: okButton];
        
        CCMenu *menu = [CCMenu menuWithArray: buttons];
        menu.position = ccp(0, -backgroundHeight / 6 + DIALOG_FONT_OFFSET);
        [self addChild:menu];
		
        if (doTextField)
        {
            self.textField = [[UITextField alloc] initWithFrame: CGRectMake(0, 0, backgroundWidth * 0.8, 24 * [Director shared].scaleFactor.height)];
            self.textField.borderStyle = UITextBorderStyleRoundedRect;
            self.textField.center = ccp([[CCDirector sharedDirector] view].center.x , [[CCDirector sharedDirector] view].center.y - backgroundHeight / 4);
            self.textField.delegate = self;
			[self.textField setPlaceholder: existingText];
			[self.textField becomeFirstResponder];
            [[[CCDirector sharedDirector] view] addSubview: self.textField];
            line1Label.dimensions = CGSizeMake(backgroundWidth * 0.9, backgroundHeight * 0.75 - 48);
            line1Label.position = ccp (line1Label.position.x, line1Label.position.y - 24);
        }
    }
    
    return self;
}

- (id) initNotificationWithMessage: (NSString *) message
{
	return [self initNotificationWithMessage: message callback: nil selector: nil];
}

- (id) initChoiceWithMessage: (NSString *) message callback: (id) callbackObjNew selector: (SEL) selectorNew
{
	if (self = [self init])
	{
		callbackObj = callbackObjNew;
		selector = selectorNew;
		
		CCSprite *background = [self createBackground];
		CGSize s = [CCDirector sharedDirector].winSize;
		
		CCLabelTTF *messageLabel = [DialogLayer createShadowHeaderWithString: message
																	position: ccp(background.position.x, background.position.y + backgroundHeight * 0.1)
																shadowOffset: CGSizeMake(1, -1)
																	   color: ccWHITE
																 shadowColor: ccBLACK
																  dimensions: CGSizeMake(backgroundWidth * 0.8, backgroundHeight * 0.7)
																  hAlignment: kCCTextAlignmentCenter
																  vAlignment: kCCVerticalTextAlignmentCenter
															   lineBreakMode: kCCLineBreakModeWordWrap
																	fontSize: DIALOG_FONT_SIZE * [Director shared].scaleFactor.width
									];
		[self addChild: messageLabel];
		
		//Cancel
		CCMenuItemImage *cancelButton = [CCMenuItemImage itemFromNormalImage:@"Media/Buttons/general/button_dialog_cancel.png" selectedImage:@"Media/Buttons/general/button_dialog_cancel.png" target:self selector:@selector(cancelButtonPressed:)];
		cancelButton.scale = (backgroundWidth * 0.225) / cancelButton.contentSize.width;
		[cancelButton setPosition: ccp(background.position.x - backgroundWidth * 0.25, background.position.y - backgroundHeight * 0.35)];
		
		//Okay
		CCMenuItemImage *okButton = [CCMenuItemImage itemFromNormalImage:@"Media/Buttons/general/button_dialog_ok.png" selectedImage:@"Media/Buttons/general/button_dialog_ok.png" target:self selector:@selector(okButtonPressed:)];
		okButton.scale = (backgroundWidth * 0.225) / okButton.contentSize.width;
		[okButton setPosition: ccp(background.position.x + backgroundWidth * 0.25, background.position.y - backgroundHeight * 0.35)];
		
		CCMenu *cancelAndOkMenu = [CCMenu menuWithItems: cancelButton, okButton, nil];
		[cancelAndOkMenu setAnchorPoint: ccp(0, 0)];
		[cancelAndOkMenu setPosition: CGPointZero];
		[self addChild: cancelAndOkMenu];
	}
	
	return self;
}

- (id) initNotificationWithMessage: (NSString *) message callback: (id) callbackObjNew selector: (SEL) selectorNew
{
	if (self = [self init])
	{
		callbackObj = callbackObjNew;
		selector = selectorNew;
		
		CCSprite *background = [self createBackground];
		CGSize s = [CCDirector sharedDirector].winSize;
		
		CCLabelTTF *messageLabel = [DialogLayer createShadowHeaderWithString: message
																	position: ccp(background.position.x, background.position.y + backgroundHeight * 0.1)
																shadowOffset: CGSizeMake(1, -1)
																	   color: ccWHITE
																 shadowColor: ccBLACK
																  dimensions: CGSizeMake(backgroundWidth * 0.8, backgroundHeight * 0.7)
																  hAlignment: kCCTextAlignmentCenter
																  vAlignment: kCCVerticalTextAlignmentCenter
															   lineBreakMode: kCCLineBreakModeWordWrap
																	fontSize: DIALOG_FONT_SIZE * [Director shared].scaleFactor.width
									];
		[self addChild: messageLabel];
		
		//Okay
		CCMenuItemImage *okayButton;
		if (!callbackObj || !selector)
		{
			okayButton = [CCMenuItemImage itemFromNormalImage:@"Media/Buttons/general/button_dialog_ok.png" selectedImage:@"Media/Buttons/general/button_dialog_ok.png" target:self selector:@selector(cancelButtonPressed:)];
		}
		else
		{
			okayButton = [CCMenuItemImage itemFromNormalImage:@"Media/Buttons/general/button_dialog_ok.png" selectedImage:@"Media/Buttons/general/button_dialog_ok.png" target:self selector:@selector(okButtonPressed:)];
		}
		
		okayButton.scale = (backgroundWidth * 0.225) / okayButton.contentSize.width;
		[okayButton setPosition: ccp(background.position.x, background.position.y - backgroundHeight * 0.35)];
		
		CCMenu *okayMenu = [CCMenu menuWithItems: okayButton, nil];
		[okayMenu setAnchorPoint: ccp(0, 0)];
		[okayMenu setPosition: CGPointZero];
		[self addChild: okayMenu];
	}
	
	return self;
}

- (id) initStageMenuWithHeader: (NSString *) headerIn target: (id) callbackObjNew selector: (SEL) selectorNew
{
	self.dialogType = 2;
	
    if((self = [self init]))
    {
        header = headerIn;
        callbackObj = callbackObjNew;
        selector = selectorNew;
        
        CCSprite *background = [self createBackground];
        
		if ([Director shared].editing)
		{			
			CCLabelTTF *line1Label = [CCLabelTTF labelWithString: [NSString stringWithFormat: @"Are you sure you want to exit to the main menu and abandon your level? If you have not saved your level it will be lost."] fontName: DIALOG_FONT fontSize: DIALOG_FONT_SIZE * [Director shared].scaleFactor.width];
			line1Label.color = ccBLACK;
			line1Label.scale = 0.84f;
			line1Label.dimensions = CGSizeMake(backgroundWidth * 0.9, backgroundHeight * 0.75);
			[line1Label setPosition:ccp(background.position.x, background.position.y + DIALOG_FONT_OFFSET)];
			[self addChild:line1Label];
		}
		else
		{
			CCLabelTTF *line1Label = [CCLabelTTF labelWithString: [NSString stringWithFormat: @"You are playing %@\n\nWhat would you like to do?", [Director shared].stage.name] fontName: DIALOG_FONT fontSize: DIALOG_FONT_SIZE * [Director shared].scaleFactor.width];
			line1Label.color = ccBLACK;
			line1Label.scale = 0.84f;
			line1Label.dimensions = CGSizeMake(backgroundWidth * 0.9, backgroundHeight * 0.75);
			[line1Label setPosition:ccp(background.position.x, background.position.y + DIALOG_FONT_OFFSET)];
			[self addChild:line1Label];
		}
        
		NSMutableArray *buttons = [NSMutableArray array];
		float okButtonPosX = background.position.x;
		okButtonPosX += backgroundWidth / 4;
		
			CCMenuItemImage *cancelButton = [CCMenuItemImage itemFromNormalImage:@"Media/Buttons/general/button_dialog_cancel.png" selectedImage:@"Media/Buttons/general/button_dialog_cancel.png" target:self selector:@selector(cancelButtonPressed:)];
			cancelButton.scale = (backgroundWidth * 0.2) / cancelButton.contentSize.width;
			[cancelButton setPosition: ccp(background.position.x - backgroundWidth / 4, background.position.y - backgroundHeight / 5)];
			[buttons addObject: cancelButton];
		
		if ([Director shared].online && ![Director shared].editing)
		{
			CCMenuItemImage *okButton = [CCMenuItemImage itemFromNormalImage:@"Media/Buttons/general/button_dialog_levels.png" selectedImage:@"Media/Buttons/general/button_dialog_levels.png" target:self selector:@selector(nextStageButtonPressed:)];
			okButton.scale = (backgroundWidth * 0.2) / okButton.contentSize.width;
			[okButton setPosition: ccp(okButtonPosX, background.position.y - backgroundHeight / 5)];
			[buttons addObject: okButton];
		
			NSLog(@"Compare: %@ with %@", [Director shared].stage.creator, [Director shared].username);
			if ([[Director shared].stage.creator isEqualToString: [Director shared].username])
			{
				CCMenuItemImage *flagButton = [CCMenuItemImage itemFromNormalImage:@"Media/Buttons/general/button_dialog_edit.png" selectedImage:@"Media/Buttons/general/button_dialog_edit.png" target:self selector:@selector(editButtonPressed:)];
				flagButton.scale = (backgroundWidth * 0.2) / okButton.contentSize.width;
				[flagButton setPosition: ccp(background.position.x, background.position.y - backgroundHeight / 5)];
				[buttons addObject: flagButton];
			}
			else
			{
				CCMenuItemImage *flagButton = [CCMenuItemImage itemFromNormalImage:@"Media/Buttons/general/button_dialog_flag.png" selectedImage:@"Media/Buttons/general/button_dialog_flag.png" target:self selector:@selector(flagButtonPressed:)];
				flagButton.scale = (backgroundWidth * 0.2) / okButton.contentSize.width;
				[flagButton setPosition: ccp(background.position.x, background.position.y - backgroundHeight / 5)];
				[buttons addObject: flagButton];
			}
		}
		else if ([Director shared].editing)
		{
			CCMenuItemImage *okButton = [CCMenuItemImage itemFromNormalImage:@"Media/Buttons/general/button_dialog_ok.png" selectedImage:@"Media/Buttons/general/button_dialog_ok.png" target:self selector:@selector(okButtonPressed:)];
			okButton.scale = (backgroundWidth * 0.2) / okButton.contentSize.width;
			[okButton setPosition: ccp(okButtonPosX, background.position.y - backgroundHeight / 5)];
			[buttons addObject: okButton];
		}
		else
		{
			CCMenuItemImage *okButton = [CCMenuItemImage itemFromNormalImage:@"Media/Buttons/general/button_dialog_levels.png" selectedImage:@"Media/Buttons/general/button_dialog_levels.png" target:self selector:@selector(nextStageButtonPressed:)];
			okButton.scale = (backgroundWidth * 0.2) / okButton.contentSize.width;
			[okButton setPosition: ccp(okButtonPosX, background.position.y - backgroundHeight / 5)];
			[buttons addObject: okButton];
		}
        
        CCMenu *menu = [CCMenu menuWithArray: buttons];
        menu.position = ccp(0, -backgroundHeight / 6 + DIALOG_FONT_OFFSET);
        [self addChild:menu];
    }
    
    return self;
}

- (id) initWinnerWithHeader: (NSString *) headerIn target: (id) callbackObjNew selector: (SEL) selectorNew andTimeElapsed: (float) timeElapsed andScore:(int)score
{
	self.dialogType = 2;
	
    if((self = [self init]))
    {
        header = headerIn;
        callbackObj = callbackObjNew;
        selector = selectorNew;
        
        CCSprite *background = [self createBackground];
        
		NSMutableArray *buttons = [NSMutableArray array];
		float okButtonPosX = background.position.x;
		okButtonPosX += backgroundWidth / 4;
		
		CCSprite *levelCompletedSprite = [CCSprite spriteWithFile: @"Media/Buttons/general/level_complete/button_dialog_level_completed.png"];
		[levelCompletedSprite setScale: (backgroundWidth * 0.70) / levelCompletedSprite.contentSize.width];
		[levelCompletedSprite setPosition:ccp(background.position.x, background.position.y + (backgroundHeight / 2) * 0.625)];
		[self addChild: levelCompletedSprite];
		
		//Play again button.
		CCMenuItemImage *retryButton = [CCMenuItemImage itemFromNormalImage:@"Media/Buttons/general/level_complete/button_dialog_play_again.png" selectedImage:@"Media/Buttons/general/level_complete/button_dialog_play_again.png" target:self selector:@selector(retryButtonPressed:)];
		retryButton.scale = levelCompletedSprite.scale;
		[retryButton setPosition: ccp(background.position.x - (backgroundWidth / 2) * 0.35, background.position.y + (backgroundHeight / 2) * 0.425)];
		[buttons addObject: retryButton];
		
		if ([Director shared].online)
		{
			CCMenuItemImage *okButton = [CCMenuItemImage itemFromNormalImage:@"Media/Buttons/general/level_complete/button_dialog_next_level.png" selectedImage:@"Media/Buttons/general/level_complete/button_dialog_next_level.png" target:self selector:@selector(nextStageButtonPressed:)];
			okButton.scale = (backgroundWidth * 0.2) / okButton.contentSize.width;
			[okButton setPosition: ccp(okButtonPosX, background.position.y - backgroundHeight / 5)];
			[buttons addObject: okButton];
			
			if (![[Director shared].stage.creator isEqualToString: [Director shared].username])
			{
				likeButton = [CCMenuItemImage itemFromNormalImage:@"Media/Buttons/general/button_dialog_thumbs_up.png" selectedImage:@"Media/Buttons/general/button_dialog_thumbs_up.png" target:self selector:@selector(likeButtonPressed:)];
				likeButton.scale = (backgroundWidth * 0.2) / likeButton.contentSize.width;
				[likeButton setPosition: ccp(okButtonPosX + backgroundWidth / 8, background.position.y)];
				[buttons addObject: likeButton];
				
				ratingThanksLabel = [DialogLayer createShadowHeaderWithString: @"Thank you for rating!"
																	   position: ccp(okButtonPosX, background.position.y)
																   shadowOffset: CGSizeMake(1, -1)
																		  color: ccWHITE
																	shadowColor: ccBLACK
																	 dimensions: CGSizeMake(backgroundWidth * 0.8, backgroundHeight * 0.7)
																	 hAlignment: kCCTextAlignmentCenter
																	 vAlignment: kCCVerticalTextAlignmentCenter
																  lineBreakMode: kCCLineBreakModeWordWrap
																	   fontSize: DIALOG_FONT_SIZE * [Director shared].scaleFactor.width
									   ];
				[self addChild: ratingThanksLabel];
				[ratingThanksLabel setVisible: NO];
				
				dislikeButton = [CCMenuItemImage itemFromNormalImage:@"Media/Buttons/general/button_dialog_thumbs_down.png" selectedImage:@"Media/Buttons/general/button_dialog_thumbs_down.png" target:self selector:@selector(dislikeButtonPressed:)];
				dislikeButton.scale = (backgroundWidth * 0.2) / okButton.contentSize.width;
				[dislikeButton setPosition: ccp(okButtonPosX - backgroundWidth / 8, background.position.y)];
				[buttons addObject: dislikeButton];
			}			
		}
		else
		{
			//Next level button.
			CCMenuItemImage *nextLevelButton = [CCMenuItemImage itemFromNormalImage:@"Media/Buttons/general/level_complete/button_dialog_next_level.png" selectedImage:@"Media/Buttons/general/level_complete/button_dialog_next_level.png" target:self selector:@selector(nextStageButtonPressed:)];
			nextLevelButton.scale = retryButton.scale;
			[nextLevelButton setPosition: ccp(background.position.x + (backgroundWidth / 2) * 0.55, background.position.y + (backgroundHeight / 2) * 0.425)];
			[buttons addObject: nextLevelButton];
		}
		
		if ([Director shared].online)
		{
			if ([[Director shared].stage.creator isEqualToString: [Director shared].username])
			{
				CCMenuItemImage *flagButton = [CCMenuItemImage itemFromNormalImage:@"Media/Buttons/general/button_dialog_edit.png" selectedImage:@"Media/Buttons/general/button_dialog_edit.png" target:self selector:@selector(editButtonPressed:)];
				flagButton.scale = (backgroundWidth * 0.2) / flagButton.contentSize.width;
				[flagButton setPosition: ccp(background.position.x, background.position.y - backgroundHeight / 5)];
				[buttons addObject: flagButton];
			}
			else
			{
				CCMenuItemImage *flagButton = [CCMenuItemImage itemFromNormalImage:@"Media/Buttons/general/button_dialog_flag.png" selectedImage:@"Media/Buttons/general/button_dialog_flag.png" target:self selector:@selector(flagButtonPressed:)];
				flagButton.scale = (backgroundWidth * 0.2) / flagButton.contentSize.width;
				[flagButton setPosition: ccp(background.position.x, background.position.y - backgroundHeight / 5)];
				[buttons addObject: flagButton];
			}
		}
		NSLog(@"Creator is %@", [Director shared].stage.creator);
		
		//Star rating and level time.
		//Background
		CCSprite *ratingBackgroundSprite = [CCSprite spriteWithFile: @"Media/Buttons/general/level_complete/button_dialog_win_rating_background.png"];
		[ratingBackgroundSprite setScale: (backgroundWidth * 0.50) / ratingBackgroundSprite.contentSize.width];
		[ratingBackgroundSprite setPosition:ccp(background.position.x, background.position.y - (backgroundHeight / 2) * 0.45)];
		[self addChild: ratingBackgroundSprite];

        //Level time.
		NSString *message = [NSString stringWithFormat: @"Level Time: %.2f", timeElapsed];
		CCLabelTTF *levelTime = [DialogLayer createShadowHeaderWithString: message position: ccp(0, 0) shadowOffset: CGSizeMake(1, -1) color: ccWHITE shadowColor: ccBLACK dimensions: CGSizeMake((ratingBackgroundSprite.contentSize.width * 2), (ratingBackgroundSprite.contentSize.height)) hAlignment:kCCTextAlignmentCenter lineBreakMode: kCCLineBreakModeClip fontSize: ((ratingBackgroundSprite.contentSize.width * 1.5) / [message length])];
		[levelTime setPosition: ccp(((ratingBackgroundSprite.contentSize.width) * 0.5), ((ratingBackgroundSprite.contentSize.height * 0.35)))];
		[ratingBackgroundSprite addChild: levelTime z: 67];
		
		//Stars
		if (![Director shared].online)
		{
			//Create stars.
			float maxTime = [[Director shared] getScoreForLevel: [NSString stringWithFormat: @"%@.ctr", [Director shared].stage.name]];
			int score;		
			if (timeElapsed < maxTime)
				score = 3;
			else if (timeElapsed < maxTime * 1.5)
				score = 2;
			else
				score = 1;
			
			if (![Director shared].online)
			{
				for (int i = 1; i <= 3; i++)
				{
					CCSprite *star;
					
					if (score >= i)
					{
						star = [CCSprite spriteWithFile: @"Media/Buttons/general/level_complete/button_dialog_star.png"];
					}
					else
					{
						star = [CCSprite spriteWithFile: @"Media/Buttons/general/level_complete/button_dialog_star_empty.png"];
					}
					[star setPosition: ccp(
										   i * ((ratingBackgroundSprite.contentSize.width) * 0.25),
										   (ratingBackgroundSprite.contentSize.height) / 2.5
										   )];
					[star setScale: ((ratingBackgroundSprite.contentSize.width * 0.25) / star.contentSize.width)];
					[ratingBackgroundSprite addChild: star z: 66];
				}
			}
		}
		
        CCMenu *menu = [CCMenu menuWithArray: buttons];
        menu.position = ccp(0, -backgroundHeight / 6 + DIALOG_FONT_OFFSET);
        [self addChild:menu];
    }
    
    return self;
}

- (id) initOnlineMenuWithCallbackObj: (id) callbackObjNew selector: (SEL) selectorNew
{
	self.dialogType = 1;
	
	if (self = [self init])
	{
		
	}
}

- (id) initFlaggerWithHeader: (NSString *) headerIn target: (id) callbackObjNew selector: (SEL) selectorNew andLevelName: (NSString *) levelName
{
	self.dialogType = 2;
	
    if((self = [self init]))
    {
        header = headerIn;
        callbackObj = callbackObjNew;
        selector = selectorNew;
        
        CCSprite *background = [self createBackground];
        
        CCLabelTTF *line1Label = [CCLabelTTF labelWithString: [NSString stringWithFormat: @"You are about to flag %@ for inappropriate content. Are you sure you wish to do this?", levelName] fontName: DIALOG_FONT fontSize: DIALOG_FONT_SIZE * [Director shared].scaleFactor.width];
        line1Label.color = ccBLACK;
        line1Label.scale = 0.84f;
        line1Label.dimensions = CGSizeMake(backgroundWidth * 0.9, backgroundHeight * 0.75);
        [line1Label setPosition:ccp(background.position.x, background.position.y + DIALOG_FONT_OFFSET)];
        [self addChild:line1Label];
        
		NSMutableArray *buttons = [NSMutableArray array];
		float okButtonPosX = background.position.x;
		okButtonPosX += backgroundWidth / 4;
		
		CCMenuItemImage *noButton = [CCMenuItemImage itemFromNormalImage:@"Media/Buttons/general/button_dialog_no.png" selectedImage:@"Media/Buttons/general/button_dialog_no.png" target:self selector:@selector(cancelButtonPressed:)];
		noButton.scale = (backgroundWidth * 0.2) / noButton.contentSize.width;
		[noButton setPosition: ccp(background.position.x - backgroundWidth / 4, background.position.y - backgroundHeight / 5)];
		[buttons addObject: noButton];
		
		CCMenuItemImage *yesButton = [CCMenuItemImage itemWithNormalImage: @"Media/Buttons/general/button_dialog_yes.png" selectedImage: @"Media/Buttons/general/button_dialog_yes.png" block:^(id sender) {
			[self flagConfirmButtonPressed: nil];
		}];
		yesButton.scale = (backgroundWidth * 0.2) / noButton.contentSize.width;
		[yesButton setPosition: ccp(background.position.x + backgroundWidth / 4, background.position.y - backgroundHeight / 5)];
		[buttons addObject: yesButton];
        
        CCMenu *menu = [CCMenu menuWithArray: buttons];
        menu.position = ccp(0, -backgroundHeight / 6 + DIALOG_FONT_OFFSET);
        [self addChild:menu];
    }
    
    return self;
}

- (id) initSaveWithCallbackObj: (id) callbackObjNew selector: (SEL) selectorNew
{
	self.dialogType = 3;
	
	if (self = [self init])
	{
		callbackObj = callbackObjNew;
        selector = selectorNew;
		
		CCSprite *background = [self createBackground];
		
		//Name your level title
		CCLabelTTF *nameYourLevelTitle = [DialogLayer createShadowHeaderWithString: @"Name Your Level"
																	 position: ccp(background.position.x, background.position.y + backgroundHeight * 0.375)
																 shadowOffset: CGSizeMake(1, -1)
																		color: ccWHITE
																  shadowColor: ccBLACK
																   dimensions: CGSizeMake(background.contentSize.width * background.scaleX, (background.contentSize.height * background.scaleY) * 0.2)
																   hAlignment: kCCTextAlignmentCenter
																lineBreakMode: kCCLineBreakModeMiddleTruncation
																	 fontSize: DIALOG_FONT_SIZE_TITLE * [Director shared].scaleFactor.width
									 ];
		[self addChild: nameYourLevelTitle];
		
		//Name of level background
		CCSprite *nameLevelInputBackground = [CCSprite spriteWithFile: @"Media/Buttons/general/level_save/button_level_name_background.png"];
		[nameLevelInputBackground setScale: (backgroundWidth * 0.6) / nameLevelInputBackground.contentSize.width];
		[nameLevelInputBackground setPosition: ccp(background.position.x, background.position.y + backgroundHeight * 0.275)];
		[self addChild: nameLevelInputBackground];
		
		//Input text box
		self.textField = [[CustomTextField alloc] initWithFrame: CGRectMake(0, 0, (nameLevelInputBackground.contentSize.width * nameLevelInputBackground.scale * 0.9), (nameLevelInputBackground.contentSize.height * nameLevelInputBackground.scale) * 0.75)];
		self.textField.center = ccp([[CCDirector sharedDirector] view].center.x, [[CCDirector sharedDirector] view].center.y - backgroundHeight * 0.3);
		self.textField.borderStyle = UITextBorderStyleNone;
		[self.textField setBackgroundColor: [UIColor clearColor]];
		[self.textField setFont: [UIFont fontWithName: [Director shared].globalFont size: DIALOG_FONT_SIZE_TITLE * [Director shared].scaleFactor.width]];
		[self.textField setPlaceholder: @"Enter name here"
		 ];
		self.textField.delegate = self;
		[self.textField becomeFirstResponder];
		self.textField.keyboardType = UIKeyboardAppearanceDefault;
		self.textField.returnKeyType = UIReturnKeyDone;
		self.textField.autocorrectionType = UITextAutocapitalizationTypeNone;
		self.textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
		[[[CCDirector sharedDirector] openGLView] addSubview: self.textField];
		
		//Name of creator (filled in with default logged in user.
		CCSprite *creatorNameBackground = [CCSprite spriteWithFile: @"Media/Buttons/general/level_save/button_level_creator_background.png"];
		[creatorNameBackground setScale: (backgroundWidth * 0.6) / nameLevelInputBackground.contentSize.width];
		[creatorNameBackground setPosition: ccp(background.position.x, background.position.y + backgroundHeight * 0.125)];
		[self addChild: creatorNameBackground];
		
		NSString *username;
		
		if (![Director shared].username)
			username = @"You";
		else
			username = [Director shared].username;
		
		CCLabelTTF *creatorName = [DialogLayer createShadowHeaderWithString: username
																   position: ccp(creatorNameBackground.position.x + backgroundWidth * 0.025, creatorNameBackground.position.y + backgroundHeight * 0.01)
															   shadowOffset: CGSizeMake(1, -1)
																	  color: ccWHITE
																shadowColor: ccBLACK
																 dimensions: CGSizeMake((creatorNameBackground.contentSize.width * creatorNameBackground.scale), (creatorNameBackground.contentSize.height * creatorNameBackground.scale))
																 hAlignment: kCCTextAlignmentLeft
															  lineBreakMode: kCCLineBreakModeMiddleTruncation
																   fontSize: DIALOG_FONT_SIZE_TITLE * [Director shared].scaleFactor.width
								   ];
		[self addChild: creatorName];
		
		//Tag your level title
		CCLabelTTF *tagYourLevelTitle = [DialogLayer createShadowHeaderWithString: @"Tag Your Level"
																		  position: ccp(background.position.x, background.position.y - backgroundHeight * 0.025)
																	  shadowOffset: CGSizeMake(1, -1)
																			 color: ccWHITE
																	   shadowColor: ccBLACK
																		dimensions: CGSizeMake(background.contentSize.width * background.scaleX, (background.contentSize.height * background.scaleY) * 0.2)
																		hAlignment: kCCTextAlignmentCenter
																	 lineBreakMode: kCCLineBreakModeMiddleTruncation
																		  fontSize: DIALOG_FONT_SIZE_TITLE * [Director shared].scaleFactor.width
										  ];
		[self addChild: tagYourLevelTitle];
		
		//Tag background.
		CCSprite *tagBackground = [CCSprite spriteWithFile: @"Media/Buttons/general/level_save/button_level_tags_background.png"];
		[tagBackground setScale: (backgroundWidth * 0.6) / nameLevelInputBackground.contentSize.width];
		[tagBackground setPosition: ccp(background.position.x, background.position.y - backgroundHeight * 0.175)];
		[self addChild: tagBackground];
		
		//Create all the tag names.
		NSMutableArray *tagNames = [NSMutableArray array];
		[tagNames addObject: @"destructive"];
		[tagNames addObject: @"crazy"];
		[tagNames addObject: @"hard"];
		[tagNames addObject: @"bouncy"];
		[tagNames addObject: @"short"];
		[tagNames addObject: @"puzzle"];
		[tagNames addObject: @"artistic"];
		[tagNames addObject: @"timing"];
		//Togglable tags.
		CCMenuItemToggle *menuItem;
		CCMenu *menu;
		NSMutableArray *menuItems = [NSMutableArray array];
		
		float offOpacity = 100;
		int row = 0;
		int col = 0;
		CGPoint startingPos = ccp(tagBackground.position.x - (tagBackground.contentSize.width * tagBackground.scale) * 0.35, tagBackground.position.y + (tagBackground.contentSize.height * tagBackground.scale) * 0.225);
		for (NSString *tagName in tagNames)
		{
			CCSprite *tagOnSprite = [CCSprite spriteWithFile: @"Media/Buttons/general/tags/tag_blank_1.png"];
			CCSprite *tagOnSelectedSprite = [CCSprite spriteWithFile: @"Media/Buttons/general/tags/tag_blank_1.png"];
			[tagOnSelectedSprite setScale: 0.95];
			
			CCSprite *tagOffSprite = [CCSprite spriteWithFile: @"Media/Buttons/general/tags/tag_blank_1.png"];
			[tagOffSprite setOpacity: offOpacity];
			CCSprite *tagOffSelectedSprite = [CCSprite spriteWithFile: @"Media/Buttons/general/tags/tag_blank_1.png"];
			[tagOffSelectedSprite setScale: 0.95];
			[tagOffSelectedSprite setOpacity: offOpacity];
			
			//Tag on
			CCLabelTTF *tagLabel;
			tagLabel = [DialogLayer createShadowHeaderWithString: tagName
																	position: ccp(tagOnSprite.contentSize.width / 2, tagOnSprite.contentSize.height / 2)
																shadowOffset: CGSizeMake(1, -1)
																	   color: ccWHITE
																 shadowColor: ccBLACK
																  dimensions: CGSizeMake(tagOnSprite.contentSize.width, tagOnSprite.contentSize.height)
																  hAlignment: kCCTextAlignmentCenter
															   lineBreakMode: kCCLineBreakModeMiddleTruncation
																	fontSize: DIALOG_FONT_SIZE_TAG
									];
			[tagOnSprite addChild: tagLabel];
			
			tagLabel = [DialogLayer createShadowHeaderWithString: tagName
														position: ccp(tagOnSelectedSprite.contentSize.width / 2, tagOnSelectedSprite.contentSize.height / 2)
													shadowOffset: CGSizeMake(1, -1)
														   color: ccWHITE
													 shadowColor: ccBLACK
													  dimensions: CGSizeMake(tagOnSelectedSprite.contentSize.width, tagOnSelectedSprite.contentSize.height)
													  hAlignment: kCCTextAlignmentCenter
												   lineBreakMode: kCCLineBreakModeMiddleTruncation
														fontSize: DIALOG_FONT_SIZE_TAG
						];
			[tagOnSelectedSprite addChild: tagLabel];
			
			//Tag off
			tagLabel = [DialogLayer createShadowHeaderWithString: tagName
														position: ccp(tagOffSprite.contentSize.width / 2, tagOffSprite.contentSize.height / 2)
													shadowOffset: CGSizeMake(1, -1)
														   color: ccWHITE
													 shadowColor: ccBLACK
													  dimensions: CGSizeMake(tagOffSprite.contentSize.width, tagOffSprite.contentSize.height)
													  hAlignment: kCCTextAlignmentCenter
												   lineBreakMode: kCCLineBreakModeMiddleTruncation
														fontSize: DIALOG_FONT_SIZE_TAG
						];
			[tagLabel setOpacity: offOpacity];
			[tagOffSprite addChild: tagLabel];
			
			tagLabel = [DialogLayer createShadowHeaderWithString: tagName
														position: ccp(tagOffSelectedSprite.contentSize.width / 2, tagOffSelectedSprite.contentSize.height / 2)
													shadowOffset: CGSizeMake(1, -1)
														   color: ccWHITE
													 shadowColor: ccBLACK
													  dimensions: CGSizeMake(tagOffSelectedSprite.contentSize.width, tagOffSelectedSprite.contentSize.height)
													  hAlignment: kCCTextAlignmentCenter
												   lineBreakMode: kCCLineBreakModeMiddleTruncation
														fontSize: DIALOG_FONT_SIZE_TAG
						];
			[tagLabel setOpacity: offOpacity];
			[tagOffSelectedSprite addChild: tagLabel];
			
			CCMenuItem *menuItemOn = [CCMenuItemSprite itemWithNormalSprite: tagOnSprite selectedSprite: tagOnSelectedSprite];
			CCMenuItem *menuItemOff = [CCMenuItemSprite itemWithNormalSprite: tagOffSprite selectedSprite: tagOffSelectedSprite];
			
			NSArray *toggleItems = [NSArray arrayWithObjects: menuItemOff, menuItemOn, nil];
			
			menuItem = [CCMenuItemToggle itemWithItems: toggleItems block:^(id sender) {
				[self toggleTag: tagName];
			}];
			[menuItem setScale: ((tagBackground.contentSize.width * tagBackground.scale) * 0.2) / menuItem.contentSize.width];
			
			for (NSString *tag in [Director shared].stage.tags)
			{
				if ([tag isEqualToString: tagName])
				{
					[menuItem activate];
				}
			}
			
			if (col >= 4)
			{
				row++;
				col = 0;
			}
			
			
			[menuItem setPosition: ccp(startingPos.x + ((menuItem.contentSize.width * menuItem.scale + 9.5) * col), startingPos.y - ((menuItem.contentSize.height * menuItem.scale) * row))];
			[menuItems addObject: menuItem];
			
			col++;
		}
		
		menu = [CCMenu menuWithArray: menuItems];
		[menu setAnchorPoint: ccp(0, 0)];
		[menu setPosition: CGPointZero];
		[self addChild: menu];
		
		//Cancel
		CCMenuItemImage *cancelButton = [CCMenuItemImage itemFromNormalImage:@"Media/Buttons/general/level_save/button_cancel_level.png" selectedImage:@"Media/Buttons/general/level_save/button_cancel_level.png" target:self selector:@selector(cancelButtonPressed:)];
		cancelButton.scale = (backgroundWidth * 0.225) / cancelButton.contentSize.width;
		[cancelButton setPosition: ccp(background.position.x - backgroundWidth * 0.25, background.position.y - backgroundHeight * 0.35)];
		
		//Save
		CCMenuItemImage *saveButton = [CCMenuItemImage itemFromNormalImage:@"Media/Buttons/general/level_save/button_save_level.png" selectedImage:@"Media/Buttons/general/level_save/button_save_level.png" target:self selector:@selector(saveButtonPressed:)];
		saveButton.scale = (backgroundWidth * 0.225) / cancelButton.contentSize.width;
		[saveButton setPosition: ccp(background.position.x + backgroundWidth * 0.25, background.position.y - backgroundHeight * 0.35)];
		
		CCMenu *cancelAndSaveMenu = [CCMenu menuWithItems: cancelButton, saveButton, nil];
		[cancelAndSaveMenu setAnchorPoint: ccp(0, 0)];
		[cancelAndSaveMenu setPosition: CGPointZero];
		[self addChild: cancelAndSaveMenu];
	}
				
	return self;
}

- (id) initPurchaseWithCallbackObj: (id) callbackObjNew selector: (SEL) selectorNew
{
	if (self = [self init])
	{		
		callbackObj = callbackObjNew;
		selector = selectorNew;
		
		CCSprite *background = [self createBackground];
		
		//Restore purchases.
		CCSprite *restorePurchasesSprite = [CCSprite spriteWithFile: @"Media/Buttons/general/purchase/button_restore_purchases.png"];
		CCSprite *restorePurchasesSelectedSprite = [CCSprite spriteWithFile: @"Media/Buttons/general/purchase/button_restore_purchases.png"];
		[restorePurchasesSelectedSprite setScale: 0.95];
		CCMenuItemSprite *restorePurchasesMenuItem = [CCMenuItemSprite itemWithNormalSprite: restorePurchasesSprite selectedSprite: restorePurchasesSelectedSprite block:^(id sender) {
			[self restorePurchases];
		}];
		[restorePurchasesMenuItem setScale: (backgroundWidth * 0.66) / restorePurchasesMenuItem.contentSize.width];
		[restorePurchasesMenuItem setPosition: ccp(background.position.x, background.position.y - backgroundHeight * 0.55)];
		
		//Purchase the full game label.
		CCLabelTTF *purchaseFullGameLabel = [DialogLayer createShadowHeaderWithString: @"Purchase Full Game"
																		position: ccp(background.position.x - backgroundWidth * 0.16, background.position.y + backgroundHeight * 0.375)
																	shadowOffset: CGSizeMake(1, -1)
																		   color: ccWHITE
																	 shadowColor: ccBLACK
																	  dimensions: CGSizeMake(backgroundWidth * 0.5, backgroundHeight * 0.15)
																	  hAlignment: kCCTextAlignmentLeft
																   lineBreakMode: kCCLineBreakModeMiddleTruncation
																		fontSize: DIALOG_FONT_SIZE * [Director shared].scaleFactor.width
										];
		
		[self addChild: purchaseFullGameLabel];
		
		//Full game description label.
		CCLabelTTF *fullGameDescLabel = [DialogLayer createShadowHeaderWithString: @"- All levels become playable!\n- Access to Online Levels!\n- Save and upload your own custom made Online Levels!\n- Support indie developers!"
																			 position: ccp(background.position.x - backgroundWidth * 0.2, background.position.y + backgroundHeight * 0.350)
																		 shadowOffset: CGSizeMake(1, -1)
																				color: ccWHITE
																		  shadowColor: ccBLACK
																		   dimensions: CGSizeMake(backgroundWidth * 0.45, backgroundHeight * 0.5)
																		   hAlignment: kCCTextAlignmentLeft
																		lineBreakMode: kCCLineBreakModeWordWrap
																			 fontSize: (DIALOG_FONT_SIZE * 0.6) * [Director shared].scaleFactor.width
											 ];
		[fullGameDescLabel setAnchorPoint: ccp(0.5, 1)];
		[self addChild: fullGameDescLabel];
		
		//Full game purchase button.
		CCSprite *purchaseFullGameSprite = [CCSprite spriteWithFile: @"Media/Buttons/general/main_menu/button_full_game_purchase.png"];
		CCSprite *purchaseFullGameSelectedSprite = [CCSprite spriteWithFile: @"Media/Buttons/general/main_menu/button_full_game_purchase.png"];
		[purchaseFullGameSelectedSprite setScale: 0.95];
		CCMenuItemSprite *purchaseFullGameMenuItem = [CCMenuItemSprite itemWithNormalSprite: purchaseFullGameSprite selectedSprite: purchaseFullGameSelectedSprite block:^(id sender) {
			[[MToolsPurchaseManager sharedManager] purchaseProductByName: @"fullversion"];
		}];
		[purchaseFullGameMenuItem setScale: (backgroundWidth * 0.33) / purchaseFullGameMenuItem.contentSize.width];
		[purchaseFullGameMenuItem setPosition: ccp(background.position.x + backgroundWidth * 0.25, background.position.y + backgroundHeight * 0.2)];
		
		CCMenu *purchaseMenu = [CCMenu menuWithItems: purchaseFullGameMenuItem, restorePurchasesMenuItem, nil];
		[purchaseMenu setAnchorPoint: ccp(0, 0)];
		[purchaseMenu setPosition: CGPointZero];
		[self addChild: purchaseMenu];
		
		//Icon to overlay on the purchase button if we've already got the full version.
		if ([[MToolsPurchaseManager sharedManager] productPurchased: @"fullversion"])
		{
			CCSprite *purchasedIcon = [CCSprite spriteWithFile: @"Media/Buttons/general/purchase/button_bought_icon.png"];
			[purchasedIcon setScale: (purchaseFullGameMenuItem.contentSize.width * purchaseFullGameMenuItem.scaleX) / purchasedIcon.contentSize.width];
			[purchasedIcon setPosition: purchaseFullGameMenuItem.position];
			[purchasedIcon setOpacity: 100];
			[purchaseFullGameMenuItem setOpacity: 150];
			[self addChild: purchasedIcon];
		}
		
		//Unlock Chuck's Friends label
		CCLabelTTF *unlockFriendsLabel = [DialogLayer createShadowHeaderWithString: @"Unlock Chuck's Friends"
																			 position: ccp(background.position.x, background.position.y - backgroundHeight * 0.1)
																		 shadowOffset: CGSizeMake(1, -1)
																				color: ccWHITE
																		  shadowColor: ccBLACK
																		   dimensions: CGSizeMake(backgroundWidth, backgroundHeight * 0.15)
																		   hAlignment: kCCTextAlignmentCenter
																		lineBreakMode: kCCLineBreakModeMiddleTruncation
																			 fontSize: DIALOG_FONT_SIZE * [Director shared].scaleFactor.width
											 ];
		[self addChild: unlockFriendsLabel];
		
		//See how many bots are available for purchase.
		NSMutableArray *botMenuItems = [NSMutableArray array];
		NSArray *botsForPurchase = [NSArray arrayWithObjects: @"1", @"1", @"1", @"1", @"1", @"1", nil];
		for (int i = 0; i < [botsForPurchase count]; i++)
		{
			CCSprite *botSprite = [CCSprite spriteWithFile: [NSString stringWithFormat: @"Media/Buttons/general/purchase/button_purchase_bot_%@.png", [botsForPurchase objectAtIndex: i]]];
			CCSprite *botSelectedSprite = [CCSprite spriteWithFile: [NSString stringWithFormat: @"Media/Buttons/general/purchase/button_purchase_bot_%@.png", [botsForPurchase objectAtIndex: i]]];
			[botSelectedSprite setScale: 0.95];
			
			CCMenuItemSprite *botMenuItem = [CCMenuItemSprite itemWithNormalSprite: botSprite selectedSprite: botSelectedSprite block:^(id sender) {
				[[MToolsPurchaseManager sharedManager] purchaseProductByName: [NSString stringWithFormat:@"botskin%@", [botsForPurchase objectAtIndex: i]]];
			}];
			[botMenuItem setScale: ((backgroundWidth * 0.12) / botMenuItem.contentSize.width)];
			[botMenuItem setPosition: ccp(background.position.x - backgroundWidth * 0.3 + (i * (botMenuItem.contentSize.width * botMenuItem.scale)), background.position.y - backgroundHeight * 0.25)];
			
			[botMenuItems addObject: botMenuItem];
		}
		
		CCMenu *botMenu = [CCMenu menuWithArray: botMenuItems];
		[botMenu setAnchorPoint: ccp(0, 0)];
		[botMenu setPosition: ccp(0, 0)];
		[self addChild: botMenu];
	}
	
	return self;
}

- (id) initCreditsWithCallbackObj: (id) callbackObjNew selector: (SEL) selectorNew
{
	if (self = [self init])
	{
		CCSprite *background = [self createBackground];
	}
	
	return self;
}

- (id) initLoginWithCallbackObj: (id) callbackObjNew selector: (SEL) selectorNew
{
	self.dialogType = 4;
	
    if((self = [self init]))
    {
        callbackObj = callbackObjNew;
        selector = selectorNew;
        
        CCSprite *background = [self createBackground];
     
		CGSize s = [CCDirector sharedDirector].winSize;
		NSMutableArray *buttons = [NSMutableArray array];
		float okButtonPosX = background.position.x;
		okButtonPosX += backgroundWidth / 4;
		
		CCSprite *loginTitleSprite = [CCSprite spriteWithFile: @"Media/Buttons/general/login/button_login_title.png"];
		[loginTitleSprite setScale: (backgroundWidth * 0.40) / loginTitleSprite.contentSize.width];
		[loginTitleSprite setPosition:ccp(background.position.x, background.position.y + (backgroundHeight / 2) * 0.625)];
		[self addChild: loginTitleSprite];
		
		//Username input background
		CCSprite *usernameInputBackground = [CCSprite spriteWithFile: @"Media/Buttons/general/level_save/button_level_name_background.png"];
		[usernameInputBackground setScale: (backgroundWidth * 0.6) / usernameInputBackground.contentSize.width];
		[usernameInputBackground setPosition: ccp(background.position.x, background.position.y + backgroundHeight * 0.1)];
		[self addChild: usernameInputBackground];
		
		//Username input text box
		self.textField = [[CustomTextField alloc] initWithFrame: CGRectMake(0, 0, (usernameInputBackground.contentSize.width * usernameInputBackground.scale * 0.9), (usernameInputBackground.contentSize.height * usernameInputBackground.scale) * 0.75)];
		self.textField.center = ccp(background.position.x, background.position.y - backgroundHeight * 0.125);
		self.textField.borderStyle = UITextBorderStyleNone;
		[self.textField setBackgroundColor: [UIColor clearColor]];
		[self.textField setFont: [UIFont fontWithName: [Director shared].globalFont size: DIALOG_FONT_SIZE_TITLE * [Director shared].scaleFactor.width]];
		[self.textField setPlaceholder: @"Username"
		 ];
		self.textField.delegate = self;
		[self.textField becomeFirstResponder];
		self.textField.keyboardType = UIKeyboardAppearanceDefault;
		self.textField.returnKeyType = UIReturnKeyNext;
		self.textField.autocorrectionType = UITextAutocapitalizationTypeNone;
		self.textField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
		self.textField.tag = 0;
		[[[CCDirector sharedDirector] openGLView] addSubview: self.textField];
		
		//Password input background
		CCSprite *passwordInputBackground = [CCSprite spriteWithFile: @"Media/Buttons/general/level_save/button_level_creator_background.png"];
		[passwordInputBackground setScale: (backgroundWidth * 0.6) / passwordInputBackground.contentSize.width];
		[passwordInputBackground setPosition: ccp(background.position.x, background.position.y - backgroundHeight * 0.05)];
		[self addChild: passwordInputBackground];
		
		//Password input text box
		self.textField2 = [[CustomTextField alloc] initWithFrame: CGRectMake(0, 0, (passwordInputBackground.contentSize.width * passwordInputBackground.scale * 0.9), (passwordInputBackground.contentSize.height * passwordInputBackground.scale) * 0.75)];
		self.textField2.center = ccp(background.position.x, background.position.y + backgroundHeight * 0.025);
		self.textField2.borderStyle = UITextBorderStyleNone;
		[self.textField2 setBackgroundColor: [UIColor clearColor]];
		[self.textField2 setFont: [UIFont fontWithName: [Director shared].globalFont size: DIALOG_FONT_SIZE_TITLE * [Director shared].scaleFactor.width]];
		[self.textField2 setPlaceholder: @"Password"
		 ];
		self.textField2.delegate = self;
		self.textField2.keyboardType = UIKeyboardAppearanceDefault;
		self.textField2.returnKeyType = UIReturnKeyDone;
		self.textField2.autocorrectionType = UITextAutocapitalizationTypeNone;
		self.textField2.autocapitalizationType = UITextAutocapitalizationTypeNone;
		self.textField2.secureTextEntry = YES;
		self.textField2.tag = 1;
		[[[CCDirector sharedDirector] openGLView] addSubview: self.textField2];
		
		//Cancel
		CCMenuItemImage *cancelButton = [CCMenuItemImage itemFromNormalImage:@"Media/Buttons/general/button_dialog_cancel.png" selectedImage:@"Media/Buttons/general/button_dialog_cancel.png" target:self selector:@selector(cancelButtonPressed:)];
		cancelButton.scale = (backgroundWidth * 0.225) / cancelButton.contentSize.width;
		[cancelButton setPosition: ccp(background.position.x - backgroundWidth * 0.25, background.position.y - backgroundHeight * 0.35)];
		
		//Next
		CCMenuItemImage *nextButton = [CCMenuItemImage itemFromNormalImage:@"Media/Buttons/general/button_dialog_next.png" selectedImage:@"Media/Buttons/general/button_dialog_next.png" target:self selector:@selector(loginButtonPressed:)];
		nextButton.scale = (backgroundWidth * 0.225) / nextButton.contentSize.width;
		[nextButton setPosition: ccp(background.position.x + backgroundWidth * 0.25, background.position.y - backgroundHeight * 0.35)];
		
		CCMenu *cancelAndNextMenu = [CCMenu menuWithItems: cancelButton, nextButton, nil];
		[cancelAndNextMenu setAnchorPoint: ccp(0, 0)];
		[cancelAndNextMenu setPosition: CGPointZero];
		[self addChild: cancelAndNextMenu];
    }
    
    return self;
}

#pragma mark MISC JUNK BUTT FART

- (void) toggleTag: (NSString *) tagString
{
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

- (CCSprite *) createBackground
{
	CGSize s = [CCDirector sharedDirector].winSize;
	
	//This is the invisible closing background which will remove the notification window if hit.
	CCMenuItemImage *closeMenuItem = [CCMenuItemImage itemWithNormalImage: @"Media/Backgrounds/blank.jpg" selectedImage: @"Media/Backgrounds/blank.jpg" target: self selector: @selector(remove)];
	[closeMenuItem setScaleX: (s.width / closeMenuItem.contentSize.width)];
	[closeMenuItem setScaleY: (s.height / closeMenuItem.contentSize.height)];
	[closeMenuItem setOpacity: 100];
	
	CCMenu *closeMenu = [CCMenu menuWithItems: closeMenuItem, nil];
	[self addChild: closeMenu z: -2];
	
	CCSprite *background = [CCSprite node];
	background = [background initWithFile: @"Media/Backgrounds/general/dialog.png"];
	float scale = (s.width * .75) / background.contentSize.width;
	[background setScale: scale];
	[background setPosition:ccp(s.width / 2, s.height / 2)];
	[self addChild:background z:-1];
	
	backgroundWidth = background.contentSize.width * background.scale;
	backgroundHeight = background.contentSize.height * background.scale;
	
	return background;
}

+ (CCSprite *) createTextWithShadow: (NSString *) string textSize: (float) textSize
{
	CCLabelTTF *headerShadow = [CCLabelTTF labelWithString: string fontName: DIALOG_FONT fontSize: textSize * [Director shared].scaleFactor.width];
	headerShadow.color = ccBLACK;
	headerShadow.opacity = 225;
	[headerShadow setPosition:ccp(1, -1)];
	
	CCLabelTTF *headerLabel = [CCLabelTTF labelWithString: string fontName: DIALOG_FONT fontSize: textSize * [Director shared].scaleFactor.width];
	headerLabel.color = ccWHITE;
	
	CCRenderTexture *renderTexture = [CCRenderTexture renderTextureWithWidth: headerLabel.contentSize.width height: headerLabel.contentSize.height];
	[renderTexture begin];
	[headerShadow draw];
	[headerLabel draw];
	[renderTexture end];
	
	CCSprite *retSprite = [CCSprite spriteWithTexture: renderTexture.sprite.texture];
	[retSprite setScaleY: -1];
	
	return retSprite;
}

+(CCLabelTTF*)createShadowHeaderWithString:(NSString*)string position:(CGPoint)pos shadowOffset:(CGSize)offset color:(ccColor3B)col shadowColor:(ccColor3B)shadowCol dimensions:(CGSize)dimensions hAlignment:(CCTextAlignment)uiTextAlignment lineBreakMode:(CCLineBreakMode)lineBreakMode fontSize:(float)fontSize
{
    return [DialogLayer createShadowHeaderWithString: string position: pos shadowOffset: offset color: col shadowColor: shadowCol dimensions: dimensions hAlignment: uiTextAlignment vAlignment: kCCVerticalTextAlignmentTop lineBreakMode:lineBreakMode fontSize: fontSize];
}

+(CCLabelTTF*)createShadowHeaderWithString:(NSString*)string position:(CGPoint)pos shadowOffset:(CGSize)offset color:(ccColor3B)col shadowColor:(ccColor3B)shadowCol dimensions:(CGSize)dimensions hAlignment:(CCTextAlignment)uiTextAlignment vAlignment: (CCVerticalTextAlignment) uiVTextAlignment lineBreakMode :(CCLineBreakMode)lineBreakMode fontSize:(float)fontSize
{
	float offsetX = offset.width;
    float offsetY = offset.height;
	
    //Shadow
    CCLabelTTF *shadow = [CCLabelTTF labelWithString:string dimensions:dimensions hAlignment: uiTextAlignment lineBreakMode: lineBreakMode fontName: [Director shared].globalFont fontSize:fontSize];
	shadow.verticalAlignment = uiVTextAlignment;
    shadow.position = ccp(pos.x + offsetX, pos.y + offsetY);
    shadow.color = shadowCol;
    shadow.opacity = (255/100*83);//83%
	
    //Actual
    CCLabelTTF *label = [CCLabelTTF labelWithString:string dimensions:dimensions hAlignment: uiTextAlignment lineBreakMode: lineBreakMode fontName: [Director shared].globalFont fontSize:fontSize];
	label.verticalAlignment = uiVTextAlignment;
    label.position = ccp(shadow.contentSize.width / 2 - offsetX, shadow.contentSize.height / 2 - offsetY);
    label.color = col;
    [shadow addChild:label];
	
    return shadow;
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
	if (self.dialogType == 0)
		[self okButtonPressed: self];
	else if (self.dialogType == 1)
		[self loginButtonPressed: self];
	else if (self.dialogType == 3)
		[self saveButtonPressed: self];
	else if (self.dialogType == 4)
	{
		NSInteger nextTag = textField.tag + 1;
		UIResponder *nextResponder = [textField.superview viewWithTag: nextTag];
		
		if (nextResponder)
		{
			[nextResponder becomeFirstResponder];
		}
		else
		{
			[textField resignFirstResponder];
			[self loginButtonPressed: self];
		}
	}
	
    return NO;
}

- (void) remove
{
	[self.textField removeFromSuperview];
	[self.textField2 removeFromSuperview];
    [self removeFromParentAndCleanup:YES];
}

#pragma mark BUTTON PRESSES

#pragma mark L purchases

- (void) restorePurchases
{
	[DialogLayer playButtonSound];
	
	[[MToolsPurchaseManager sharedManager] restorePurchases];
}

#pragma mark L ratings

- (void) likeButtonPressed: (id) sender
{
	[DialogLayer playButtonSound];
	
	[[Director shared] rateLevel: [Director shared].stage.name withRating: 1];
	[self submittedRating: self];
}

- (void) dislikeButtonPressed: (id) sender
{
	[DialogLayer playButtonSound];
	
	[[Director shared] rateLevel: [Director shared].stage.name withRating: -1];
	[self submittedRating: self];
}

- (void) submittedRating: (id) sender
{
	[ratingThanksLabel setVisible: YES];
	[dislikeButton setVisible: NO];
	[likeButton setVisible: NO];
}

- (void) flagButtonPressed: (id) sender
{
	[DialogLayer playButtonSound];
	
	DialogLayer *flagConfirmDialog = [[DialogLayer alloc] initFlaggerWithHeader: @"CONFIRM FLAG" target: self selector: @selector(flagConfirmButtonPressed:) andLevelName: [Director shared].stage.name];
	[self.parent addChild: flagConfirmDialog z: 9100];
	[self removeFromParentAndCleanup: YES];
}

- (void) flagConfirmButtonPressed: (id) sender
{
	[DialogLayer playButtonSound];
	
	[[Director shared] flagLevel: [Director shared].stage.name];
	DialogLayer *thankYouDialog = [[DialogLayer alloc] initWithHeader: @"THANK YOU" andLine1: @"Thank you for your report. We will investigate the level you have flagged and take the appropriate action." target: self selector: @selector(cancelButtonPressed:) textField: NO];
	[self.parent addChild: thankYouDialog z: 9100];
	[self removeFromParentAndCleanup: YES];
}


- (void) retryButtonPressed: (id) sender
{
	[DialogLayer playButtonSound];
	
	[callbackObj performSelector: selector withObject: [NSNumber numberWithBool: YES]];
}

- (void) nextStageButtonPressed: (id) sender
{
	[DialogLayer playButtonSound];
	
	[callbackObj performSelector: selector withObject: [NSNumber numberWithBool: NO]];
}

- (void) okButtonPressed:(id) sender
{
    [DialogLayer playButtonSound];
    
    [callbackObj performSelector: selector withObject: self];
    
    [self remove];
}

- (void) cancelButtonPressed:(id) sender
{
    [DialogLayer playButtonSound];
    
    [self remove];
}

- (void) loginButtonPressed:(id) sender
{
    [DialogLayer playButtonSound];
    
	NSArray *retArray = [NSArray arrayWithObjects: self.textField.text, [Director sha: self.textField2.text], nil];
	
    [callbackObj performSelector: selector withObject: retArray];
    
    [self.textField removeFromSuperview];
	[self.textField2 removeFromSuperview];
    [self removeFromParentAndCleanup:YES];
}

- (void) editButtonPressed: (id) sender
{
	[DialogLayer playButtonSound];
	
	[Director shared].editing = YES;
	[[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration: 0.0 scene: [StageLoadingLevel scene]]];
}

- (void) saveButtonPressed: (id) sender
{
	[DialogLayer playButtonSound];
	
	[Director shared].stage.name = self.textField.text;
	
	[self.textField removeFromSuperview];
	[self.textField2 removeFromSuperview];
    [self removeFromParentAndCleanup:YES];
	
	if (!currentTags)
	{
		currentTags = [NSMutableArray array];
	}
	
	[callbackObj performSelector: selector withObject: currentTags];
}

+ (void) playButtonSound
{
	[[SimpleAudioEngine sharedEngine] playEffect: @"Media/Audio/general/button_press.mp3"];
}

@end