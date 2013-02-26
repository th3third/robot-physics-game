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
        
        CCSprite *background = [self createBackgroundStatic];
        
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
		
		CCSprite *background = [self createBackgroundStatic];
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

- (id) initChoiceWithMessage: (NSString *) message callback: (id) callbackObjNew selector: (SEL) selectorNew selectorCancel: (SEL) selectorCancel
{
	if (self = [self init])
	{
		callbackObj = callbackObjNew;
		selector = selectorNew;
		
		CCSprite *background = [self createBackgroundStatic];
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
		CCMenuItemImage *cancelButton = [CCMenuItemImage itemWithNormalImage: @"Media/Buttons/general/button_dialog_cancel.png" selectedImage: @"Media/Buttons/general/button_dialog_cancel.png" block:^(id sender) {			
			if ((callbackObj && selectorCancel) && [callbackObj respondsToSelector: selectorCancel])
			{
				[callbackObj performSelector: selectorCancel];
			}
			[self cancelButtonPressed: nil];
		}];
		cancelButton.scale = (backgroundWidth * 0.225) / cancelButton.contentSize.width;
		[cancelButton setPosition: ccp(background.position.x - backgroundWidth * 0.25, background.position.y - backgroundHeight * 0.35)];
		
		//Okay
		CCMenuItemImage *okButton = [CCMenuItemImage itemWithNormalImage: @"Media/Buttons/general/button_dialog_ok.png" selectedImage: @"Media/Buttons/general/button_dialog_ok.png" block:^(id sender) {
			[self okButtonPressed: nil];
		}];
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
        
        CCSprite *background = [self createBackgroundStatic];
        
		NSMutableArray *buttons = [NSMutableArray array];
		float okButtonPosX = background.position.x;
		okButtonPosX += backgroundWidth / 4;
		
		CCSprite *levelCompletedSprite = [CCSprite spriteWithFile: @"Media/Buttons/general/button_dialog_paused.png"];
		[levelCompletedSprite setScale: (backgroundWidth * 0.70) / levelCompletedSprite.contentSize.width];
		[levelCompletedSprite setPosition:ccp(background.position.x, background.position.y + (backgroundHeight / 2) * 0.625)];
		[self addChild: levelCompletedSprite];
		
		//Play again button.
		CCMenuItemImage *retryButton = [CCMenuItemImage itemFromNormalImage:@"Media/Buttons/general/button_dialog_back.png" selectedImage:@"Media/Buttons/general/button_dialog_back.png" target:self selector:@selector(retryButtonPressed:)];
		retryButton.scale = levelCompletedSprite.scale;
		[retryButton setPosition: ccp(background.position.x - (backgroundWidth / 2) * 0.35, background.position.y + (backgroundHeight / 2) * 0.425)];
		[buttons addObject: retryButton];
		
		if ([Director shared].online)
		{
			CCMenuItemImage *resumeButton = [CCMenuItemImage itemWithNormalImage: @"Media/Buttons/general/button_dialog_resume.png" selectedImage: @"Media/Buttons/general/button_dialog_resume.png" block:^(id sender) {
				[self remove];
				[callbackObj performSelector: @selector(resumePlaying)];
			}];
			resumeButton.scale = retryButton.scale;
			[resumeButton setPosition: ccp(background.position.x + (backgroundWidth / 2) * 0.55, background.position.y + (backgroundHeight / 2) * 0.425)];
			[buttons addObject: resumeButton];
			
			if (![[Director shared].stage.creator isEqualToString: [Director shared].username])
			{
				likeButton = [CCMenuItemImage itemFromNormalImage:@"Media/Buttons/general/button_thumbs_up.png" selectedImage:@"Media/Buttons/general/button_thumbs_up.png" target:self selector:@selector(likeButtonPressed:)];
				likeButton.scale = (backgroundWidth * 0.125) / likeButton.contentSize.width;
				[likeButton setPosition: ccp(background.position.x + backgroundWidth * 0.1, background.position.y - backgroundHeight * 0.075)];
				[buttons addObject: likeButton];
				
				dislikeButton = [CCMenuItemImage itemFromNormalImage:@"Media/Buttons/general/button_thumbs_down.png" selectedImage:@"Media/Buttons/general/button_thumbs_down.png" target:self selector:@selector(dislikeButtonPressed:)];
				dislikeButton.scale = (backgroundWidth * 0.125) / dislikeButton.contentSize.width;
				[dislikeButton setPosition: ccp(background.position.x - backgroundWidth * 0.1, background.position.y - backgroundHeight * 0.075)];
				[buttons addObject: dislikeButton];
			}
		}
		else
		{
			//Resume button.
			CCMenuItemImage *nextLevelButton = [CCMenuItemImage itemFromNormalImage:@"Media/Buttons/general/level_complete/button_dialog_next_level.png" selectedImage:@"Media/Buttons/general/level_complete/button_dialog_next_level.png" target:self selector:@selector(nextStageButtonPressed:)];
			nextLevelButton.scale = retryButton.scale;
			[nextLevelButton setPosition: ccp(background.position.x + (backgroundWidth / 2) * 0.55, background.position.y + (backgroundHeight / 2) * 0.425)];
			[buttons addObject: nextLevelButton];
		}
		
		//Flag and edit buttons.
		if ([Director shared].online)
		{
			NSLog(@"Comparing %@ to %@", [[Director shared].stage.creator lowercaseString], [[Director shared].username lowercaseString]);
			if ([[[Director shared].stage.creator lowercaseString] isEqualToString: [[Director shared].username lowercaseString]])
			{
				CCMenuItemImage *flagButton = [CCMenuItemImage itemFromNormalImage:@"Media/Buttons/general/button_dialog_edit.png" selectedImage:@"Media/Buttons/general/button_dialog_edit.png" target:self selector:@selector(editButtonPressed:)];
				flagButton.scale = (backgroundWidth * 0.2) / flagButton.contentSize.width;
				[flagButton setPosition: ccp(background.position.x, background.position.y - backgroundHeight * 0.125)];
				[buttons addObject: flagButton];
			}
			else
			{
				CCMenuItemImage *flagButton = [CCMenuItemImage itemFromNormalImage:@"Media/Buttons/general/button_dialog_flag.png" selectedImage:@"Media/Buttons/general/button_dialog_flag.png" target: callbackObj selector:@selector(flagButtonPressed)];
				flagButton.scale = (backgroundWidth * 0.2) / flagButton.contentSize.width;
				[flagButton setPosition: ccp(background.position.x - backgroundWidth * 0.35, background.position.y - backgroundHeight * 0.175)];
				[buttons addObject: flagButton];
			}
		}
		
		//Star rating and level time.
		//Background
		CCSprite *ratingBackgroundSprite = [CCSprite spriteWithFile: @"Media/Buttons/general/level_complete/button_dialog_win_rating_background.png"];
		[ratingBackgroundSprite setScale: (backgroundWidth * 0.50) / ratingBackgroundSprite.contentSize.width];
		[ratingBackgroundSprite setPosition:ccp(background.position.x, background.position.y - (backgroundHeight / 2) * 0.45)];
		[self addChild: ratingBackgroundSprite];
		
        CCMenu *menu = [CCMenu menuWithArray: buttons];
        menu.position = ccp(0, -backgroundHeight / 6 + DIALOG_FONT_OFFSET);
        [self addChild:menu];
    }
    
    return self;
}

