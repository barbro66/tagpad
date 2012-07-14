//
//  AudioJoiner.h
//  TagPad
//
//  Created by Malcolm Hall on 21/04/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AudioJoiner : NSObject {

	NSURL *_firstFile;
	NSURL *_secondFile;

	NSTimer *updateTimer;
    id delegate;
    NSTimeInterval start;
    NSTimeInterval end;
    BOOL wait;
}

@property (assign) id delegate;
@property (readwrite, retain) NSURL *firstFile;
@property (readwrite, retain) NSURL *secondFile;


//joins the 2 files together into the first filename and deletes the second.
- (id)initWithFirstFile:(NSURL*)firstFile secondFile:(NSURL*)secondFile delegate:(id)delegate;
- (void)_join;
- (void)_convert:(NSURL*)url;
@end


@interface NSObject (AudioJoinerDelegate)

- (void)audioJoinerDidFinish:(AudioJoiner *)audioJoiner joinedFile:(NSString*)joinedFile;
- (void)audioJoiner:(AudioJoiner *)audioJoiner didFailWithError:(NSError *)error;

@end