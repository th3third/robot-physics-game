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
#import "MyContactListener.h"

#define trimEnds( object ) [object stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet] ]

#ifdef PREPAID

#define PREPAID_VERSION true

#endif

#ifndef PREPAID

#define PREPAID_VERSION false

#endif

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
	float timeoutInterval;
}

@property MyContactListener *_contactListener;
@property (nonatomic) bool fullVersion;
@property NSURL *levelsServerURL;
@property NSURL *loginScriptURL;
@property NSURL *createUserScriptURL;
@property NSURL *saveLevelScriptURL;
@property NSURL *loadLevelScriptURL;
@property NSURL *listingsScriptURL;
@property NSURL *flagLevelScriptURL;
@property NSURL *rateLevelScriptURL;
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
@property int levelSelectPageNum;
@property int localLevelIndex;
@property (nonatomic) bool loggedIn;
@property (nonatomic) bool processingNetworkRequest;
@property (nonatomic) NSArray *localLevelsList;
@property (nonatomic) NSArray *defaultLevelsList;
@property (nonatomic) int onlineLevelsListCount;
@property (nonatomic) CGSize scaleFactor;
@property NSDictionary *presetScores;
@property DialogLayer *currentDialog;

//Scaling
@property float ip5Scale;

//Chuck stuff.
@property NSString *botType;

//Authentication stuff.
@property NSString *username;
@property NSString *hashedPassword;

//Player login stuff.
@property (nonatomic) NSString *playerName;

+ (Director *) shared;
+ (NSString *) levelsPath;
+ (NSString *) sha: (NSString *) string;
- (int) getNewObjectID;

//User stuffz.
- (bool) createUsername: (NSString *) username andPassword: (NSString *) password andEmail: (NSString *) email;
- (bool) logInWithUsername: (NSString *) username andPassword: (NSString *) encryptedPassword;
- (void) logout;
- (bool) saveLevelToServer;
- (bool) getLevelFromServer;
- (void) loadCurrentStage;
- (void) loadBlankStage;
- (void) nextLocalLevel;
- (int) getScoreForLevel: (NSString *) name;
- (void) flagLevel: (NSString *) name;
- (void) rateLevel: (NSString *) name withRating: (int) rating;
- (NSArray *) onlineLevelsList: (int) number withSorting: (int) sorting;

//Music player.
- (void) playMusic: (NSString *) bgm;
- (void) stopMusic;
- (void) toggleSound;

//Scaling
- (CGPoint) scalePoint:(CGPoint)point;

@end
