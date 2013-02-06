//
//  Director.h
//  chucktherobot
//
//  Created by Marshall on 07/01/2013.
//
//

#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"
#import <Foundation/Foundation.h>
#import "Stage.h"

enum DataState
{
	DATA_STATE_LOGGING_IN = 0,
	DATA_STATE_CREATING_USERNAME = 1,
	DATA_STATE_SAVING_LEVEL = 2,
	DATA_STATE_LOADING_LEVEL = 3,
	DATA_STATE_LOADING_LISTINGS = 4
};

@class Stage;

@interface Director : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate, NSURLConnectionDownloadDelegate>
{
	GLESDebugDraw *m_debugDraw;
}

@property NSURL *levelsServerURL;
@property NSURL *loginScriptURL;
@property NSURL *createUserScriptURL;
@property NSURL *saveLevelScriptURL;
@property NSURL *loadLevelScriptURL;
@property NSURL *listingsScriptURL;
@property NSURLConnection *connection;
@property (nonatomic) bool paused;
@property bool editing;
@property bool online;
@property bool drawDebugData;
@property bool soundEnabled;
@property (nonatomic) NSString *stageName;
@property Stage *stage;
@property b2World *world;
@property int objID;
@property NSString *globalFont;
@property int numOfBackgrounds;
@property int dataState;
@property (nonatomic) bool loggedIn;
@property (nonatomic) bool processingNetworkRequest;
@property (nonatomic) NSArray *localLevelsList;
@property (nonatomic) NSArray *defaultLevelsList;
@property (nonatomic) CGSize scaleFactor;

//Authentication stuff.
@property NSString *username;
@property NSString *hashedPassword;

//Player login stuff.
@property (nonatomic) NSString *playerName;

+ (Director *) shared;
+ (NSString *) levelsPath;
- (int) getNewObjectID;

//User stuffz.
- (DialogLayer *) createLogInDialog;
- (bool) createUsername: (NSString *) username andPassword: (NSString *) password;
- (bool) logInWithUsername: (NSString *) username andPassword: (NSString *) encryptedPassword;
- (bool) saveLevelToServer;
- (bool) getLevelFromServer;
- (void) loadCurrentStage;
- (void) loadBlankStage;
- (NSArray *) onlineLevelsList: (int) number withSorting: (int) sorting;

//Scaling
- (CGPoint) scalePoint:(CGPoint)point;

@end
