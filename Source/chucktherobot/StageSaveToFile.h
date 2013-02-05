//
//  StageSaveToFile.h
//  chucktherobot
//
//  Created by Marshall on 23/01/2013.
//
//

#import "Layer.h"

@interface StageSaveToFile : Layer
{
	bool finishedLocalSave;
	bool finishedOnlineSave;
	bool savingStage;
	
	CCActionTween *spinnerTween;
	CCSprite *spinner;
	
	CCLabelTTF *statusLabel;
}

@end
