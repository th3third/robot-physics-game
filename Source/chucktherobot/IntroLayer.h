//
//  IntroLayer.h
//  chucktherobot
//
//  Created by Marshall on 03/01/2013.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "Layer.h"

// HelloWorldLayer
@interface IntroLayer : Layer
{
	CCActionTween *spinnerTween;
	CCSprite *spinner;
	CCLabelTTF *statusLabel;
}

@end
