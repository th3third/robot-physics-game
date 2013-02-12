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

#define DIALOG_FONT @"Segoe Print"
#define DIALOG_FONT_SIZE 18
#define DIALOG_FONT_SHADOW_OFFSET 0.5
#define DIALOG_FONT_OFFSET 5

@implementation DialogLayer

@synthesize callbackObj;
@synthesize selector;

- (id) initWithHeader:(NSString *)header andLine1:(NSString *)line1 target:(id)callbackObjNew selector:(SEL)selectorNew textField: (bool) doTextField
{
	return [self initWithHeader: header andLine1: line1 target: callbackObjNew selector: selectorNew textField: doTextField andExistingText: @"" andCancelButton: NO];
}

- (id) initWithHeader:(NSString *)headerIn andLine1:(NSString *)line1 target:(id)callbackObjNew selector:(SEL)selectorNew textField: (bool) doTextField andExistingText: (NSString *) existingText andCancelButton: (bool) addCancelButton
{
	self.dialogType = 0;
	
    if((self = [super init]))
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

- (id) initLoginWithHeader:(NSString *)headerIn target:(id)callbackObjNew selector:(SEL)selectorNew andExistingText: (NSString *) existingText
{
	self.dialogType = 1;
	
	if((self = [super init]))
    {
		header = headerIn;
        callbackObj = callbackObjNew;
        selector = selectorNew;
        
        CCSprite *background = [self createBackground];
        
		NSMutableArray *buttons = [NSMutableArray array];
		float okButtonPosX = background.position.x;
		CGSize s = [CCDirector sharedDirector].winSize;

		//Cancel button.
		okButtonPosX += backgroundWidth / 4;
		CCMenuItemImage *cancelButton = [CCMenuItemImage itemFromNormalImage:@"Media/Buttons/general/button_dialog_cancel.png" selectedImage:@"Media/Buttons/general/button_dialog_cancel.png" target:self selector:@selector(cancelButtonPressed:)];
		[cancelButton setPosition: ccp(background.position.x - backgroundWidth / 4, background.position.y - backgroundHeight / 5)];
		[cancelButton setScale: ((s.width * 0.175) / cancelButton.contentSize.width)];
		[buttons addObject: cancelButton];
		
		//OK button.
		CCMenuItemImage *okButton = [CCMenuItemImage itemFromNormalImage:@"Media/Buttons/general/button_dialog_ok.png" selectedImage:@"Media/Buttons/general/button_dialog_ok.png" target:self selector:@selector(loginButtonPressed:)];
        [okButton setPosition: ccp(okButtonPosX, background.position.y - backgroundHeight / 5)];
		[okButton setScale: ((s.width * 0.175) / okButton.contentSize.width)];
		[buttons addObject: okButton];
        
        CCMenu *menu = [CCMenu menuWithArray: buttons];
        menu.position = ccp(0, -backgroundHeight / 6 + DIALOG_FONT_OFFSET);
        [self addChild:menu];
		
		//Text fields.
		//Username
		self.textField = [[UITextField alloc] initWithFrame: CGRectMake(0, 0, backgroundWidth * 0.8, 24 * [Director shared].scaleFactor.height)];
		self.textField.borderStyle = UITextBorderStyleRoundedRect;
		self.textField.center = ccp([[CCDirector sharedDirector] view].center.x , [[CCDirector sharedDirector] view].center.y - backgroundHeight / 4);
		self.textField.delegate = self;
		[self.textField setPlaceholder: @"username"];
		self.textField.text = existingText;
		[self.textField becomeFirstResponder];
		[[[CCDirector sharedDirector] view] addSubview: self.textField];
		
		//Password
		self.textField2 = [[UITextField alloc] initWithFrame: CGRectMake(0, 0, backgroundWidth * 0.8, 24 * [Director shared].scaleFactor.height)];
		self.textField2.borderStyle = UITextBorderStyleRoundedRect;
		self.textField2.center = ccp([[CCDirector sharedDirector] view].center.x , self.textField.center.y + 29);
		self.textField2.delegate = self;
		self.textField2.secureTextEntry = YES;
		[self.textField2 setPlaceholder: @"password"];
		[self.textField2 becomeFirstResponder];
		[[[CCDirector sharedDirector] view] addSubview: self.textField2];
    }
    
    return self;
}

- (id) initStageMenuWithHeader: (NSString *) headerIn target: (id) callbackObjNew selector: (SEL) selectorNew
{
	self.dialogType = 2;
	
    if((self = [super init]))
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
	
    if((self = [super init]))
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
			CCMenuItemImage *okButton = [CCMenuItemImage itemFromNormalImage:@"Media/Buttons/general/button_dialog_levels.png" selectedImage:@"Media/Buttons/general/button_dialog_levels.png" target:self selector:@selector(nextStageButtonPressed:)];
			okButton.scale = (backgroundWidth * 0.2) / okButton.contentSize.width;
			[okButton setPosition: ccp(okButtonPosX, background.position.y - backgroundHeight / 5)];
			[buttons addObject: okButton];
			
			if (![[Director shared].stage.name isEqualToString: [Director shared].username])
			{
				CCMenuItemImage *likeButton = [CCMenuItemImage itemFromNormalImage:@"Media/Buttons/general/button_dialog_like.png" selectedImage:@"Media/Buttons/general/button_dialog_levels.png" target:self selector:@selector(likeButtonPressed:)];
				likeButton.scale = (backgroundWidth * 0.2) / likeButton.contentSize.width;
				[likeButton setPosition: ccp(okButtonPosX + backgroundWidth / 8, background.position.y)];
				[buttons addObject: likeButton];
				
				CCMenuItemImage *dislikeButton = [CCMenuItemImage itemFromNormalImage:@"Media/Buttons/general/button_dialog_like.png" selectedImage:@"Media/Buttons/general/button_dialog_levels.png" target:self selector:@selector(dislikeButtonPressed:)];
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
			NSLog(@"Compare: %@ with %@", [Director shared].stage.creator, [Director shared].username);
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
		
		//Star rating and level time.
		//Background
		CCSprite *ratingBackgroundSprite = [CCSprite spriteWithFile: @"Media/Buttons/general/level_complete/button_dialog_win_rating_background.png"];
		[ratingBackgroundSprite setScale: (backgroundWidth * 0.50) / ratingBackgroundSprite.contentSize.width];
		[ratingBackgroundSprite setPosition:ccp(background.position.x, background.position.y - (backgroundHeight / 2) * 0.45)];
		[self addChild: ratingBackgroundSprite];

        //Level time.
		NSString *message = [NSString stringWithFormat: @"Level Time: %.2f", timeElapsed];
		CCNode *levelTime = [DialogLayer createTextWithShadow: message textSize: ((ratingBackgroundSprite.contentSize.width * 1.5) / [message length])];
		[levelTime setPosition: ccp(((ratingBackgroundSprite.contentSize.width) * 0.5), ((ratingBackgroundSprite.contentSize.height * 0.75)))];
		[ratingBackgroundSprite addChild: levelTime z: 67];
		
		//Stars
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
				[star setScale: (star.contentSize.height / (ratingBackgroundSprite.contentSize.height * 1.5 * ratingBackgroundSprite.scaleY))];
				[ratingBackgroundSprite addChild: star z: 66];
			}
		}
		
        CCMenu *menu = [CCMenu menuWithArray: buttons];
        menu.position = ccp(0, -backgroundHeight / 6 + DIALOG_FONT_OFFSET);
        [self addChild:menu];
    }
    
    return self;
}

