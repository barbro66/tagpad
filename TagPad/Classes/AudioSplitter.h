//
//  AudioSplitter.h
//  TagPad
//
//  Created by Malcolm Hall on 21/04/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AudioSplitter : NSObject {
	NSMutableArray *audioAsArray;
	NSURL *soundFileURL;
	NSURL *trimmedSoundFileURL;
	AVURLAsset *soundFileAsset;
	CMTime soundFileDuration;
	AVAudioPlayer *soundPlayer;
	NSTimer *updateTimer;
    id delegate;
    NSTimeInterval start;
    NSTimeInterval end;
}

@property (assign) id delegate;
@property (readwrite, retain) NSURL *soundFileURL;
@property (readwrite, retain) NSURL *trimmedSoundFileURL;
@property (readwrite, retain) AVURLAsset *soundFileAsset;
@property (readwrite, retain) AVAudioPlayer *soundPlayer;

- (id)initWithSoundFileURL:(NSURL*)url destination:(NSURL*)dest start:(NSTimeInterval)start end:(NSTimeInterval)end delegate:(id)delegate;
- (void)calculateTrimmedAudio;
@end


@interface NSObject (AudioSplitterDelegate)

- (void)audioSplitterDidFinish:(AudioSplitter *)audioSplitter splitFile:(NSURL*)splitFile;
- (void)audioSplitter:(AudioSplitter *)audioSplitter didFailWithError:(NSError *)error;

@end