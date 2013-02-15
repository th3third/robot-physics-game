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

- (void) logInWith: (NSArray *) loginInfo
{
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
