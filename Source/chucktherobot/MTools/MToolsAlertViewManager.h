//
//  MToolsAlertViewManager.h
//  AppScaffold
//
//  Created by Marshall on 20/09/2012.
//
//

#import <Foundation/Foundation.h>

@interface MToolsAlertViewManager : NSObject <UIAlertViewDelegate>

@property (unsafe_unretained) id delegate;

+ (MToolsAlertViewManager *) sharedManager;

- (void) alertWithMessage: (NSString *) string;
- (UIAlertView *) alertWithInput: (bool) input andMessage:(NSString *) string andTitle: (NSString *) title numOnly: (bool) numpad;

@end
