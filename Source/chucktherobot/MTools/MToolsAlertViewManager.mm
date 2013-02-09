//
//  MToolsAlertViewManager.m
//  AppScaffold
//
//  Created by Marshall on 20/09/2012.
//
//

#import "MToolsAlertViewManager.h"

@implementation MToolsAlertViewManager

@synthesize delegate;

//Singleton implementation.
static MToolsAlertViewManager *sharedManager = nil;

+ (MToolsAlertViewManager *) sharedManager
{
    if (!sharedManager)
    {
        sharedManager = [[MToolsAlertViewManager alloc] init];
        sharedManager.delegate = sharedManager;
    }
    return sharedManager;
}

- (void) alertWithMessage: (NSString *) string
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"" message: string delegate: delegate cancelButtonTitle: @"Okay" otherButtonTitles: nil];
    [alert show];
}

- (UIAlertView *) alertWithInput: (bool) input andMessage:(NSString *) string andTitle: (NSString *) title numOnly: (bool) numpad
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: title message: string delegate: delegate cancelButtonTitle: @"Okay" otherButtonTitles: nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    if (numpad)
        [[alert textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeNumberPad];
    
    [alert show];
    
    return alert;
}

@end
