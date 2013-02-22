//
//  StageLoadingLevel.h
//  chucktherobot
//
//  Created by Marshall on 31/01/2013.
//
//

#import "Layer.h"

@interface StageLoadingLevel : Layer
{
	bool downloadingLevel;
	bool finishedDownloadingLevel;
	
	CCActionTween *spinnerTween;
	CCSprite *spinner;
	CCLabelTTF *statusLabel;
}

@end