- (id) initFlaggerWithHeader: (NSString *) headerIn target: (id) callbackObjNew selector: (SEL) selectorNew andLevelName: (NSString *) levelName
{
	self.dialogType = 2;
	
    if((self = [super init]))
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

- (CCSprite *) createBackground
{
	CGSize screenSize = [CCDirector sharedDirector].winSize;
	
	CCSprite *background = [CCSprite node];
	background = [background initWithFile:@"Media/Backgrounds/background_dialog.png"];
	float scale = (screenSize.width * .75) / background.contentSize.width;
	[background setScale: scale];
	[background setPosition:ccp(screenSize.width / 2, screenSize.height / 2)];
	[self addChild:background z:-1];
	
	backgroundWidth = background.contentSize.width * background.scale;
	backgroundHeight = background.contentSize.height * background.scale;
	
	CCSprite *text = [DialogLayer createTextWithShadow: header textSize: DIALOG_FONT_SIZE * 1.25];
	[text setPosition:ccp(background.position.x, background.position.y + backgroundHeight / 2 - (DIALOG_FONT_SIZE * 1.5) * [Director shared].scaleFactor.width)];
	[self addChild: text];
	
	/*CCLabelTTF *headerShadow = [CCLabelTTF labelWithString: header fontName: DIALOG_FONT fontSize: DIALOG_FONT_SIZE * [Director shared].scaleFactor.width];
	headerShadow.color = ccBLACK;
	headerShadow.opacity = 190;
	[headerShadow setPosition:ccp(background.position.x - DIALOG_FONT_SHADOW_OFFSET, background.position.y + backgroundHeight / 2 - (DIALOG_FONT_SIZE * 1.5 - DIALOG_FONT_SHADOW_OFFSET) * [Director shared].scaleFactor.width)];
	[self addChild:headerShadow];
	
	CCLabelTTF *headerLabel = [CCLabelTTF labelWithString: header fontName: DIALOG_FONT fontSize: DIALOG_FONT_SIZE * [Director shared].scaleFactor.width];
	headerLabel.color = ccBLACK;
	[headerLabel setPosition:ccp(background.position.x, background.position.y + backgroundHeight / 2 - (DIALOG_FONT_SIZE * 1.5) * [Director shared].scaleFactor.width)];
	[self addChild:headerLabel];*/
	
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
    float offsetX = offset.width;
    float offsetY = offset.height;
	
    //Shadow
    CCLabelTTF *shadow = [CCLabelTTF labelWithString:string dimensions:dimensions hAlignment: uiTextAlignment lineBreakMode: lineBreakMode fontName:@"Noteworthy-Bold" fontSize:fontSize];
    shadow.position = ccp(pos.x + offsetX, pos.y + offsetY);
    shadow.color = shadowCol;
    shadow.opacity = (255/100*83);//83%
	
    //Actual
    CCLabelTTF *label = [CCLabelTTF labelWithString:string dimensions:dimensions hAlignment: uiTextAlignment lineBreakMode: lineBreakMode fontName:@"Noteworthy-Bold" fontSize:fontSize];
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
	
    return NO;
}

- (void) likeButtonPressed: (id) sender
{
	[[Director shared] rateLevel: [Director shared].stage.name withRating: 1];
	DialogLayer *thanksDialog = [[DialogLayer alloc] initWithHeader: @"THANKS!" andLine1: @"Thank you for submitting your rating of this level!" target: self selector: @selector(submittedRating:) textField: NO];
	[self.parent addChild: thanksDialog z: 9100];
}

- (void) submittedRating: (id) sender
{
	[self removeFromParentAndCleanup: YES];
}

- (void) dislikeButtonPressed: (id) sender
{
	[[Director shared] rateLevel: [Director shared].stage.name withRating: -1];
}

- (void) flagButtonPressed: (id) sender
{
	[self playButtonSound];
	
	DialogLayer *flagConfirmDialog = [[DialogLayer alloc] initFlaggerWithHeader: @"CONFIRM FLAG" target: self selector: @selector(flagConfirmButtonPressed:) andLevelName: [Director shared].stage.name];
	[self.parent addChild: flagConfirmDialog z: 9100];
	[self removeFromParentAndCleanup: YES];
}

- (void) flagConfirmButtonPressed: (id) sender
{
	[self playButtonSound];
	
	[[Director shared] flagLevel: [Director shared].stage.name];
	DialogLayer *thankYouDialog = [[DialogLayer alloc] initWithHeader: @"THANK YOU" andLine1: @"Thank you for your report. We will investigate the level you have flagged and take the appropriate action." target: self selector: @selector(cancelButtonPressed:) textField: NO];
	[self.parent addChild: thankYouDialog z: 9100];
	[self removeFromParentAndCleanup: YES];
}


- (void) retryButtonPressed: (id) sender
{
	[self playButtonSound];
	
	[callbackObj performSelector: selector withObject: [NSNumber numberWithBool: YES]];
}

- (void) nextStageButtonPressed: (id) sender
{
	[self playButtonSound];
	
	[callbackObj performSelector: selector withObject: [NSNumber numberWithBool: NO]];
}

- (void) okButtonPressed:(id) sender
{
    [self playButtonSound];
    
    [callbackObj performSelector: selector withObject: self];
    
    [self.textField removeFromSuperview];
    [self removeFromParentAndCleanup:YES];
}

- (void) cancelButtonPressed:(id) sender
{
    [self playButtonSound];
    
    [self.textField removeFromSuperview];
	[self.textField2 removeFromSuperview];
    [self removeFromParentAndCleanup:YES];
}

- (void) loginButtonPressed:(id) sender
{
    [self playButtonSound];
    
	NSArray *retArray = [NSArray arrayWithObjects: self.textField.text, self.textField2.text, nil];
	
    [callbackObj performSelector: selector withObject: retArray];
    
    [self.textField removeFromSuperview];
	[self.textField2 removeFromSuperview];
    [self removeFromParentAndCleanup:YES];
}

- (void) editButtonPressed: (id) sender
{
	[self playButtonSound];
	
	[Director shared].editing = YES;
	[[CCDirector sharedDirector] replaceScene: [CCTransitionFade transitionWithDuration: 0.0 scene: [StageLoadingLevel scene]]];
}

- (void) playButtonSound
{
	
}

@end