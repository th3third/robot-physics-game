//
//  StageLayer.h
//  chucktherobot
//
//  Created by Marshall on 03/01/2013.
//
//

#import "Layer.h"
#import "Chuck.h"
#import "CCMenuAdvanced.h"
#import "MyContactListener.h"

@interface StageLayer : Layer <CCStandardTouchDelegate, CCTargetedTouchDelegate>
{
    NSMutableArray *stageObjects;
    id selectedObject;
    id selectedObject2;
	float timeElapsedSinceStart;
	int score;
	bool levelCompleted;
    Chuck *chuck;
    CGPoint touchStart;
    NSMutableArray *drawPoints;
	CCSprite *buttonSelector;
    CCSprite *selector;
	CCSprite *selector2;
	CCSprite *editorBar;
	CCSprite *editorBarBot;
	CCSprite *editorBarLeft;
	CCSprite *motorArrows;
	CCSprite *background;
	CCSprite *botEditorBackground;
	CCSprite *leftEditorBackground;
	
	CCMenuItemSprite *gear;
	
	//Help menu
	CCSprite *loadingBackground;
	CCLabelTTF *loadingLabel;
	UIPanGestureRecognizer *pan;
	bool pageTurning;
	int helpPageNum;
	CCMenu *helpCloseMenu;
	CCMenu *pageMenu;
	CCMenu *helpMenu;
	
	//Dialogs
	DialogLayer *winDialog;
	DialogLayer *purchaseDialog;
	
	//Saving vars
	CCMenuItemFont *stageNameItem;
	CCMenuItemSprite *sound;
	CCMenuItemImage *playButton;
}

typedef enum
{
	DRAWING_MODE_SELECTION = 0,
	DRAWING_MODE_RECTANGLE = 1,
	DRAWING_MODE_CIRCLE = 2,
	DRAWING_MODE_ROPE = 3,
	DRAWING_MODE_PIVOT = 4,
	DRAWING_MODE_BALLOON = 5,
	DRAWING_MODE_ROTATE = 6,
	DRAWING_MODE_WELD = 7,
	DRAWING_MODE_POPPABLE = 8,
	DRAWING_MODE_STATIC = 9,
	DRAWING_MODE_BOUNCY = 10,
	DRAWING_MODE_DELETE = 11,
	DRAWING_MODE_COPY = 12,
	DRAWING_MODE_MOTOR = 13
} DrawingMode;

typedef enum
{
	MOTOR_DIRECTION_CW = 0,
	MOTOR_DIRECTION_CCW = 1
} MotorDirection;

typedef enum
{
	MOTOR_SPEED_SLOW = 0,
	MOTOR_SPEED_MED = 1,
	MOTOR_SPEED_FAST = 2
} MotorSpeed;

@property (nonatomic) int drawingMode;
@property (nonatomic) int motorSpeed;
@property (nonatomic) int motorDirection;
@property (nonatomic) bool paused;
@property (nonatomic) int snapDivider;

@end