//Winner, winner, chicken dinner.
- (id) initWinnerWithHeader: (NSString *) headerIn target: (id) callbackObjNew selector: (SEL) selectorNew andTimeElapsed: (float) timeElapsed andScore:(int)score
{
	self.dialogType = 2;
	
    if((self = [self init]))
    {
        header = headerIn;
        callbackObj = callbackObjNew;
        selector = selectorNew;
        
        CCSprite *background = [self createBackgroundStatic];
        
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
			CCMenuItemImage *nextLevelButton = [CCMenuItemImage itemFromNormalImage:@"Media/Buttons/general/level_complete/button_dialog_list.png" selectedImage:@"Media/Buttons/general/level_complete/button_dialog_list.png" target:self selector:@selector(nextStageButtonPressed:)];
			nextLevelButton.scale = retryButton.scale;
			[nextLevelButton setPosition: ccp(background.position.x + (backgroundWidth / 2) * 0.55, background.position.y + (backgroundHeight / 2) * 0.425)];
			[buttons addObject: nextLevelButton];
			
			if (![[Director shared].stage.creator isEqualToString: [Director shared].username])
			{
				likeButton = [CCMenuItemImage itemFromNormalImage:@"Media/Buttons/general/button_thumbs_up.png" selectedImage:@"Media/Buttons/general/button_thumbs_up.png" target:self selector:@selector(likeButtonPressed:)];
				likeButton.scale = (backgroundWidth * 0.125) / likeButton.contentSize.width;
				[likeButton setPosition: ccp(background.position.x + backgroundWidth * 0.1, background.position.y - backgroundHeight * 0.125)];
				[buttons addObject: likeButton];
				
				dislikeButton = [CCMenuItemImage itemFromNormalImage:@"Media/Buttons/general/button_thumbs_down.png" selectedImage:@"Media/Buttons/general/button_thumbs_down.png" target:self selector:@selector(dislikeButtonPressed:)];
				dislikeButton.scale = (backgroundWidth * 0.125) / dislikeButton.contentSize.width;
				[dislikeButton setPosition: ccp(background.position.x - backgroundWidth * 0.1, background.position.y - backgroundHeight * 0.125)];
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
		
		//Flag and edit buttons.
		if ([Director shared].online)
		{
			if ([[Director shared].stage.creator isEqualToString: [Director shared].username])
			{
				CCMenuItemImage *flagButton = [CCMenuItemImage itemFromNormalImage:@"Media/Buttons/general/button_dialog_edit.png" selectedImage:@"Media/Buttons/general/button_dialog_edit.png" target:self selector:@selector(editButtonPressed:)];
				flagButton.scale = (backgroundWidth * 0.2) / flagButton.contentSize.width;
				[flagButton setPosition: ccp(background.position.x, background.position.y - backgroundHeight * 0.125)];
				[buttons addObject: flagButton];
			}
			else
			{
				CCMenuItemImage *flagButton = [CCMenuItemImage itemFromNormalImage:@"Media/Buttons/general/button_dialog_flag.png" selectedImage:@"Media/Buttons/general/button_dialog_flag.png" target: callbackObj selector:@selector(flagButtonPressed)];
				flagButton.scale = (backgroundWidth * 0.2) / flagButton.contentSize.width;
				[flagButton setPosition: ccp(background.position.x - backgroundWidth * 0.35, background.position.y - backgroundHeight * 0.175)];
				[buttons addObject: flagButton];
			}
		}
		
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
	
    if((self = [self initChoiceWithMessage: [NSString stringWithFormat: @"You are about to flag %@ for inappropriate content.", levelName] callback: callbackObjNew selector: selectorNew selectorCancel: @selector(showWinScreen)]))
    {
        
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
		
		CCSprite *background = [self createBackgroundStatic];
		
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
		[MToolsPurchaseManager sharedManager].callback = self;
		
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
		CCLabelTTF *fullGameDescLabel = [DialogLayer createShadowHeaderWithString: @"- All levels become playable!\n- Access to Online Levels!\n- Save and upload your own\n  custom made Online Levels!\n- Support indie developers!"
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
		
		if (!PREPAID_VERSION)
			[purchaseFullGameSelectedSprite setScale: 0.95];
		
		CCMenuItemSprite *purchaseFullGameMenuItem = [CCMenuItemSprite itemWithNormalSprite: purchaseFullGameSprite selectedSprite: purchaseFullGameSelectedSprite block:^(id sender) {
			if (!PREPAID_VERSION)
				[[MToolsPurchaseManager sharedManager] purchaseProductByName: @"fullversion"];
		}];
		[purchaseFullGameMenuItem setScale: (backgroundWidth * 0.33) / purchaseFullGameMenuItem.contentSize.width];
		[purchaseFullGameMenuItem setPosition: ccp(background.position.x + backgroundWidth * 0.25, background.position.y + backgroundHeight * 0.2)];
		
		CCMenu *purchaseMenu = [CCMenu menuWithItems: purchaseFullGameMenuItem, restorePurchasesMenuItem, nil];
		[purchaseMenu setAnchorPoint: ccp(0, 0)];
		[purchaseMenu setPosition: CGPointZero];
		[self addChild: purchaseMenu];
		
		//Icon to overlay on the purchase button if we've already got the full version.
		if ([[MToolsPurchaseManager sharedManager] productPurchased: @"fullversion"] || PREPAID_VERSION)
		{
			CCSprite *purchasedIcon = [CCSprite spriteWithFile: @"Media/Buttons/general/purchase/button_bought_icon.png"];
			[purchasedIcon setScale: (purchaseFullGameMenuItem.contentSize.width * purchaseFullGameMenuItem.scaleX) / purchasedIcon.contentSize.width];
			[purchasedIcon setPosition: purchaseFullGameMenuItem.position];
			[purchaseFullGameMenuItem setOpacity: 150];
			[self addChild: purchasedIcon];
			
			[purchaseFullGameMenuItem setColor: ccc3(150, 150, 150)];
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
		NSArray *botsForPurchase = [NSArray arrayWithObjects: @"1", @"2", @"3", @"4", @"5", nil];
		CCSprite *selectionIcons = [[CCSprite alloc] init];
		[selectionIcons setAnchorPoint: ccp(0, 0)];
		[selectionIcons setPosition: CGPointZero];
		for (int i = 0; i < [botsForPurchase count]; i++)
		{
			CCSprite *botSprite = [CCSprite spriteWithFile: [NSString stringWithFormat: @"Media/Buttons/general/purchase/button_purchase_bot_%@.png", [botsForPurchase objectAtIndex: i]]];
			CCSprite *botSelectedSprite = [CCSprite spriteWithFile: [NSString stringWithFormat: @"Media/Buttons/general/purchase/button_purchase_bot_%@.png", [botsForPurchase objectAtIndex: i]]];
			[botSelectedSprite setScale: 0.95];
			
			if ([[MToolsPurchaseManager sharedManager] productPurchased: [NSString stringWithFormat: @"botskin%@", [botsForPurchase objectAtIndex: i]]])
			{
				CCSprite *boughtOverlaySprite = [CCSprite spriteWithFile: @"Media/Buttons/general/purchase/button_bought_overlay.png"];
				CCSprite *boughtOverlaySelectedSprite = [CCSprite spriteWithFile: @"Media/Buttons/general/purchase/button_bought_overlay.png"];
				[boughtOverlaySprite setAnchorPoint: ccp(0, 0)];
				[boughtOverlaySelectedSprite setAnchorPoint: ccp(0, 0)];
				
				[botSprite addChild: boughtOverlaySprite];
				[botSelectedSprite addChild: boughtOverlaySelectedSprite];
			}
			
			CCMenuItemSprite *botMenuItem;
			CCSprite *purchasedIcon = [CCSprite spriteWithFile: @"Media/Buttons/general/purchase/button_bought_icon.png"];
			
			botMenuItem = [CCMenuItemSprite itemWithNormalSprite: botSprite selectedSprite: botSelectedSprite block:^(id sender) {

				if (![[MToolsPurchaseManager sharedManager] productPurchased: [NSString stringWithFormat: @"botskin%@", [botsForPurchase objectAtIndex: i]]])
				{
					[[MToolsPurchaseManager sharedManager] purchaseProductByName: [NSString stringWithFormat:@"botskin%@", [botsForPurchase objectAtIndex: i]]];
				}
				else
				{
					[Director shared].botType = [botsForPurchase objectAtIndex: i];
					
					for (int j = 0; j < [botsForPurchase count]; j++)
					{
						[[selectionIcons getChildByTag: j] setVisible: NO];
					}
					[[selectionIcons getChildByTag: i] setVisible: YES];
				}
			}];

			[botMenuItem setScale: ((backgroundWidth * 0.12) / botMenuItem.contentSize.width)];
			[botMenuItem setPosition: ccp(background.position.x - backgroundWidth * ([botsForPurchase count] * .0475) + (i * (botMenuItem.contentSize.width * botMenuItem.scale)), background.position.y - backgroundHeight * 0.25)];
			
			[purchasedIcon setScale: (botMenuItem.contentSize.width * botMenuItem.scaleX) / purchasedIcon.contentSize.width];
			[purchasedIcon setPosition: botMenuItem.position];
			[purchasedIcon setOpacity: 150];
			[purchasedIcon setTag: i];
			[purchasedIcon setVisible: NO];
			[selectionIcons addChild: purchasedIcon z: 9001];
			
			if ([[Director shared].botType intValue] == [[botsForPurchase objectAtIndex: i] intValue])
			{
				[[selectionIcons getChildByTag: i] setVisible: YES];
			}
			
			[botMenuItems addObject: botMenuItem];
		}
		
		CCMenu *botMenu = [CCMenu menuWithArray: botMenuItems];
		[botMenu setAnchorPoint: ccp(0, 0)];
		[botMenu setPosition: ccp(0, 0)];
		[self addChild: botMenu];
		
		[self addChild: selectionIcons];
	}
	
	return self;
}

- (id) initCreditsWithCallbackObj: (id) callbackObjNew selector: (SEL) selectorNew
{
	if (self = [self init])
	{
		CCSprite *background = [self createBackground];
		
		//"Other GearSprout Apps"
		CCLabelTTF *titleLabel = [DialogLayer createShadowHeaderWithString: @"Other GearSprout Apps"
																	position: ccp(background.position.x, background.position.y + backgroundHeight * 0.375)
																shadowOffset: CGSizeMake(1, -1)
																	   color: ccWHITE
																 shadowColor: ccBLACK
																  dimensions: CGSizeMake(backgroundWidth * 0.8, backgroundHeight * 0.7)
																  hAlignment: kCCTextAlignmentCenter
																  vAlignment: kCCVerticalTextAlignmentCenter
															   lineBreakMode: kCCLineBreakModeWordWrap
																	fontSize: DIALOG_FONT_SIZE * [Director shared].scaleFactor.width
									];
		[self addChild: titleLabel];
		
		//Pictures and links to other GearSprout apps.
		NSMutableArray *menuItems = [NSMutableArray array];
		CCSprite *appIcon;
		CCSprite *appIconSelected;
		CCMenuItemSprite *appMenuItem;
		
		NSArray *apps = [NSArray arrayWithObjects: @"mouth-mover", @"rodent's-revenge", @"skifree", @"symmetry-hd", @"tunepad", nil];
		NSArray *appURLs = [NSArray arrayWithObjects:
							@"https://itunes.apple.com/us/app/mouth-mover/id564033673?ls=1&mt=8",
							@"https://itunes.apple.com/us/app/rodents-revenge/id587603072?ls=1&mt=8",
							@"https://itunes.apple.com/us/app/skifree/id588839086?ls=1&mt=8",
							@"https://itunes.apple.com/us/app/symmetry-hd/id590932479?ls=1&mt=12",
							@"https://itunes.apple.com/us/app/tunepad/id556683901?ls=1&mt=8",
							nil];
		
		for (int i = 0; i < [apps count]; i++)
		{
			appIcon = [CCSprite spriteWithFile: [NSString stringWithFormat: @"Media/Buttons/general/credits/%@.png", [apps objectAtIndex: i]]];
			appIconSelected = [CCSprite spriteWithFile: [NSString stringWithFormat: @"Media/Buttons/general/credits/%@.png", [apps objectAtIndex: i]]];
			[appIconSelected setScale: 0.95];
			
			appMenuItem = [CCMenuItemSprite itemWithNormalSprite: appIcon selectedSprite: appIconSelected block:^(id sender)
			{
				NSString *pageURL =[appURLs objectAtIndex: i];
				NSString *escaped = [pageURL stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
				[[UIApplication sharedApplication] openURL: [NSURL URLWithString: escaped]];
			}];
			[appMenuItem setScale: (backgroundWidth * 0.115) / appIcon.contentSize.width];
			[appMenuItem setPosition: ccp(background.position.x - backgroundWidth * 0.225 + (i * (appMenuItem.contentSize.width * appMenuItem.scale)), background.position.y + backgroundHeight * 0.225)];
			
			[menuItems addObject: appMenuItem];
		}		
		
		CCMenu *menu = [CCMenu menuWithArray: menuItems];
		[menu setAnchorPoint: ccp(0, 0)];
		[menu setPosition: CGPointZero];
		[self addChild: menu];
		
		//Credits label
		CCLabelTTF *creditsLabel = [DialogLayer createShadowHeaderWithString: @"Credits"
																	position: ccp(background.position.x, background.position.y - backgroundHeight * 0.2)
																shadowOffset: CGSizeMake(1, -1)
																	   color: ccWHITE
																 shadowColor: ccBLACK
																  dimensions: CGSizeMake(backgroundWidth * 0.8, backgroundHeight * 0.7)
																  hAlignment: kCCTextAlignmentLeft
																  vAlignment: kCCVerticalTextAlignmentTop
															   lineBreakMode: kCCLineBreakModeWordWrap
																	fontSize: DIALOG_FONT_SIZE * [Director shared].scaleFactor.width
									];
		[self addChild: creditsLabel];
		
		//Credits body label
		UIScrollView *creditsScrollView = [[UIScrollView alloc] initWithFrame: CGRectMake(0, 0, backgroundWidth * 0.8, backgroundHeight * 0.45)];
		[creditsScrollView setIndicatorStyle: UIScrollViewIndicatorStyleWhite];
		 
		UITextView *creditsTextView = [[UITextView alloc] initWithFrame: CGRectMake(0, 0, backgroundWidth * 0.8, backgroundHeight * 0.45)];
		[creditsTextView setText: @"Developed By: GearSprout, LLC\nTommy Tornroos & Marshall Miller\n\nHead Developer: Marshall Miller\n\nGraphics and Testing: Tommy Tornroos\n\n\n\n\nMusic: \"Toy of Fury\" by Thiaz Itch\n(http://thiazitch.prootrecords.com)\n\n\"Air Hockey Saloon\" by Chris Zabriskie\n(http://chriszabriskie.com)\n\n\"Robot Anthem Part II\" by Learning Music\n(http://www.learningmusicmonthly.com/)\n\n\"FB-01 2\" by Christian Bjoerklund\n(http://freemusicarchive.org/music/Christian_Bjoerklund/Skapmat/)\n\nSound Effects: Tommy Tornroos & Marshall Miller"];
		[creditsTextView setBackgroundColor: [UIColor clearColor]];
		[creditsTextView setTextColor: [UIColor whiteColor]];
		[creditsTextView setFont: [UIFont fontWithName: [Director shared].globalFont size: 12]];
		[UIScrollView beginAnimations:@"scrollAnimation" context:nil];
		[UIScrollView setAnimationDuration: 24.0f];
		[creditsTextView setContentOffset:CGPointMake(0, backgroundHeight * 2)];
		[UIScrollView commitAnimations];
		[creditsScrollView addSubview: creditsTextView];
		 
		CCUIViewWrapper *creditsWrapper = [CCUIViewWrapper wrapperForUIView: creditsScrollView];
		[creditsWrapper setContentSize: CGSizeMake(backgroundWidth * 0.8, backgroundHeight)];
		[creditsWrapper setPosition: ccp(background.position.x, background.position.y - backgroundHeight * 0.45)];
		[creditsWrapper setAnchorPoint: ccp(0.5, 0.5)];
		[self addChild: creditsWrapper];
		
		CCLabelTTF *creditsBodyLabel = [DialogLayer createShadowHeaderWithString: @"Developed By: GearSprout, LLC\nTommy Tornroos & Marshall Miller\n\nHead Developer: Marshall Miller\n\nGraphics and Testing: Tommy Tornroos\n\n\n\n\nMusic: \"Toy of Fury\" by Thiaz Itch\n(http://thiazitch.prootrecords.com)\n\n\"Air Hockey Saloon\" by Chris Zabriskie\n(http://chriszabriskie.com)\n\n\"Robot Anthem Part II\" by Learning Music\n(http://www.learningmusicmonthly.com/)\n\n\"FB-01 2\" by Christian Bjoerklund\n(http://freemusicarchive.org/music/Christian_Bjoerklund/Skapmat/)\n\nSound Effects: Tommy Tornroos & Marshall Miller"
																  position: ccp(background.position.x, background.position.y + backgroundHeight * 0.05)
															  shadowOffset: CGSizeMake(1, -1)
																	 color: ccWHITE
															   shadowColor: ccBLACK
																dimensions: CGSizeMake(backgroundWidth * 0.8, backgroundHeight)
																hAlignment: kCCTextAlignmentLeft
																vAlignment: kCCVerticalTextAlignmentTop
															 lineBreakMode: kCCLineBreakModeWordWrap
																  fontSize: DIALOG_FONT_SIZE * 0.8 * [Director shared].scaleFactor.width
								  ];
		[creditsBodyLabel setAnchorPoint: ccp(0.5, 1)];
		//[self addChild: creditsBodyLabel];
	}
	
	return self;
}

- (id) initCreateAccountWithCallbackObj: (id) callbackObjNew selector: (SEL) selectorNew
{
	self.dialogType = 5;
	
    if((self = [self init]))
    {
        callbackObj = callbackObjNew;
        selector = selectorNew;
        
        CCSprite *background = [self createBackgroundStatic];
		background.position = ccp(background.position.x, background.position.y + 70);
		
		CGSize s = [CCDirector sharedDirector].winSize;
		NSMutableArray *buttons = [NSMutableArray array];
		float okButtonPosX = background.position.x;
		okButtonPosX += backgroundWidth / 4;
		
		CCSprite *loginTitleSprite = [CCSprite spriteWithFile: @"Media/Buttons/general/create_account/button_create_account_title.png"];
		[loginTitleSprite setScale: (backgroundWidth * 0.70) / loginTitleSprite.contentSize.width];
		[loginTitleSprite setPosition:ccp(background.position.x, background.position.y + (backgroundHeight / 2) * 0.625)];
		[self addChild: loginTitleSprite];
		
		//Username input background
		CCSprite *usernameInputBackground = [CCSprite spriteWithFile: @"Media/Buttons/general/level_save/button_level_name_background.png"];
		[usernameInputBackground setScale: (backgroundWidth * 0.6) / usernameInputBackground.contentSize.width];
		[usernameInputBackground setPosition: ccp(background.position.x, background.position.y + backgroundHeight * 0.1)];
		[self addChild: usernameInputBackground];
		
		//Username input text box
		self.textField = [[CustomTextField alloc] initWithFrame: CGRectMake(0, 0, (usernameInputBackground.contentSize.width * usernameInputBackground.scale * 0.9), (usernameInputBackground.contentSize.height * usernameInputBackground.scale) * 0.75)];
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
		
		self.textFieldWrapper = [CCUIViewWrapper wrapperForUIView: self.textField];
		[self.textFieldWrapper setContentSize: CGSizeMake((usernameInputBackground.contentSize.width * usernameInputBackground.scale * 0.85), (usernameInputBackground.contentSize.height * usernameInputBackground.scale) * 0.75)];
		[self.textFieldWrapper setPosition: ccp(usernameInputBackground.position.x, usernameInputBackground.position.y + self.textFieldWrapper.contentSize.height * 0.25)];
		[self.textFieldWrapper setAnchorPoint: ccp(0.5, 0.5)];
		[self addChild: self.textFieldWrapper];
		
		//Password input background
		CCSprite *passwordInputBackground = [CCSprite spriteWithFile: @"Media/Buttons/general/level_save/button_level_creator_background.png"];
		[passwordInputBackground setScale: (backgroundWidth * 0.6) / passwordInputBackground.contentSize.width];
		[passwordInputBackground setPosition: ccp(background.position.x, background.position.y - backgroundHeight * 0.05)];
		[self addChild: passwordInputBackground];
		
		//Password input text box
		self.textField2 = [[CustomTextField alloc] initWithFrame: CGRectMake(0, 0, (passwordInputBackground.contentSize.width * passwordInputBackground.scale * 0.9), (passwordInputBackground.contentSize.height * passwordInputBackground.scale) * 0.75)];
		self.textField2.borderStyle = UITextBorderStyleNone;
		[self.textField2 setBackgroundColor: [UIColor clearColor]];
		[self.textField2 setFont: [UIFont fontWithName: [Director shared].globalFont size: DIALOG_FONT_SIZE_TITLE * [Director shared].scaleFactor.width]];
		[self.textField2 setPlaceholder: @"Password"
		 ];
		self.textField2.delegate = self;
		self.textField2.keyboardType = UIKeyboardAppearanceDefault;
		self.textField2.returnKeyType = UIReturnKeyNext;
		self.textField2.autocorrectionType = UITextAutocapitalizationTypeNone;
		self.textField2.autocapitalizationType = UITextAutocapitalizationTypeNone;
		self.textField2.secureTextEntry = YES;
		self.textField2.tag = 1;
		
		self.textFieldWrapper2 = [CCUIViewWrapper wrapperForUIView: self.textField2];
		[self.textFieldWrapper2 setContentSize: CGSizeMake((passwordInputBackground.contentSize.width * passwordInputBackground.scale * 0.85), (passwordInputBackground.contentSize.height * passwordInputBackground.scale) * 0.75)];
		[self.textFieldWrapper2 setPosition: ccp(passwordInputBackground.position.x, passwordInputBackground.position.y + self.textFieldWrapper2.contentSize.height * 0.25)];
		[self.textFieldWrapper2 setAnchorPoint: ccp(0.5, 0.5)];
		[self addChild: self.textFieldWrapper2];
		
		//Email input background
		CCSprite *emailInputBackground = [CCSprite spriteWithFile: @"Media/Buttons/general/level_save/button_level_name_background.png"];
		[emailInputBackground setScale: (backgroundWidth * 0.6) / emailInputBackground.contentSize.width];
		[emailInputBackground setPosition: ccp(background.position.x, background.position.y - backgroundHeight * 0.20)];
		[self addChild: emailInputBackground];
		
		//Email input text box
		self.textField3 = [[CustomTextField alloc] initWithFrame: CGRectMake(0, 0, (emailInputBackground.contentSize.width * emailInputBackground.scale * 0.9), (emailInputBackground.contentSize.height * emailInputBackground.scale) * 0.75)];
		self.textField3.borderStyle = UITextBorderStyleNone;
		[self.textField3 setBackgroundColor: [UIColor clearColor]];
		[self.textField3 setFont: [UIFont fontWithName: [Director shared].globalFont size: DIALOG_FONT_SIZE_TITLE * [Director shared].scaleFactor.width]];
		[self.textField3 setPlaceholder: @"Optional Email Address"
		 ];
		self.textField3.delegate = self;
		self.textField3.keyboardType = UIKeyboardAppearanceDefault;
		self.textField3.returnKeyType = UIReturnKeyDone;
		self.textField3.autocorrectionType = UITextAutocapitalizationTypeNone;
		self.textField3.autocapitalizationType = UITextAutocapitalizationTypeNone;
		self.textField3.secureTextEntry = YES;
		self.textField3.tag = 2;
		
		self.textFieldWrapper3 = [CCUIViewWrapper wrapperForUIView: self.textField3];
		[self.textFieldWrapper3 setContentSize: CGSizeMake((emailInputBackground.contentSize.width * emailInputBackground.scale * 0.85), (emailInputBackground.contentSize.height * emailInputBackground.scale) * 0.75)];
		[self.textFieldWrapper3 setPosition: ccp(emailInputBackground.position.x, emailInputBackground.position.y + self.textFieldWrapper3.contentSize.height * 0.25)];
		[self.textFieldWrapper3 setAnchorPoint: ccp(0.5, 0.5)];
		[self addChild: self.textFieldWrapper3];
		
		//Cancel
		CCMenuItemImage *cancelButton = [CCMenuItemImage itemWithNormalImage:@"Media/Buttons/general/button_dialog_cancel.png" selectedImage:@"Media/Buttons/general/button_dialog_cancel.png" target:self selector:@selector(cancelButtonPressed:)];
		cancelButton.scale = (backgroundWidth * 0.225) / cancelButton.contentSize.width;
		[cancelButton setPosition: ccp(background.position.x - backgroundWidth * 0.25, background.position.y - backgroundHeight * 0.35)];
		
		//Next
		CCMenuItemImage *nextButton = [CCMenuItemImage itemWithNormalImage:@"Media/Buttons/general/button_dialog_next.png" selectedImage:@"Media/Buttons/general/button_dialog_next.png" target:self selector:@selector(sendNewAccountInfoButtonPressed)];
		nextButton.scale = (backgroundWidth * 0.225) / nextButton.contentSize.width;
		[nextButton setPosition: ccp(background.position.x + backgroundWidth * 0.25, background.position.y - backgroundHeight * 0.35)];
		
		CCMenu *cancelAndNextMenu = [CCMenu menuWithItems: cancelButton, nextButton, nil];
		[cancelAndNextMenu setAnchorPoint: ccp(0, 0)];
		[cancelAndNextMenu setPosition: CGPointZero];
		[self addChild: cancelAndNextMenu];
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
        
        CCSprite *background = [self createBackgroundStatic];
		background.position = ccp(background.position.x, background.position.y + 30);
     
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
		self.textField.center = ccp(background.position.x, (background.position.y - backgroundHeight * 0.125) - 60);
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
		self.textField2.center = ccp(background.position.x, background.position.y + backgroundHeight * 0.025 - 60);
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
		[[[CCDirector sharedDirector] view] addSubview: self.textField2];
		
		//Cancel
		CCMenuItemImage *cancelButton = [CCMenuItemImage itemWithNormalImage:@"Media/Buttons/general/button_dialog_cancel.png" selectedImage:@"Media/Buttons/general/button_dialog_cancel.png" target:self selector:@selector(cancelButtonPressed:)];
		cancelButton.scale = (backgroundWidth * 0.225) / cancelButton.contentSize.width;
		[cancelButton setPosition: ccp(background.position.x - backgroundWidth * 0.325, background.position.y - backgroundHeight * 0.35)];
		
		//Create account
		CCMenuItemImage *createAccountButton = [CCMenuItemImage itemWithNormalImage: @"Media/Buttons/general/login/button_create_account.png" selectedImage: @"Media/Buttons/general/login/button_create_account.png" block:^(id sender) {
			[self createAccountButtonPressed];
			
		}];
		[createAccountButton setScale: (backgroundWidth * 0.35) / createAccountButton.contentSize.width];
		[createAccountButton setPosition: ccp(background.position.x, background.position.y - backgroundHeight * 0.35)];
		
		//Next
		CCMenuItemImage *nextButton = [CCMenuItemImage itemWithNormalImage:@"Media/Buttons/general/button_dialog_next.png" selectedImage:@"Media/Buttons/general/button_dialog_next.png" target:self selector:@selector(loginButtonPressed:)];
		nextButton.scale = (backgroundWidth * 0.225) / nextButton.contentSize.width;
		[nextButton setPosition: ccp(background.position.x + backgroundWidth * 0.325, background.position.y - backgroundHeight * 0.35)];
		
		CCMenu *cancelAndNextMenu = [CCMenu menuWithItems: cancelButton, createAccountButton, nextButton, nil];
		[cancelAndNextMenu setAnchorPoint: ccp(0, 0)];
		[cancelAndNextMenu setPosition: CGPointZero];
		[self addChild: cancelAndNextMenu];
    }
    
    return self;
}

- (id) initNewUserWithCallbackObj: (id) callbackObjNew selector: (SEL) selectorNew
{
	self.dialogType = 5;
	
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

- (id) initAllLevelsCompletedWithStars: (bool) allStars
{
	if (self = [self init])
	{
		CCSprite *background = [self createBackground];
		
		if (!allStars)
		{
			CCSprite *winAllLevels = [CCSprite spriteWithFile: @"Media/Backgrounds/general/win_no_stars.png"];
			[winAllLevels setScaleX: (background.contentSize.width * background.scaleX) / winAllLevels.contentSize.width];
			[winAllLevels setScaleY: (background.contentSize.height * background.scaleY) / winAllLevels.contentSize.height];
			[winAllLevels setPosition: background.position];
			[self addChild: winAllLevels];
			
			[MToolsAppSettings setValue: [NSNumber numberWithBool: YES] withName: @"completedAllLevels"];
		}
		else
		{
			CCSprite *winAllLevels = [CCSprite spriteWithFile: @"Media/Backgrounds/general/win_all_stars.png"];
			[winAllLevels setScaleX: (background.contentSize.width * background.scaleX) / winAllLevels.contentSize.width];
			[winAllLevels setScaleY: (background.contentSize.height * background.scaleY) / winAllLevels.contentSize.height];
			[winAllLevels setPosition: background.position];
			[self addChild: winAllLevels];
			
			[MToolsAppSettings setValue: [NSNumber numberWithBool: YES] withName: @"completedAllLevelsWithStars"];
		}
	}
	
	return self;
}

#pragma mark UITextField Delegate Methods

- (BOOL)textField:(UITextField *)field shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)characters
{
	if (field.tag == 0)
	{
		NSCharacterSet *blockedCharacters = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
	
		return ([characters rangeOfCharacterFromSet:blockedCharacters].location == NSNotFound);
	}
	
	return YES;
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

- (CCSprite *) createBackgroundStatic
{
	CGSize s = [CCDirector sharedDirector].winSize;
	
	//This is the invisible closing background which will remove the notification window if hit.
	CCMenuItemImage *closeMenuItem = [CCMenuItemImage itemWithNormalImage: @"Media/Backgrounds/blank.jpg" selectedImage: @"Media/Backgrounds/blank.jpg" target: self selector: @selector(resign)];
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

- (BOOL) textFieldShouldEndEditing:(UITextField *)textField
{
	return YES;
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
	CGSize s = [CCDirector sharedDirector].winSize;
	
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
	
	else if (self.dialogType == 5)
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
			[self sendNewAccountInfoButtonPressed];
		}
	}
	
    return NO;
}

- (void) retrievedProduct
{
	id parent = self.parent;
	[self remove];
	
	DialogLayer *refreshPurchaseDialog = [[DialogLayer alloc] initPurchaseWithCallbackObj: callbackObj selector: selector];
	[parent addChild: refreshPurchaseDialog z: 9000];
}

- (void) remove
{
	[self resign];
	
	[self.textField removeFromSuperview];
	[self.textField2 removeFromSuperview];
	[self.textField3 removeFromSuperview];
    [self removeFromParentAndCleanup: YES];
	[[CCTextureCache sharedTextureCache] removeUnusedTextures];
}

- (void) resign
{
	[self.textField resignFirstResponder];
	[self.textField2 resignFirstResponder];
	[self.textField3 resignFirstResponder];
}

#pragma mark BUTTON PRESSES

#pragma mark L purchases

- (void) restorePurchases
{
	[DialogLayer playButtonSound];
	
	[[MToolsPurchaseManager sharedManager] restorePurchases];
}

#pragma mark L ratings

- (void) sendNewAccountInfoButtonPressed
{
	if ([[Director shared] createUsername: self.textField.text andPassword: self.textField2.text andEmail: self.textField3.text])
	{
		id parent = self.parent;
		[self remove];
		
		NSArray *retArray = [NSArray arrayWithObjects: self.textField.text, [Director sha: self.textField2.text], nil];
		[callbackObj performSelector: selector withObject: retArray];
		
		return;
	}
	else
	{
		id parent = self.parent;
		[self remove];
		
		DialogLayer *successDialog = [[DialogLayer alloc] initNotificationWithMessage: @"That username already exists." callback: callbackObj selector: selector];
		[parent addChild: successDialog z: 9000];
	}
}

- (void) createAccountButtonPressed
{
	id parent = self.parent;
	[self remove];
	
	DialogLayer *createAccountDialog = [[DialogLayer alloc] initCreateAccountWithCallbackObj: callbackObj selector: selector];
	[parent addChild: createAccountDialog z: 9000];
}

- (void) likeButtonPressed: (id) sender
{
	[DialogLayer playButtonSound];
	
	[[Director shared] rateLevel: [Director shared].stage.name withRating: 1];
	
	[dislikeButton setColor: ccc3(0, 0, 0)];
	[dislikeButton setOpacity: 150];
	
	[likeButton setColor: ccc3(255, 255, 255)];
	[likeButton setOpacity: 255];
}

- (void) dislikeButtonPressed: (id) sender
{
	[DialogLayer playButtonSound];
	
	[[Director shared] rateLevel: [Director shared].stage.name withRating: 0];
	
	[dislikeButton setColor: ccc3(255, 255, 255)];
	[dislikeButton setOpacity: 255];
	
	[likeButton setColor: ccc3(0, 0, 0)];
	[likeButton setOpacity: 150];
}

- (void) submittedRating: (id) sender
{
	[ratingThanksLabel setVisible: YES];
}

- (void) flagButtonPressed: (id) sender
{
	[DialogLayer playButtonSound];

	DialogLayer *flagConfirmDialog = [[DialogLayer alloc] initFlaggerWithHeader: @"CONFIRM FLAG" target: self selector: @selector(flagConfirmButtonPressed:) andLevelName: [Director shared].stage.name];
	[[CCDirector sharedDirector].runningScene addChild: flagConfirmDialog z: 9100];
}

- (void) flagConfirmButtonPressed: (id) sender
{
	[DialogLayer playButtonSound];
	
	[[Director shared] flagLevel: [Director shared].stage.name];
	DialogLayer *thankYouDialog = [[DialogLayer alloc] initNotificationWithMessage:  @"Thank you for your report. We will investigate the level you have flagged and take the appropriate action." callback: self selector: @selector(nextStageButtonPressed:)];
	[[CCDirector sharedDirector].runningScene addChild: thankYouDialog z: 9100];
}

- (void) retryButtonPressed: (id) sender
{
	[DialogLayer playButtonSound];
	
	[callbackObj performSelector: selector withObject: [NSNumber numberWithBool: YES]];
	[self remove];
}

- (void) nextStageButtonPressed: (id) sender
{
	[DialogLayer playButtonSound];
	
	[callbackObj performSelector: selector withObject: [NSNumber numberWithBool: NO]];
	[self remove];
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
    
	if (self.parent)
		[self remove];
}

- (void) loginButtonPressed:(id) sender
{
    [DialogLayer playButtonSound];
    
	NSArray *retArray = [NSArray arrayWithObjects: self.textField.text, [Director sha: self.textField2.text], nil];
	
    [callbackObj performSelector: selector withObject: retArray];
    
    [self remove];
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