//
//  Layer.m
//  chucktherobot
//
//  Created by Marshall on 03/01/2013.
//
//

#import "Layer.h"
#import "DialogLayer.h"
#import "Director.h"

@implementation Layer

- (id) init
{
	if (self = [super init])
	{
		[self schedule: @selector(updateFrame) interval: 0.05f];
	}
	
	return self;
}

- (void) updateFrame
{
    //MOVE THE VIEW, PLEASE
	UIView *glView = [CCDirector sharedDirector].view;
	
	if (glView.frame.size.width == 568 && glView.frame.origin.x != 44)
	{
		CGRect newFrame = CGRectMake(44, 0, glView.frame.size.width, glView.frame.size.height);
		[UIView animateWithDuration: 0 animations:^{
			glView.frame = newFrame;
		}];
	}
}

- (void) logInWith: (NSArray *) loginInfo
{
	if (!loginInfo || ![loginInfo isKindOfClass: [NSArray class]])
		return;
	
	if ([loginInfo count] < 2)
	{
		DialogLayer *errorLoggingInDialog = [[DialogLayer alloc] initNotificationWithMessage: @"You must enter a username and password."];
		[self addChild: errorLoggingInDialog z: 9000];
		
		return;
	}
	
	NSString *username = [loginInfo objectAtIndex: 0];
	NSString *password = [loginInfo objectAtIndex: 1];
	
	if (!username || !password || [trimEnds(username) length] == 0 || ![[Director shared] logInWithUsername: username andPassword: password])
	{
		DialogLayer *errorLoggingInDialog = [[DialogLayer alloc] initNotificationWithMessage: @"You have entered an incorrect username and password combination or that user does not exist."];
		[self addChild: errorLoggingInDialog z: 9000];
		
		return;
	}
}


@end
