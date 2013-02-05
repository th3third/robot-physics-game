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
    
}

@property id callbackObj;
@property SEL selector;
@property UITextField *textField;
@property UITextField *textField2;
@property int buttonPressedIndex;
@property int dialogType;

-(id) initWithHeader:(NSString *)header andLine1:(NSString *)line1 target:(id)callbackObjNew selector:(SEL)selectorNew textField: (bool) doTextField;
- (id) initWithHeader:(NSString *)header andLine1:(NSString *)line1 target:(id)callbackObjNew selector:(SEL)selectorNew textField: (bool) doTextField andExistingText: (NSString *) existingText andCancelButton: (bool) addCancelButton;
- (id) initLoginWithHeader:(NSString *)header target:(id)callbackObjNew selector:(SEL)selectorNew andExistingText: (NSString *) existingText;

-(void) okButtonPressed:(id) sender;

- (void) changeStageName: (DialogLayer *) diaglayer;

@end