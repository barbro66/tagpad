//
//  Study.m
//  TagPad
//
//  Created by Malcolm Hall on 07/05/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Study.h"
#import "NSString+UUID.h"
#import "Subject.h"

@implementation Study
@synthesize identifier = _identifier;

- (id)initWithIdentifier:(NSString*)identifier {
    self = [super init];
    if (self) {
        self.identifier = identifier;
    }
    return self;
}
+(NSArray*)studies{
    
    NSArray *searchPaths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsPath = [searchPaths objectAtIndex: 0]; 
    
    NSError* error = nil;
    NSArray* filesArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsPath error:&error];
    if(error != nil) {
        NSLog(@"Error in reading files: %@", [error localizedDescription]);
        return;
    }
    
    // sort by creation date
    NSMutableArray* filesAndProperties = [NSMutableArray arrayWithCapacity:[filesArray count]];
    for(NSString* file in filesArray) {
        NSString* filePath = [documentsPath stringByAppendingPathComponent:file];
        NSDictionary* properties = [[NSFileManager defaultManager]
                                    attributesOfItemAtPath:filePath
                                    error:&error];
        NSDate* modDate = [properties objectForKey:NSFileModificationDate];
        
        if(error == nil)
        {
            [filesAndProperties addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                           file, @"path",
                                           modDate, @"lastModDate",
                                           nil]];                 
        }
    }
    
    // sort using a block
    // order inverted as we want latest date first
    NSArray* sortedFiles = [filesAndProperties sortedArrayUsingComparator:
                            ^(id path1, id path2)
                            {                               
                                // compare 
                                NSComparisonResult comp = [[path1 objectForKey:@"lastModDate"] compare:
                                                           [path2 objectForKey:@"lastModDate"]];
                                // invert ordering
                                if (comp == NSOrderedDescending) {
                                    comp = NSOrderedAscending;
                                }
                                else if(comp == NSOrderedAscending){
                                    comp = NSOrderedDescending;
                                }
                                return comp;                                
                            }];
    
    /*
     NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
     NSString* documentsDirectory = [paths objectAtIndex:0];
     NSArray* contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:nil];
     //return contents;
     */
    NSMutableArray* results = [NSMutableArray array];
	for(NSDictionary* s in sortedFiles){
        if([[s objectForKey:@"path"] hasPrefix:@"."])
            continue;
		//NSString* path = [[self documentsDirectory] stringByAppendingPathComponent:s];
        Study* study = [[[Study alloc] initWithIdentifier:[s objectForKey:@"path"]] autorelease];
        [results addObject:study];
	}
    return results;
    
}

+(BOOL)createStudyFromFile:(NSString*)file title:(NSString*)title dropboxPath:(NSString*)dropboxPath{
    NSError *error = nil;
    NSStringEncoding encoding;
    NSString *contents = [NSString stringWithContentsOfFile:file usedEncoding:&encoding error:&error];
    if (error != nil) {
        error=nil;
        contents = [NSString stringWithContentsOfFile:file encoding: NSWindowsCP1252StringEncoding error:&error];        
        if (error != nil) {
            // error;
            return NO;
        }
    }
    
    // Fix stupid word linefeed nonsence
    contents=[contents stringByReplacingOccurrencesOfString:@"\r\n" withString:@"\n"];
    contents=[contents stringByReplacingOccurrencesOfString:@"\r" withString:@"\n"];
    
    //	viewer.text = contents;
    NSArray* sectionLines = [contents componentsSeparatedByString:@"\n\n\n"];
    
    NSMutableDictionary* study = [NSMutableDictionary dictionary];
    //[study setObject:@"test" forKey:@"title"];
    [study setObject:title forKey:@"title"];
    [study setObject:[NSNumber numberWithInt:0] forKey:@"lastSubjectIncrement"];
    [study setObject:[dropboxPath stringByDeletingLastPathComponent] forKey:@"dropboxPath"];
    
    NSMutableArray* sections = [NSMutableArray array];
    
    for(NSString* sectionLine in sectionLines){
        NSMutableDictionary* section = [NSMutableDictionary dictionary];
        NSMutableArray* questions = [NSMutableArray array];
        NSArray* questionLines = [sectionLine componentsSeparatedByString:@"\n"];
        for(int i=0;i<[questionLines count];i++){
            NSString* line = [questionLines objectAtIndex:i];
            if(i == 0){
                //first line is section heading
                [section setObject:line forKey:@"title"];
            }else{
                NSArray* arr = [line componentsSeparatedByString:@"|"];
                if([arr count] == 0){
                    [questions addObject:[NSDictionary dictionaryWithObject:line forKey:@"question"]];
                }
                else{
                    if([line isEqualToString:@""]){
                        continue;
                    }
                    NSMutableArray* choices = [NSMutableArray arrayWithArray:arr];
                    //remove the question
                    NSString* q = [choices objectAtIndex:0];
                    [choices removeObjectAtIndex:0];
                    [questions addObject:[NSDictionary dictionaryWithObjectsAndKeys:q,@"question", 
                                          choices,@"choices", nil]];
                }
            }
        }
        [section setObject:questions forKey:@"questions"];
        [sections addObject:section];
    }
    [study setObject:sections forKey:@"sections"];
    
    if ([sections count]==0) return NO;
    if ([[[sections objectAtIndex:0] objectForKey:@"questions"] count]==0) return NO;    
    
    //create the package
    NSString* studyId = [NSString stringWithUUID];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = [paths objectAtIndex:0];
    NSString* path = [documentsDirectory stringByAppendingPathComponent:studyId];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:nil];
    [study writeToFile:[path stringByAppendingPathComponent:@"Study.plist"] atomically:NO];
    
    //create subjects
    NSString* subjsDir = [path stringByAppendingPathComponent:@"Subjects"];
    [[NSFileManager defaultManager] createDirectoryAtPath:subjsDir withIntermediateDirectories:NO attributes:nil error:nil];
    //create the first subject
    Study* study1 = [[[Study alloc] initWithIdentifier:studyId] autorelease];
    [study1 createSubject];
    
    
    return YES;
}


