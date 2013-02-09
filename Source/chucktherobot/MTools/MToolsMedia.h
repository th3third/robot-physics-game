//
//  MToolsMedia.h
//  AppScaffold
//

#import <Foundation/Foundation.h>

@interface MToolsMedia : NSObject

+ (void)initAtlas;
+ (void)releaseAtlas;

+ (void)init;

+ (void) autocache: (bool) value;

+ (void) storeTexture: (SPTexture *) newTexture ofName: (NSString *) textureName ofType: (NSString *) type;

+ (SPTexture *)getTexture:(NSString *)textureName;
+ (SPTexture *)getTexture:(NSString *)textureName ofType: (NSString *) type;
+ (SPTexture *)getTexture:(NSString *)textureName fromURL: (NSString *) path ofType:(NSString *)type;

+ (SPSound *)getSound:(NSString *)soundName;
+ (SPSound *)getSound:(NSString *)soundName ofType: (NSString *) type;

+ (SPTexture *)atlasTexture:(NSString *)name;
+ (NSArray *)atlasTexturesWithPrefix:(NSString *)prefix;

+ (void)initSound;
+ (void)releaseSound;

+ (SPSoundChannel *)soundChannel:(NSString *)soundName;
+ (void)playSound: (NSString *) soundName;
+ (void)playSound: (NSString *) soundName ofType: (NSString *) type;

@end
