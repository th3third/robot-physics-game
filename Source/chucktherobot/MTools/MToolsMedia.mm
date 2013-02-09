//
//  MToolsMedia.m
//  AppScaffold
//

#import "MToolsMedia.h"


@implementation MToolsMedia

static SPTextureAtlas *atlas = NULL;
static NSMutableDictionary *sounds = NULL;
static NSMutableDictionary *textures = NULL;
static bool autocache = true;
static SPTexture *texture;
static SPSound *sound;

#pragma mark Textures
+ (void)init
{
    if (textures && sounds)
        return;
    
    textures = [NSMutableDictionary dictionary];
    sounds = [NSMutableDictionary dictionary];
}

+ (void) autocache: (bool) value
{
    autocache = value;
}

+ (void) storeTexture: (SPTexture *) newTexture ofName: (NSString *) textureName ofType: (NSString *) type
{
    [textures setObject: newTexture forKey: [textureName stringByAppendingPathExtension: type]];
}

+ (SPTexture *)getTexture:(NSString *)textureName
{    
    return [self getTexture: textureName ofType: @"png"];
}

+ (SPTexture *)getTexture:(NSString *)textureName ofType: (NSString *) type
{
    return [self getTexture: textureName fromURL: [[NSBundle mainBundle] resourcePath] ofType: type];
}

+ (SPTexture *)getTexture:(NSString *)textureName fromURL: (NSString *) path ofType:(NSString *)type
{
    @autoreleasepool
    {        
        //Check and see if we've already loaded that texture. If so, just return the texture.
        if ([textures objectForKey: [textureName stringByAppendingPathExtension: type]])
        {
            return [textures objectForKey: [textureName stringByAppendingPathExtension: type]];
        }
        
        path = [path stringByAppendingPathComponent: [textureName stringByAppendingPathExtension: type]];
        //NSLog(@"Loading %@", path);
        if ([[NSFileManager defaultManager] fileExistsAtPath: path])
        {
            //NSLog(@"Found texture.");
            
            @try
            {
                texture = [[SPTexture alloc] initWithContentsOfFile: path];
            }
            @catch (NSException *e) {
                NSLog(@"Error loading texture: %@", e);
            }
            
            if (autocache)
            {
                if (!textures)
                    textures = [NSMutableDictionary dictionary];
                
                [textures setObject: texture forKey: [textureName stringByAppendingPathExtension: type]];
            }
        }
        else
        {
            //NSLog(@"Texture %@/%@.%@ does not exist!", path, textureName, type);
            return nil;
        }
    }
    
    return texture;
}

#pragma mark Sounds

+ (SPSound *)getSound:(NSString *)soundName
{
    return [self getSound:soundName ofType: @"caf"];
}

+ (SPSound *)getSound:(NSString *)soundName ofType: (NSString *) type
{
    @autoreleasepool
    {
        //NSLog(@"Loading %@", textureName);
        
        //Check and see if we've already loaded that audio. If so, just return the texture.
        if ([sounds objectForKey: [soundName stringByAppendingPathExtension: type]])
        {
            return [sounds objectForKey: [soundName stringByAppendingPathExtension: type]];
        }
        
        if ([[NSFileManager defaultManager] fileExistsAtPath: [[NSBundle mainBundle] pathForResource: soundName ofType: type]])
        {
            sound = [[SPSound alloc] initWithContentsOfFile: [soundName stringByAppendingPathExtension: type]];
            
            if (autocache)
            {
                if (!sounds)
                    sounds = [NSMutableDictionary dictionary];
                
                if (sound)
                    [sounds setObject: sound forKey: [soundName stringByAppendingPathExtension: type]];
            }
        }
        else
        {
            NSLog(@"Sound file %@.%@ does not exist!", soundName, type);
        }
    }
    
    return sound;
}

//Empties the texture cache.
+ (void) flushCache
{
    textures = [NSMutableDictionary dictionary];
    sounds = [NSMutableDictionary dictionary];
}

#pragma mark Texture Atlas

+ (void)initAtlas
{
    if (!atlas)
        atlas = [[SPTextureAtlas alloc] initWithContentsOfFile:@"atlas.xml"];
}

+ (void)releaseAtlas
{
    atlas = nil;
}

+ (SPTexture *)atlasTexture:(NSString *)name
{
    if (!atlas) [self initAtlas];
    return [atlas textureByName:name];
}

+ (NSArray *)atlasTexturesWithPrefix:(NSString *)prefix
{
    if (!atlas) [self initAtlas];
    return [atlas texturesStartingWith:prefix];
}

+ (void)initSound
{
    if (sounds) return;
    
    [SPAudioEngine start];
    sounds = [[NSMutableDictionary alloc] init];
    
    // enumerate all sounds
    
    NSString *soundDir = [[NSBundle mainBundle] resourcePath];    
    NSDirectoryEnumerator *dirEnum = [[NSFileManager defaultManager] enumeratorAtPath:soundDir];   
    
    NSString *filename;
    while (filename = [dirEnum nextObject]) 
    {
        if ([[filename pathExtension] isEqualToString: @"caf"])
        {
            SPSound *sound = [[SPSound alloc] initWithContentsOfFile:filename];            
            [sounds setObject:sound forKey:filename];
        }
    }
}

+ (void)releaseSound
{
    sounds = nil;
    
    [SPAudioEngine stop];    
}

#pragma mark Play Sounds

+ (void)playSound:(NSString *)soundName
{
    [MToolsMedia playSound: soundName ofType: @"caf"];
}

+ (void)playSound: (NSString *) soundName ofType: (NSString *) type
{
    SPSound *sound = [sounds objectForKey:soundName];
    
    if (sound)
        [sound play];
    else
    {
        sound = [MToolsMedia getSound: soundName ofType: type];
        
        if (sound)
            [sound play];
    }
}

+ (SPSoundChannel *)soundChannel:(NSString *)soundName
{
    SPSound *sound = [sounds objectForKey:soundName];
    
    // sound was not preloaded
    if (!sound)        
        sound = [SPSound soundWithContentsOfFile:soundName];
    
    return [sound createChannel];
}

@end
