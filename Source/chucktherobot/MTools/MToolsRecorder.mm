//
//  MToolsRecorder.m
//  AppScaffold
//
//  Created by Marshall on 13/09/2012.
//
//

#import "MToolsRecorder.h"

#define DBOFFSET -74.0 

@implementation MToolsRecorder

#define AUDIO_DATA_TYPE_FORMAT SInt16

- (id) init
{
    if (self = [super init])
    {
        previousLevel = 0.00f;
        
        recordState.dataFormat.mSampleRate = 8000.0;
        recordState.dataFormat.mFormatID = kAudioFormatLinearPCM;
        recordState.dataFormat.mFramesPerPacket = 1;
        recordState.dataFormat.mChannelsPerFrame = 1;
        recordState.dataFormat.mBytesPerFrame = 2;
        recordState.dataFormat.mBytesPerPacket = 2;
        recordState.dataFormat.mBitsPerChannel = 16;
        recordState.dataFormat.mReserved = 0;
        recordState.dataFormat.mFormatFlags =
        kLinearPCMFormatFlagIsBigEndian |
        kLinearPCMFormatFlagIsSignedInteger |
        kLinearPCMFormatFlagIsPacked;
        
        AudioQueueNewInput(
                                             &recordState.dataFormat, // 1
                                             AudioInputCallback, // 2
                                             &recordState,  // 3
                                             CFRunLoopGetCurrent(),  // 4
                                             kCFRunLoopCommonModes, // 5
                                             0,  // 6
                                             &recordState.queue);  // 7
        
        for(int i = 0; i < NUM_BUFFERS; i++)
        {
            AudioQueueAllocateBuffer(recordState.queue,
                                     16000, &recordState.buffers[i]);
            AudioQueueEnqueueBuffer(recordState.queue,
                                    recordState.buffers[i], 0, NULL);
        }
        
        char path[256];
        [self getFilename:path maxLenth:sizeof path];
        fileURL = CFURLCreateFromFileSystemRepresentation(NULL, (UInt8*)path, strlen(path), false);
        [self startRecording];
    }
    
    return self;
}

- (void)setupAudioFormat:(AudioStreamBasicDescription*)format
{
	format->mSampleRate = 8000.0;
	format->mFormatID = kAudioFormatLinearPCM;
	format->mFramesPerPacket = 1;
	format->mChannelsPerFrame = 1;
	format->mBytesPerFrame = 2;
	format->mBytesPerPacket = 2;
	format->mBitsPerChannel = 16;
	format->mReserved = 0;
	format->mFormatFlags = kLinearPCMFormatFlagIsBigEndian |
    kLinearPCMFormatFlagIsSignedInteger |
    kLinearPCMFormatFlagIsPacked;
}

void AudioInputCallback(
                        void *inUserData,
                        AudioQueueRef inAQ,
                        AudioQueueBufferRef inBuffer,
                        const AudioTimeStamp *inStartTime,
                        UInt32 inNumberPacketDescriptions,
                        const AudioStreamPacketDescription *inPacketDescs)
{
    RecordState* recordState = (RecordState*)inUserData;
    
    //NSLog(@"Writing buffer %lld", recordState->currentPacket);
    OSStatus status = AudioFileWritePackets(recordState->audioFile,
                                            false,
                                            inBuffer->mAudioDataByteSize,
                                            inPacketDescs,
                                            recordState->currentPacket,
                                            &inNumberPacketDescriptions,
                                            inBuffer->mAudioData);
    
    if(status == 0)
    {
        recordState->currentPacket += inNumberPacketDescriptions;
    }
    
    AudioQueueEnqueueBuffer(recordState->queue, inBuffer, 0, NULL);
}

- (void)startRecording
{
    [self setupAudioFormat:&recordState.dataFormat];
    
    recordState.currentPacket = 0;
    
    OSStatus status;
    status = AudioQueueNewInput(&recordState.dataFormat,
                                AudioInputCallback,
                                &recordState,
                                CFRunLoopGetCurrent(),
                                kCFRunLoopCommonModes,
                                0,
                                &recordState.queue);
    
    if(status == 0)
    {
        for(int i = 0; i < NUM_BUFFERS; i++)
        {
            AudioQueueAllocateBuffer(recordState.queue,
                                     16000, &recordState.buffers[i]);
            AudioQueueEnqueueBuffer(recordState.queue,
                                    recordState.buffers[i], 0, NULL);
        }
        
        OSStatus status = AudioFileCreateWithURL(fileURL,
                                        kAudioFileAIFFType,
                                        &recordState.dataFormat,
                                        kAudioFileFlags_EraseFile,
                                        &recordState.audioFile);
        if(status == 0)
        {
            UInt32 trueValue = true;
            AudioQueueSetProperty(recordState.queue, kAudioQueueProperty_EnableLevelMetering, &trueValue, sizeof (UInt32));
            
            recordState.recording = true;
            status = AudioQueueStart(recordState.queue, NULL);
            if(status == 0)
            {
                NSLog(@"Recording");
            }
        }
    }
    
    if(status != 0)
    {
        NSLog(@"Record Failed");
    }
}

- (BOOL)getFilename:(char*)buffer maxLenth:(int)maxBufferLength
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString* docDir = [paths objectAtIndex:0];
    NSString* file = [docDir stringByAppendingString:@"/recording.aif"];
    return [file getCString:buffer maxLength:maxBufferLength encoding:NSUTF8StringEncoding];
}

- (float)getAveragePowerLevelForChannel: (NSInteger) channel
{
    UInt32 dataSize = sizeof(AudioQueueLevelMeterState) *recordState.dataFormat.mChannelsPerFrame;
    AudioQueueLevelMeterState *levels = (AudioQueueLevelMeterState *)malloc(dataSize);
    AudioQueueGetProperty(recordState.queue, kAudioQueueProperty_CurrentLevelMeterDB, levels, &dataSize);
    
    if (previousLevel > levels[0].mAveragePower + 0.25)
    {
        decay += 15;
    }
    else
    {
        decay -= 10;
    }
    
    if (decay < 0)
    {
        decay = 0;
    }
    else if (decay > 50)
    {
        decay = 50;
    }
    
    previousLevel = levels[0].mAveragePower;
    free(levels);
    
    return previousLevel - decay;
}

@end
