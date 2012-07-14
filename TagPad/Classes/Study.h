//
//  Study.h
//  TagPad
//
//  Created by Malcolm Hall on 07/05/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


@class Subject;

@interface Study : NSObject {
    NSString* _identifier;
}
@property (copy) NSString* identifier;
@property (assign) NSMutableDictionary* dictionary;
@property (assign) NSMutableArray* tags;
//static
+(NSArray*)studies;
+(BOOL)createStudyFromFile:(NSString*)file title:(NSString*)title dropboxPath:(NSString*)dropboxPath;

//instance
-(NSString*)documentsDirectory;

-(void)remove;

-(NSArray*)subjects;
-(Subject*)createSubject;
-(NSMutableDictionary*)dictionaryForSubject:(NSString*)subject;


-(void)saveScreenshot:(UIImage*)image;
-(UIImage*)screenshot;


-(void)setDictionary:(NSDictionary*)dictionary subject:(NSString*)subject;

@end
