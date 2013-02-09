//
//  MToolsRecorder.h
//  AppScaffold
//
//  Created by Marshall on 13/09/2012.
//
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AudioToolbox/AudioFile.h>

#define NUM_BUFFERS 3

typedef struct
{
    AudioStreamBasicDescription dataFormat;
    AudioQueueRef queue;
    AudioQueueBufferRef buffers[NUM_BUFFERS];
    AudioFileID audioFile;
    SInt64 currentPacket;
    bool recording;
} RecordState;

@interface MToolsRecorder : NSObject
{
    RecordState recordState;
    CFURLRef fileURL;
    float previousLevel;
    float decay;
}

- (float)getAveragePowerLevelForChannel: (NSInteger) channel;

@end
