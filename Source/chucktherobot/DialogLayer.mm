//
//  DialogLayer.m
//  concentrate
//
//  Created by Paul Legato on 12/4/10.
//  Copyright 2010 Paul Legato. All rights reserved.
//

#import "DialogLayer.h"

#define DIALOG_FONT @"Verdana"
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

- (id) initWithHeader:(NSString *)header andLine1:(NSString *)line1 target:(id)callbackObjNew selector:(SEL)selectorNew textField: (bool) doTextField andExistingText: (NSString *) existingText andCancelButton: (bool) addCancelButton
{
	self.dialogType = 0;
	
    if((self = [super init]))
    {
        callbackObj = callbackObjNew;
        selector = selectorNew;
        
        CGSize screenSize = [CCDirector sharedDirector].winSize;
		
        CCSprite *background = [CCSprite node];
        background = [background initWithFile:@"Media/Backgrounds/background_dialog.png"];
		float scale = 1.00f;
		if (background.contentSize.width > screenSize.width)
		{
			scale = screenSize.width / background.contentSize.width;
		}
		[background setScale: scale * 0.75];
        [background setPosition:ccp(screenSize.width / 2, screenSize.height / 2)];
        [self addChild:background z:-1];
        
        float backgroundWidth = background.contentSize.width * background.scale;
        float backgroundHeight = background.contentSize.height * background.scale;
        
        CCLabelTTF *headerShadow = [CCLabelTTF labelWithString:header fontName: DIALOG_FONT fontSize: DIALOG_FONT_SIZE];
        headerShadow.color = ccBLACK;
        headerShadow.opacity = 190;
        [headerShadow setPosition:ccp(background.position.x - DIALOG_FONT_SHADOW_OFFSET, background.position.y + backgroundHeight / 2 - DIALOG_FONT_SIZE * 1.5 - DIALOG_FONT_SHADOW_OFFSET)];
        [self addChild:headerShadow];
        
        CCLabelTTF *headerLabel = [CCLabelTTF labelWithString:header fontName: DIALOG_FONT fontSize: DIALOG_FONT_SIZE];
        headerLabel.color = ccBLACK;
        [headerLabel setPosition:ccp(background.position.x, background.position.y + backgroundHeight / 2 - DIALOG_FONT_SIZE * 1.5)];
        [self addChild:headerLabel];
        
        //////////////////
        
        CCLabelTTF *line1Label = [CCLabelTTF labelWithString: line1 fontName: DIALOG_FONT fontSize: DIALOG_FONT_SIZE];
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
			CCMenuItemImage *cancelButton = [CCMenuItemImage itemFromNormalImage:@"Media/Buttons/general/CancelButton.png" selectedImage:@"Media/Buttons/general/CancelButtonSelected.png" target:self selector:@selector(cancelButtonPressed:)];
			[cancelButton setPosition: ccp(background.position.x - backgroundWidth / 4, background.position.y - backgroundHeight / 5)];
			[buttons addObject: cancelButton];
		}
		
		CCMenuItemImage *okButton = [CCMenuItemImage itemFromNormalImage:@"Media/Buttons/general/OKButton.png" selectedImage:@"Media/Buttons/general/OKButtonSelected.png" target:self selector:@selector(okButtonPressed:)];
        [okButton setPosition: ccp(okButtonPosX, background.position.y - backgroundHeight / 5)];
		[buttons addObject: okButton];
        
        CCMenu *menu = [CCMenu menuWithArray: buttons];
        menu.position = ccp(0, -backgroundHeight / 6 + DIALOG_FONT_OFFSET);
        [self addChild:menu];
		
        if (doTextField)
        {
            self.textField = [[UITextField alloc] initWithFrame: CGRectMake(0, 0, backgroundWidth * 0.8, 24)];
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

- (id) initLoginWithHeader:(NSString *)header target:(id)callbackObjNew selector:(SEL)selectorNew andExistingText: (NSString *) existingText
{
	self.dialogType = 1;
	
	if((self = [super init]))
    {
        callbackObj = callbackObjNew;
        selector = selectorNew;
        
        CGSize screenSize = [CCDirector sharedDirector].winSize;
		
        CCSprite *background = [CCSprite node];
        background = [background initWithFile:@"Media/Backgrounds/background_dialog.png"];
		float scale = 1.00f;
		if (background.contentSize.width > screenSize.width)
		{
			scale = screenSize.width / background.contentSize.width;
		}
		[background setScale: scale * 0.75];
        [background setPosition:ccp(screenSize.width / 2, screenSize.height / 2)];
        [self addChild:background z:-1];
        
        float backgroundWidth = background.contentSize.width * background.scale;
        float backgroundHeight = background.contentSize.height * background.scale;
        
        CCLabelTTF *headerShadow = [CCLabelTTF labelWithString:header fontName: DIALOG_FONT fontSize: DIALOG_FONT_SIZE];
        headerShadow.color = ccBLACK;
        headerShadow.opacity = 190;
        [headerShadow setPosition:ccp(background.position.x - DIALOG_FONT_SHADOW_OFFSET, background.position.y + backgroundHeight / 2 - DIALOG_FONT_SIZE * 1.5 - DIALOG_FONT_SHADOW_OFFSET)];
        [self addChild:headerShadow];
        
        CCLabelTTF *headerLabel = [CCLabelTTF labelWithString:header fontName: DIALOG_FONT fontSize: DIALOG_FONT_SIZE];
        headerLabel.color = ccBLACK;
        [headerLabel setPosition:ccp(background.position.x, background.position.y + backgroundHeight / 2 - DIALOG_FONT_SIZE * 1.5)];
        [self addChild:headerLabel];
        
		NSMutableArray *buttons = [NSMutableArray array];
		float okButtonPosX = background.position.x;

		//Cancel button.
		okButtonPosX += backgroundWidth / 4;
		CCMenuItemImage *cancelButton = [CCMenuItemImage itemFromNormalImage:@"Media/Buttons/general/CancelButton.png" selectedImage:@"Media/Buttons/general/CancelButtonSelected.png" target:self selector:@selector(cancelButtonPressed:)];
		[cancelButton setPosition: ccp(background.position.x - backgroundWidth / 4, background.position.y - backgroundHeight / 5)];
		[buttons addObject: cancelButton];
		
		//OK button.
		CCMenuItemImage *okButton = [CCMenuItemImage itemFromNormalImage:@"Media/Buttons/general/OKButton.png" selectedImage:@"Media/Buttons/general/OKButtonSelected.png" target:self selector:@selector(loginButtonPressed:)];
        [okButton setPosition: ccp(okButtonPosX, background.position.y - backgroundHeight / 5)];
		[buttons addObject: okButton];
        
        CCMenu *menu = [CCMenu menuWithArray: buttons];
        menu.position = ccp(0, -backgroundHeight / 6 + DIALOG_FONT_OFFSET);
        [self addChild:menu];
		
		//Text fields.
		//Username
		self.textField = [[UITextField alloc] initWithFrame: CGRectMake(0, 0, backgroundWidth * 0.8, 24)];
		self.textField.borderStyle = UITextBorderStyleRoundedRect;
		self.textField.center = ccp([[CCDirector sharedDirector] view].center.x , [[CCDirector sharedDirector] view].center.y - backgroundHeight / 4);
		self.textField.delegate = self;
		[self.textField setPlaceholder: @"username"];
		self.textField.text = existingText;
		[self.textField becomeFirstResponder];
		[[[CCDirector sharedDirector] view] addSubview: self.textField];
		
		//Password
		self.textField2 = [[UITextField alloc] initWithFrame: CGRectMake(0, 0, backgroundWidth * 0.8, 24)];
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

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
	if (self.dialogType == 0)
		[self okButtonPressed: self];
	else if (self.dialogType == 1)
		[self loginButtonPressed: self];
	
    return NO;
}

- (void) okButtonPressed:(id) sender
{
    [self playButtonSound];
    
    [callbackObj performSelector: selector withObject: self];
    
    [self.textField removeFromSuperview];
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

- (void) cancelButtonPressed:(id) sender
{
    [self playButtonSound];
    
    [self.textField removeFromSuperview];
    [self removeFromParentAndCleanup:YES];
}

- (void) playButtonSound
{
	
}

@end