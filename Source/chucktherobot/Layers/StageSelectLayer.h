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
    
}

typedef enum
{
    SelectTypeLocal = 0,
    SelectTypeWorld = 1
} SelectType;

@property int selectType;
@property CCNode *selectionNode;

@end
