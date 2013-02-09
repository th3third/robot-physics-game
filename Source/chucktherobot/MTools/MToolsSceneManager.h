//
//  MToolsSceneManager.h
//  AppScaffold
//
//  Created by Marshall on 11/09/2012.
//
//

#import <Foundation/Foundation.h>

@interface MToolsSceneManager : SPEventDispatcher
{
    NSMutableDictionary *scenes;
    bool landscapeMode;
}

@property NSString *currentSceneName;
@property SPSprite *currentScene;
@property SPSprite *sceneBuffer;
@property bool isChanging;
@property NSString *transitionType;

+ (MToolsSceneManager *) sharedManager;

- (void) addScene: (SPSprite *) newScene named: (NSString *) name;
- (void) changeSceneTo: (NSString *) name withTransition: (bool) transition withTime: (float) time;
- (void) quickLoadScene: (SPSprite *) newScene;

- (void) setLandscapeMode: (bool) value;
- (void) hook: (SPSprite *) hookup;

@end
