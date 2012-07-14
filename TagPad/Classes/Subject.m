//
//  Subject.m
//  TagPad
//
//  Created by Malcolm Hall on 07/05/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Subject.h"
#import "Study.h"

@implementation Subject
@synthesize identifier = _identifier;
@synthesize study = _study;
@synthesize dictionary;

- (id)initWithIdentifier:(NSString*)identifier study:(Study*)study{
    self = [super init];
    if (self) {
        self.identifier = identifier;
        self.study = study;
    }
    return self;
}

-(NSString*)codename{
    NSDictionary* d = self.dictionary;
    NSString* s = [[d objectForKey:@"increment"] stringValue];
    NSString* title = [self.study.dictionary objectForKey:@"title"];
    return [title stringByAppendingString:s];
}

-(NSString*)displayName{
    NSString* name = [[self dictionary] objectForKey:@"name"];
    if(!name || [name length] == 0){
        name = [self codename];
    }
    return name;
}


-(NSMutableDictionary*)dictionary{
    NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithContentsOfFile:[[self directory] stringByAppendingPathComponent:@"Subject.plist"]];
    return dict;
}

-(void)setDictionary:(NSMutableDictionary*)d{
    [d writeToFile:[[self directory] stringByAppendingPathComponent:@"Subject.plist"] atomically:NO];
}

-(double)durationPerPixel{
    return (double)890 / [self recordingDuration];
}

-(NSTimeInterval)recordingDuration{
    return [[self.dictionary objectForKey:@"recordingDuration"] doubleValue];
}

-(void)setRecordingDuration:(NSTimeInterval)recordingDuration{
    NSMutableDictionary* dict = self.dictionary;
    [dict setObject:[NSNumber numberWithDouble:recordingDuration] forKey:@"recordingDuration"];
    [self setDictionary:dict];
}

-(NSString*)audioFile{
   return [[self directory] stringByAppendingPathComponent:@"audio.m4a"];
}

-(NSArray*)stamps{
    return [NSArray arrayWithContentsOfFile:[[self directory] stringByAppendingPathComponent:@"stamps.plist"]];
}

-(void)setStamps:(NSArray *)stamps{
    [stamps writeToFile:[[self directory] stringByAppendingPathComponent:@"stamps.plist"] atomically:NO];
}

-(NSMutableArray*)tags{
    return [NSMutableArray arrayWithContentsOfFile:[[self directory] stringByAppendingPathComponent:@"tags.plist"]];
}

-(void)setTags:(NSMutableArray *)tags{
    [tags writeToFile:[[self directory] stringByAppendingPathComponent:@"tags.plist"] atomically:NO];
}

-(NSMutableDictionary*)answers{
    return [NSMutableDictionary dictionaryWithContentsOfFile:[[self directory] stringByAppendingPathComponent:@"answers.plist"]];
}

-(void)setAnswers:(NSMutableDictionary *)answers{
    [answers writeToFile:[[self directory] stringByAppendingPathComponent:@"answers.plist"] atomically:NO];
}

-(NSString*)directory{
    NSString* subjDir = [[[self documentsDirectory] stringByAppendingPathComponent:self.study.identifier] stringByAppendingPathComponent:@"Subjects"];
// self.displayName
    subjDir = [subjDir stringByAppendingPathComponent:self.identifier];
    return subjDir;
}

-(NSString*)documentsDirectory{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

-(void)remove{
    [[NSFileManager defaultManager] removeItemAtPath:[self directory] error:nil];
}

- (void)dealloc {
    self.study = nil;
    self.identifier = nil;
    [super dealloc];
}
@end
