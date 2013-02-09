//
//  MToolsSceneManager.m
//  AppScaffold
//
//  Created by Marshall on 11/09/2012.
//
//
//TODO: Put in a method to make an overlay, message box, etc.
//TODO: Check and make sure we always return something if someone accesses current scene. That way we don't crash.

#import "MToolsSceneManager.h"
#import "MToolsDebug.h"

#define IS_IPHONE ( [ [ [ UIDevice currentDevice ] model ] isEqualToString: @"iPhone" ] )
#define IS_IPOD   ( [ [ [ UIDevice currentDevice ] model ] isEqualToString: @"iPod touch" ] )
#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

@implementation MToolsSceneManager

@synthesize currentScene;
@synthesize currentSceneName;
@synthesize isChanging;
@synthesize transitionType;

//Juggler for the scene transitions.
static SPJuggler *juggler;

//Singleton implementation.
static MToolsSceneManager *sharedManager = nil;

+ (MToolsSceneManager *) sharedManager
{
    if (!sharedManager)
    {
        sharedManager = [[MToolsSceneManager alloc] init];
    }
    return sharedManager;
}

- (id) init
{
    if (self = [super init])
    {
        scenes = [NSMutableDictionary dictionary];
        juggler = [SPJuggler juggler];
        landscapeMode = false;
        transitionType = SP_TRANSITION_EASE_OUT_BACK;
        
        [self setLandscapeMode: landscapeMode];
    }
    
    return self;
}

- (void) hook: (SPSprite *) hookup
{
    //Add a temporary scene if there's no scene available when we hook up.
    if (!currentScene)
    {
        SPSprite *scene = [SPSprite sprite];
        [self addScene: scene named: @"empty"];
        [self changeSceneTo: @"empty" withTransition: NO  withTime: 0.00f];
    }
    
    [hookup addEventListener: @selector(onEnterFrame:) atObject: self forType: SP_EVENT_TYPE_ENTER_FRAME];
    [hookup addChild: currentScene];
}

//Simple on frame to advance the scene juggler.
- (void)onEnterFrame: (SPEnterFrameEvent *) event
{
    [juggler advanceTime:event.passedTime];
}

//Used to add a scene to the manager.
- (void) addScene: (SPSprite *) newScene named: (NSString *) name
{
    [scenes setValue: newScene forKey: name];
}

- (void) quickLoadScene: (SPSprite *) newScene
{    
    [currentScene.parent addChild: newScene];
    currentScene = newScene;
    
    [self removeScene: currentSceneName];
    currentSceneName = nil;
    
    [self setLandscapeMode: landscapeMode];
}

//Used to remove a scene to the manager.
- (void) removeScene: (NSString *) name
{
    if (!name)
        return;
    
    [[scenes objectForKey: name] removeFromParent];
    [scenes removeObjectForKey: name];
}

//TODO: Put in a better default.
//Changes the current scene to whatever is given.
- (void) changeSceneTo: (NSString *) name withTransition: (bool) transition withTime: (float) time
{
    if (isChanging)
        return;
    
    //NSLog(@"Changing scene to %@", name);
    float sceneTransitionTime = time;
    SPDisplayObjectContainer *sceneParent = currentScene.parent;
    
    //Only perform the scene out transitions if there's a current scene displayed and they want a transition.
    SPTween *sceneTransitionOut;
    if (transition)
    {
        if (currentScene)
        {
            isChanging = true;
            sceneTransitionOut = [SPTween tweenWithTarget: currentScene time: sceneTransitionTime transition: transitionType];
            [sceneTransitionOut animateProperty: @"x" targetValue: currentScene.x + sceneParent.width];
            [sceneTransitionOut addEventListener: @selector(retireScene:) atObject: self forType: SP_EVENT_TYPE_TWEEN_COMPLETED];
            [juggler addObject: sceneTransitionOut];
            //[self removeScene: currentSceneName];
        }

        currentScene = [scenes objectForKey: name];
        [self setLandscapeMode: landscapeMode];
        currentScene.x -= currentScene.width;
        [sceneParent addChild: currentScene];
        currentSceneName = name;

        SPTween *sceneTransitionIn = [SPTween tweenWithTarget: currentScene time: sceneTransitionTime transition: transitionType];
        [sceneTransitionIn animateProperty: @"x" targetValue: 0];
        sceneTransitionIn.delay = sceneTransitionTime;
        [juggler addObject: sceneTransitionIn];
    }
    else
    {
        [self removeScene: currentSceneName];
        
        currentScene = [scenes objectForKey: name];
        [self setLandscapeMode: landscapeMode];
        [sceneParent addChild: currentScene];
        currentSceneName = name;  
    }
}

//Removes a scene from the main stage.
- (void) retireScene: (SPEvent *) event
{
    SPTween *tween = event.target;
    SPSprite *scene = tween.target;
    [scene removeFromParent];
    
    isChanging = false;
}

- (void) setLandscapeMode: (bool) value
{
    landscapeMode = value;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        if (landscapeMode)
        {
            currentScene.x = -64;
            currentScene.y = 64;
        }
        else
        {
            currentScene.x = 0;
            currentScene.y = 0;
        }
    }
    else
    {
        if (landscapeMode)
        {
            currentScene.x = -80;
            currentScene.y = 80;
            if (IS_IPHONE_5)
            {
                currentScene.x = -124;
                currentScene.y = 124;
            }
        }
        else
        {
            currentScene.x = 0;
            currentScene.y = 0;
        }
    }
}

@end
