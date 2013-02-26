//
//  SetupLayer.m
//  chuckthebot
//
//  Created by Marshall on 25/02/2013.
//
//

#import "SetupLayer.h"
#import "IntroLayer.h"

@implementation SetupLayer

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	SetupLayer *layer = [SetupLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(void) onEnter
{
	[super onEnter];
	
	// In one second transition to the new scene
	[self scheduleOnce:@selector(makeTransition:) delay: 0];
}

-(void) makeTransition:(ccTime)dt
{
	if ([CCDirector sharedDirector].isWidescreen)
	{
		//MOVE THE VIEW, PLEASE
		UIView *glView = [CCDirector sharedDirector].view;
		CGRect newFrame = CGRectMake(44, 0, glView.frame.size.width, glView.frame.size.height);
		[UIView animateWithDuration: 0 animations:^{
			glView.frame = newFrame;
		}];
	}
	
	[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration: 1.0 scene:[IntroLayer scene] withColor: ccBLACK]];
}


@end
