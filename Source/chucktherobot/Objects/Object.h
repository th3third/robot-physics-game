//
//  Object.h
//  Chuck the Robot
//
//  Created by Marshall on 03/01/2013.
//
//

#import "cocos2d.h"
#import "Box2D.h"
#import "Director.h"
#import "SimpleAudioEngine.h"

struct ObjectUserData
{
	id objectID;
};

@interface Object : CCNode
{
	float soundCooldown;
}

@property b2World *world;
@property b2Body *body;
@property CCSprite *bodyVisible;
@property bool changing;
@property NSMutableArray *groups;

@property CFUUIDRef cfid;
@property CGPoint startPos;
@property CGPoint curPos;
@property (nonatomic) CGPoint centerPos;
@property (nonatomic) float rotationAngle;
@property (nonatomic) float rotationForce;
@property (nonatomic) float restitution;
@property int z;
@property (nonatomic) bool alive;
@property int type;
@property (nonatomic) bool movable;
@property (nonatomic) bool poppable;
@property (nonatomic) float widthAbs;
@property (nonatomic) float heightAbs;
@property (nonatomic) bool needToChangeTexture;
@property (nonatomic) float minimumSize;
@property NSString *idleSound;
@property int hitSounds;
@property int hitBouncySounds;
@property int popSounds;
@property ALuint hitSoundPlaying;
@property ALuint idleSoundPlaying;
@property CDSoundSource *soundPlaying;

+ (Object *) object;

- (id) initWithCFID: (CFUUIDRef) newID;
- (id) copy;
- (void) copyVars: (Object *) copy;

- (void) createBox2DBody;
- (void) createVisibleBody;
- (void) createObjectUserData;

- (void) tick: (ccTime) dt;
- (void) attachObject: (Object *) object;
- (void) moveToPoint: (CGPoint) point;
- (void) moveByX: (float) x andY: (float) y;
- (void) moveBodyByX: (float) x andY: (float) y;
- (NSArray *) moveAttachedObjectsByX: (float) x andY: (float) y;
- (void) pop;
- (void) remove;
- (void) reset;
- (void) wakeUp;
- (void) display;
- (void) tint;
- (void) hit;
- (void) hitWithForce: (float) force;

- (NSString *) serialize;
- (id) unserializeWithDict: (NSDictionary *) dict;

@end
