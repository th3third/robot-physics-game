//
//  BotSelectLayer.h
//  chuckthebot
//
//  Created by Marshall on 11/02/2013.
//
//

#import "Layer.h"

@interface BotSelectLayer : Layer
{
	CCMenu *pageMenu;
	CCNode *selectionNode;
	int menuItemsPerPage;
	int totalMenuItems;
	int enabledMenuItems;
	
	bool pageTurning;
	
	UIPanGestureRecognizer *pan;
}

@end
