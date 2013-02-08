//
//  StageSaveLayer.h
//  chucktherobot
//
//  Created by Marshall on 16/01/2013.
//
//

#import "Layer.h"

@interface StageSaveLayer : Layer <UITextFieldDelegate>
{
	CCMenuItemFont *stageNameItem;
	NSMutableArray *currentTags;
	NSMutableArray *tagNames;
}

@end
