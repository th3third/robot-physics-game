//
//  DialogLayer.h
//  concentrate
//
//  Created by Paul Legato on 12/4/10.
//  Copyright 2010 Paul Legato. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface DialogLayer : CCLayer <UITextFieldDelegate>
{
    float backgroundWidth;
	float backgroundHeight;
	NSString *header;
}

@property id callbackObj;
@property SEL selector;
@property UITextField *textField;
@property UITextField *textField2;
@property int buttonPressedIndex;
@property int dialogType;

-(id) initWithHeader:(NSString *)header andLine1:(NSString *)line1 target:(id)callbackObjNew selector:(SEL)selectorNew textField: (bool) doTextField;
- (id) initWithHeader:(NSString *)header andLine1:(NSString *)line1 target:(id)callbackObjNew selector:(SEL)selectorNew textField: (bool) doTextField andExistingText: (NSString *) existingText andCancelButton: (bool) addCancelButton;
- (id) initLoginWithHeader:(NSString *)headerIn target:(id)callbackObjNew selector:(SEL)selectorNew andExistingText: (NSString *) existingText;
- (id) initWinnerWithHeader: (NSString *) headerIn target: (id) callbackObjNew selector: (SEL) selectorNew andTimeElapsed: (float) timeElapsed andScore: (int) score;
- (id) initFlaggerWithHeader: (NSString *) headerIn target: (id) callbackObjNew selector: (SEL) selectorNew andLevelName: (NSString *) levelName;
- (id) initStageMenuWithHeader: (NSString *) headerIn target: (id) callbackObjNew selector: (SEL) selectorNew;

-(void) okButtonPressed:(id) sender;

- (void) changeStageName: (DialogLayer *) diaglayer;

@end