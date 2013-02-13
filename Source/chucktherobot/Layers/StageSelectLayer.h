//
//  StageSelectLayer.h
//  chucktherobot
//
//  Created by Marshall on 16/01/2013.
//
//

#import "Layer.h"

@interface StageSelectLayer : Layer
{
    int totalMenuItems;
	int menuItemsPerPage;
	bool pageTurning;
	UIPanGestureRecognizer *pan;
	
	//Boundries of all the major elements.
	CGRect topBounds;
	CGRect midBounds;
	CGRect arrowBounds;
	CGRect botBounds;
	
	//Sprites to hold various elements. These will be regularly updated.
	CCSprite *onlineLevelListSprite;
	CCSprite *onlineLevelDetailsSprite;
	CCSprite *titleBackground;
	CCSprite *creatorBackground;
	CCSprite *thumbsUpBackground;
}

typedef enum
{
    SelectTypeLocal = 0,
    SelectTypeWorld = 1
} SelectType;

@property int selectType;
@property CCNode *selectionNode;
@property CCMenu *pageMenu;

@end