-(NSString*)documentsDirectory{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}


-(void)remove{
    [[NSFileManager defaultManager] removeItemAtPath:[[self documentsDirectory] stringByAppendingPathComponent:self.identifier] error:nil];
}

-(void)saveScreenshot:(UIImage*)image{
    NSString* path = [[[self documentsDirectory] stringByAppendingPathComponent:self.identifier] stringByAppendingPathComponent:@"Default.png"];
    NSData* png = UIImagePNGRepresentation(image);
    [png writeToFile:path atomically:NO];
}

-(UIImage*)screenshot{
    NSString* path = [[[self documentsDirectory] stringByAppendingPathComponent:self.identifier] stringByAppendingPathComponent:@"Default.png"];
    return [UIImage imageWithContentsOfFile:path];
}

-(NSMutableDictionary*)dictionary{
    NSString* path = [[[self documentsDirectory] stringByAppendingPathComponent:self.identifier] stringByAppendingPathComponent:@"Study.plist"];
    NSMutableDictionary* d=[NSMutableDictionary dictionaryWithContentsOfFile:path];
    if ([d objectForKey:@"uploadHistory"]==nil) {
        [d setObject:[NSMutableArray array] forKey:@"uploadHistory"];
    }
    return d;
}

-(void)setDictionary:(NSMutableDictionary*)dictionary{
    NSString* path = [[[self documentsDirectory] stringByAppendingPathComponent:self.identifier] stringByAppendingPathComponent:@"Study.plist"];
    [dictionary writeToFile:path atomically:NO];
}

-(NSMutableArray*)tags{
    NSString* path = [[[self documentsDirectory] stringByAppendingPathComponent:self.identifier] stringByAppendingPathComponent:@"tags.plist"];
    return [NSMutableArray arrayWithContentsOfFile:path];
}

-(void)setTags:(NSMutableArray*)tags{
    NSString* path = [[[self documentsDirectory] stringByAppendingPathComponent:self.identifier] stringByAppendingPathComponent:@"tags.plist"];
    [tags writeToFile:path atomically:NO];
}

-(NSArray*)subjects{
    NSString* subjDir = [[[self documentsDirectory] stringByAppendingPathComponent:self.identifier] stringByAppendingPathComponent:@"Subjects"];
    NSArray* contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:subjDir error:nil];
    //  return contents;
    
    NSMutableArray* results = [NSMutableArray array];
    for(NSString* s in contents){
        if([s hasPrefix:@"."]){
            continue;
        }
        Subject* subject = [[[Subject alloc] initWithIdentifier:s study:self] autorelease];
        [results addObject:subject];
    }
    return results;
    
}

//gathers the subject info out of each dir and builds an array
-(NSArray*)subjectDictionaries{
    NSString* subjDir = [[[self documentsDirectory] stringByAppendingPathComponent:self.identifier] stringByAppendingPathComponent:@"Subjects"];
    NSArray* contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:subjDir error:nil];
    NSMutableArray* results = [NSMutableArray array];
    for(NSString* s in contents){
        if([s hasPrefix:@"."])
            continue;
        NSString* path = [subjDir stringByAppendingPathComponent:s];
        NSDictionary* d = [NSDictionary dictionaryWithContentsOfFile:[path stringByAppendingPathComponent:@"Subject.plist"]];
        [results addObject:d];
    }
    return results;
}

-(Subject*)createSubject{
    NSString* subjDir = [[[self documentsDirectory] stringByAppendingPathComponent:self.identifier] stringByAppendingPathComponent:@"Subjects"];
    NSString* subjectFolder = [NSString stringWithUUID];
    subjDir = [subjDir stringByAppendingPathComponent:subjectFolder];
    [[NSFileManager defaultManager] createDirectoryAtPath:subjDir withIntermediateDirectories:NO attributes:nil error:nil];
    
    //inc subject id
    NSMutableDictionary* studyDict = [self dictionary];
    int i = [[studyDict objectForKey:@"lastSubjectIncrement"] intValue];
    i++;
    [studyDict setObject:[NSNumber numberWithInt:i] forKey:@"lastSubjectIncrement"];
    [self setDictionary:studyDict];
    
    NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:@"", @"name",
                          @"",@"info",
                          [NSNumber numberWithInt:i],@"increment",
                          subjectFolder,@"folder",
                          nil];
    [dict writeToFile:[subjDir stringByAppendingPathComponent:@"Subject.plist"] atomically:NO];
    Subject* subject = [[[Subject alloc] initWithIdentifier:subjectFolder study:self] autorelease];
    return subject;
}

-(void)setDictionary:(NSDictionary*)dictionary subject:(NSString*)subject{
    NSString* s = [[self documentsDirectory] stringByAppendingPathComponent:self.identifier];
    s = [s stringByAppendingPathComponent:@"Subjects"];
    s = [s stringByAppendingPathComponent:subject];
    s = [s stringByAppendingPathComponent:@"Subject.plist"];
    [dictionary writeToFile:s atomically:NO];
}

- (void)dealloc {
    self.identifier = nil;
    [super dealloc];
}


@end
