//
//  MToolsAudioManager.h
//  AppScaffold
//
//  Created by Marshall on 11/09/2012.
//
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "MToolsRecorder.h"

@interface MToolsAudioManager : NSObject
{
    AVAudioRecorder *recorder;
    MToolsRecorder *recorderQueue;
    NSTimer *levelTimer;
    double lowPassResults;
}

+ (MToolsAudioManager *) sharedManager;

- (void) beginRecordingWithMetering: (bool) metering;
- (float)getAveragePowerLevelForChannel: (NSInteger) channel;
- (float)getPeakPowerLevelForChannel: (NSInteger) channel;

@end
