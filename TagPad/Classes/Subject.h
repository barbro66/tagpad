//
//  Subject.h
//  TagPad
//
//  Created by Malcolm Hall on 07/05/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Study;

@interface Subject : NSObject {
    NSString* _identifier;
    Study* _study;
}
@property (copy) NSString* identifier;
@property (retain) Study* study;
@property (assign) NSMutableDictionary* dictionary;
@property (readonly) NSString* audioFile;
@property (assign) NSArray* stamps;
@property (assign) NSMutableArray* tags;
@property (assign) NSMutableDictionary* answers;
@property (readonly) NSString* codename;
@property (assign) NSTimeInterval recordingDuration;
@property (readonly) double durationPerPixel;

- (id)initWithIdentifier:(NSString*)identifier study:(Study*)study;
-(NSString*)audioFile;
-(NSString*)documentsDirectory;
-(NSString*)directory;
-(void)remove;
-(NSString*)displayName;

@end
