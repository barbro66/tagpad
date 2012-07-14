//
//  AudioSplitter.m
//  TagPad
//
//  Created by Malcolm Hall on 21/04/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AudioJoiner.h"

@implementation AudioJoiner

@synthesize firstFile = _firstFile;
@synthesize secondFile = _secondFile;


@synthesize delegate;

- (id)initWithFirstFile:(NSURL*)firstFile secondFile:(NSURL*)secondFile delegate:(id)d{
   self = [super init];
    if (self) {
		self.firstFile = firstFile;
        self.secondFile = secondFile;
        self.delegate = d;
		
        [self _join];
    }
    return self;
}

- (void)_join{
	
	NSLog(@"AudioJoiner: join");
    [self retain];
    //create composition track
    AVMutableComposition *saveComposition = [AVMutableComposition composition];
    
    AVMutableCompositionTrack *compositionAudioTrack = [saveComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    //Set up the sound as an asset
    NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset* firstFileAsset = [AVURLAsset URLAssetWithURL:self.firstFile options:options];
    AVURLAsset* secondFileAsset = [AVURLAsset URLAssetWithURL:self.secondFile options:options]; 
    
    //get the 2 tracks
    AVAssetTrack *clipAudioTrack = [firstFileAsset compatibleTrackForCompositionTrack:compositionAudioTrack];
    AVAssetTrack *clipAudioTrack2 = [secondFileAsset compatibleTrackForCompositionTrack:compositionAudioTrack];
    
   // AVAssetTrack *clipAudioTrack = [firstFileAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
    //AVAssetTrack *clipAudioTrack2 = [[secondFileAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
    
    //add the first track and then the second after it in time.
    [compositionAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, [firstFileAsset duration]) ofTrack:clipAudioTrack atTime:kCMTimeZero error:nil];
    
    [compositionAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, [secondFileAsset duration]) ofTrack:clipAudioTrack2 atTime:[firstFileAsset duration] error:nil];
    
    //AVAudioMix
    
    //export the new track using the attributes like 1 channel etc of the first asset
	NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:saveComposition];
    NSLog(@"%@",compatiblePresets);
//	if ([compatiblePresets containsObject:AVAssetExportPresetAppleM4A]) {
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]
                                           initWithAsset:saveComposition presetName:AVAssetExportPresetPassthrough];
    
    NSLog (@"created exporter. supportedFileTypes: %@", exportSession.supportedFileTypes);

    NSString *soundFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent: @"audioJoined.mov"];
    NSLog(@"%@",soundFilePath);
    NSURL *url = [NSURL fileURLWithPath:soundFilePath];
    exportSession.outputURL = url;
    
    //delete the temp file if it exists
    [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
    
    exportSession.outputFileType = AVFileTypeQuickTimeMovie;

    NSLog(@"AudioJoiner: export async");
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        switch ([exportSession status]) {
            case AVAssetExportSessionStatusFailed:
                NSLog(@"AudioJoiner: Join Failed: %@", [[exportSession error] localizedDescription]);
                break;
            case AVAssetExportSessionStatusCancelled:
                NSLog(@"AudioJoiner: Join Canceled");
                break;
            default:
                NSLog(@"AudioJoiner: Join Complete");
                [self performSelectorOnMainThread:@selector(_convert:) withObject:url waitUntilDone:NO];
                break;
        }
        [exportSession release];
    }];
	
		//self.trimmedSoundFileURL = trimmedURL;
        //NSLog(@"%@", trimmedURL);
        
/*	}else{
        NSLog(@"Wasn't there");
    }
 */
}


- (void)_convert:(NSURL*)joinedUrl{
	NSLog(@"AudioJoiner: convert");
    
     NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset* firstFileAsset = [AVURLAsset URLAssetWithURL:joinedUrl options:options];
    
    //AVAudioMix
    
	NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:firstFileAsset];
    NSLog(@"%@",compatiblePresets);
    //	if ([compatiblePresets containsObject:AVAssetExportPresetAppleM4A]) {
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]
                                           initWithAsset:firstFileAsset presetName:AVAssetExportPresetAppleM4A];
    
    NSLog (@"created exporter. supportedFileTypes: %@", exportSession.supportedFileTypes);
    
    NSString *soundFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent: @"audioJoined.m4a"];
    NSLog(@"%@",soundFilePath);
    NSURL *url = [NSURL fileURLWithPath:soundFilePath];
    exportSession.outputURL = url;
    
    [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
    
    exportSession.outputFileType = AVFileTypeAppleM4A;
    
    NSLog(@"AudioJoiner: export async");
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        switch ([exportSession status]) {
            case AVAssetExportSessionStatusFailed:
                NSLog(@"AudioJoiner: Join Failed: %@", [[exportSession error] localizedDescription]);
                break;
            case AVAssetExportSessionStatusCancelled:
                NSLog(@"AudioJoiner: Join Canceled");
                break;
            default:
                NSLog(@"AudioJoiner: Join Complete");
                if([self.delegate respondsToSelector:@selector(audioJoinerDidFinish:joinedFile:)]){
                    [self performSelectorOnMainThread:@selector(completed:) withObject:soundFilePath waitUntilDone:NO];
                }
                break;
        }
        [exportSession release];
    }];
	
    //self.trimmedSoundFileURL = trimmedURL;
    //NSLog(@"%@", trimmedURL);
    
    /*	}else{
     NSLog(@"Wasn't there");
     }
     */
}

-(void)completed:(NSString*)soundFilePath{
    [self.delegate audioJoinerDidFinish:self joinedFile:soundFilePath];
    [self release];
}

- (void)dealloc {
    self.firstFile = nil;
    self.secondFile = nil;
    [super dealloc];
}
@end
