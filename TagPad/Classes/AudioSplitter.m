//
//  AudioSplitter.m
//  TagPad
//
//  Created by Malcolm Hall on 21/04/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AudioSplitter.h"

@implementation AudioSplitter

@synthesize soundFileURL;
@synthesize trimmedSoundFileURL;
@synthesize soundPlayer;
@synthesize soundFileAsset;
@synthesize delegate;

- (id)initWithSoundFileURL:(NSURL*)url destination:(NSURL*)dest start:(NSTimeInterval)s end:(NSTimeInterval)e delegate:(id)d{
    self = [super init];
    if (self) {
		self.soundFileURL = url;
		start = s;
        end = e;
        self.trimmedSoundFileURL = dest;
        self.delegate = d;
		//Set up the sound as an asset
		NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
		self.soundFileAsset = [AVURLAsset URLAssetWithURL:self.soundFileURL options:options];
		
		//Start Calculating the Duration
		NSArray *keys = [NSArray arrayWithObject:@"duration"];
		[self.soundFileAsset loadValuesAsynchronouslyForKeys:keys completionHandler:^(void) {
			NSError *error = nil;
			AVKeyValueStatus durationStatus = [self.soundFileAsset statusOfValueForKey:@"duration" error:&error];
			switch (durationStatus) {
				case AVKeyValueStatusLoaded:
					soundFileDuration = [self.soundFileAsset duration];
					NSLog(@"Duration Loaded: %f Seconds", CMTimeGetSeconds(soundFileDuration));
					[self calculateTrimmedAudio];
					break;
				case AVKeyValueStatusFailed:
					NSLog(@"ERROR Loading Asset");
					break;
				case AVKeyValueStatusCancelled:
					// Do whatever is appropriate for cancelation.
                    break;
			}
		}];
        
		audioAsArray = [[NSMutableArray alloc]initWithCapacity:10];
    }
    return self;
}

-(CMTimeRange)trimmedTimeRange {
	Float64 startTimeInSeconds = start;// [self secondsForXPosition: trimInBar.frame.origin.x + trimInBar.frame.size.width];
	Float64 endTimeInSeconds = end;//[self secondsForXPosition:trimOutBar.frame.origin.x];
	Float64 durationInSeconds = endTimeInSeconds - startTimeInSeconds;
	
	CMTime start = CMTimeMakeWithSeconds(startTimeInSeconds, 600);
	CMTime duration = CMTimeMakeWithSeconds(durationInSeconds, 600);
	return CMTimeRangeMake(start, duration);
	
}

- (void)calculateTrimmedAudio{
	
	NSLog(@"AudioTrimmerVC: calculateTrimmedAudio");
	
	NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:self.soundFileAsset];
	if ([compatiblePresets containsObject:AVAssetExportPresetAppleM4A]) {
		AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]
											   initWithAsset:self.soundFileAsset presetName:AVAssetExportPresetAppleM4A];
		
		
		//NSString *soundFilePath = [NSTemporaryDirectory ()
		//						   stringByAppendingPathComponent: @"audio.m4a"];
		
		//NSURL *trimmedURL = [[NSURL alloc] initFileURLWithPath: soundFilePath];
		exportSession.outputURL = trimmedSoundFileURL;
		
		[[NSFileManager defaultManager] removeItemAtURL:trimmedSoundFileURL error:nil];
		
		exportSession.outputFileType = @"com.apple.m4a-audio";
		
		exportSession.timeRange = [self trimmedTimeRange];
		
		[exportSession exportAsynchronouslyWithCompletionHandler:^{
			switch ([exportSession status]) {
				case AVAssetExportSessionStatusFailed:
					NSLog(@"AudioTrimmerVC: Calculating Trim Failed: %@", [[exportSession error] localizedDescription]);
					break;
				case AVAssetExportSessionStatusCancelled:
					NSLog(@"AudioTrimmerVC: Calculating Trim Canceled");
					break;
				default:
					NSLog(@"AudioTrimmerVC: Calculating Trim Complete");
                    if([self.delegate respondsToSelector:@selector(audioSplitterDidFinish:splitFile:)]){
                        [self.delegate audioSplitterDidFinish:self splitFile:trimmedSoundFileURL];
                    }
					//[self updateButtonsForCurrentMode];
					break;
			}
			[exportSession release];
		}];
		
		//self.trimmedSoundFileURL = trimmedURL;
        //NSLog(@"%@", trimmedURL);
	}
	
}

- (void)dealloc {
    self.soundFileURL = nil;
    self.trimmedSoundFileURL = nil;
    [super dealloc];
}
@end
