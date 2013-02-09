//
//  MToolsAudioManager.m
//  AppScaffold
//
//  Created by Marshall on 11/09/2012.
//
//

#import "MToolsAudioManager.h"

@implementation MToolsAudioManager

//Singleton implementation.
static MToolsAudioManager *sharedManager = nil;

+ (MToolsAudioManager *) sharedManager
{
    if (!sharedManager)
    {
        sharedManager = [[MToolsAudioManager alloc] init];
    }
    return sharedManager;
}

- (id) init
{
    if (self = [super init])
    {
        NSURL *url = [NSURL fileURLWithPath: @"/dev/null"];
        
        NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithFloat: 44100.0],                 AVSampleRateKey,
            [NSNumber numberWithInt: kAudioFormatAppleLossless], AVFormatIDKey,
            [NSNumber numberWithInt: 1],                         AVNumberOfChannelsKey,
            [NSNumber numberWithInt: AVAudioQualityMax],         AVEncoderAudioQualityKey,
            nil];
        
        NSError *error;
        
        recorder = [[AVAudioRecorder alloc] initWithURL: url settings: settings error: &error];
        
        recorderQueue = [[MToolsRecorder alloc] init];
    }
    
    return self;
}

//Begins the recording process and determines if we're going to be metering that recording.
- (void) beginRecordingWithMetering: (bool) metering
{
    NSError *error;
    
    if (recorder)
    {
        [recorder prepareToRecord];
        recorder.meteringEnabled = metering;
        [recorder record];
        
        if (metering)
        {
            levelTimer = [NSTimer scheduledTimerWithTimeInterval: 0.03 target: self selector: @selector(levelTimerCallback:) userInfo: nil repeats: YES];
        }
    }
    else
  		NSLog(@"%@ says something went wrong: %@", self, error);
}

//Callback for the metering.
- (void)levelTimerCallback:(NSTimer *)timer
{
	[recorder updateMeters];
    
	const double ALPHA = 0.05;
	double peakPowerForChannel = pow(10, (0.05 * [recorder peakPowerForChannel:0]));
	lowPassResults = ALPHA * peakPowerForChannel + (1.0 - ALPHA) * lowPassResults;
    
	//NSLog(@"Average input: %f Peak input: %f Low pass results: %f", [recorder averagePowerForChannel:0], [recorder peakPowerForChannel:0], lowPassResults);
}

//Get the current power results
- (float)getAveragePowerLevelForChannel: (NSInteger) channel
{
    return [recorderQueue getAveragePowerLevelForChannel: 0];
}

//Get the peak power results.
- (float)getPeakPowerLevelForChannel: (NSInteger) channel
{
    return [recorder peakPowerForChannel: channel];
}

@end
