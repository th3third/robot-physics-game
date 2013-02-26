//
//  DialogLayer.h
//  concentrate
//
//  Created by Paul Legato on 12/4/10.
//  Copyright 2010 Paul Legato. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CustomTextField.h"
#import "CCUIViewWrapper.h"

@interface DialogLayer : CCLayer <UITextFieldDelegate>
{
    float backgroundWidth;
	float backgroundHeight;
	NSString *header;
	NSMutableArray *currentTags;
	
	CCMenuItemImage *likeButton;
	CCMenuItemImage *dislikeButton;
	CCLabelTTF *ratingThanksLabel;
}

@property id callbackObj;
@property SEL selector;
@property CustomTextField *textField;
@property CustomTextField *textField2;
@property CustomTextField *textField3;
@property CCUIViewWrapper *textFieldWrapper;
@property CCUIViewWrapper *textFieldWrapper2;
@property CCUIViewWrapper *textFieldWrapper3;
@property int buttonPressedIndex;
@property int dialogType;

- (id) initNotificationWithMessage: (NSString *) message;
- (id) initNotificationWithMessage: (NSString *) message callback: (id) callbackObjNew selector: (SEL) selectorNew;
- (id) initChoiceWithMessage: (NSString *) message callback: (id) callbackObjNew selector: (SEL) selectorNew;
- (id) initChoiceWithMessage: (NSString *) message callback: (id) callbackObjNew selector: (SEL) selectorNew selectorCancel: (SEL) selectorCancel;
- (id) initLoader;
- (id) initCreateAccountWithCallbackObj: (id) callbackObjNew selector: (SEL) selectorNew;
- (id) initLoginWithCallbackObj: (id) callbackObjNew selector: (SEL) selectorNew;
- (id) initWinnerWithHeader: (NSString *) headerIn target: (id) callbackObjNew selector: (SEL) selectorNew andTimeElapsed: (float) timeElapsed andScore: (int) score;
- (id) initFlaggerWithHeader: (NSString *) headerIn target: (id) callbackObjNew selector: (SEL) selectorNew andLevelName: (NSString *) levelName;
- (id) initStageMenuWithHeader: (NSString *) headerIn target: (id) callbackObjNew selector: (SEL) selectorNew;
- (id) initSaveWithCallbackObj: (id) callbackObjNew selector: (SEL) selectorNew;
- (id) initPurchaseWithCallbackObj: (id) callbackObjNew selector: (SEL) selectorNew;
- (id) initCreditsWithCallbackObj: (id) callbackObjNew selector: (SEL) selectorNew;
- (id) initAllLevelsCompletedWithStars: (bool) allStars;

- (void) okButtonPressed:(id) sender;
- (void) remove;

- (void) changeStageName: (DialogLayer *) diaglayer;

+ (void) playButtonSound;
+ (CCSprite *) createTextWithShadow: (NSString *) string textSize: (float) textSize;
+ (CCLabelTTF*) createShadowHeaderWithString:(NSString*)string position:(CGPoint)pos shadowOffset:(CGSize)offset color:(ccColor3B)col shadowColor:(ccColor3B)shadowCol dimensions:(CGSize)dimensions hAlignment:(CCTextAlignment)uiTextAlignment lineBreakMode:(CCLineBreakMode)lineBreakMode fontSize:(float)fontSize;
+ (CCLabelTTF*) createShadowHeaderWithString:(NSString*)string position:(CGPoint)pos shadowOffset:(CGSize)offset color:(ccColor3B)col shadowColor:(ccColor3B)shadowCol dimensions:(CGSize)dimensions hAlignment:(CCTextAlignment)uiTextAlignment vAlignment: (CCVerticalTextAlignment) uiVTextAlignment lineBreakMode :(CCLineBreakMode)lineBreakMode fontSize:(float)fontSize;

@end