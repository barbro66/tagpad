//
//  Copyright (c) 2010 Nuclear Elements, Inc. http://nuclearelements.com/
//  The above line must remain intact. And this use of this source code is subject to the terms in LICENSE.txt
//

#import "NebulousSaveAs.h"
#import "NebulousController.h"
#import "NebulousStyle.h"

@implementation NebulousSaveAs

@synthesize fileName;
@synthesize localPath;
@synthesize destFolder;
@synthesize saving;

- (id) init {
	if (self = [super init]) {
		delegates = [[NSMutableArray alloc] init];
		active = YES;
	}
	return self;
}

- (void) resetClient {
	[client release];
	DBSession *session = [DBSession sharedSession];
	client = [[DBRestClient alloc] initWithSession:session];
	client.delegate = self;
}

- (void) clearDelegates {
	[delegates removeAllObjects];
}

- (void) removeDelegate:(id<NebulousSaveAsDelegate>) delegate {
	[delegates removeObject:delegate];
}

- (void) addDelegate:(id<NebulousSaveAsDelegate>) delegate {
	[self removeDelegate:delegate];
	[delegates addObject:delegate];
}

- (BOOL) active {
	return active;
}

- (void) setActive:(BOOL) newActive {
	if (newActive == active)
		return;
	
	active = newActive;
	if (active == NO) {
		[self clearDelegates];
		self.saving = NO;
	}
}

- (void) save {
	saving = YES;
	[self resetClient];
	[client uploadFile:fileName toPath:destFolder fromPath:localPath];
}

- (void) cancel {
	NSArray *delegatesSnapshot = [NSArray arrayWithArray:delegates];
	NSEnumerator *e = [delegatesSnapshot objectEnumerator];
	id<NebulousSaveAsDelegate> delegate;
	while (delegate = [e nextObject]) {
		if ([delegate respondsToSelector:@selector(saveAsCanceled)])
			[delegate saveAsCanceled];
	}	
	self.active = NO;
}

- (void) stopSave {
	saving = NO;
	[self resetClient];
}

#pragma mark -
#pragma mark DBRestClient Delegates

- (void)restClient:(DBRestClient*)client uploadedFile:(NSString*)srcPath {
	NSArray *delegatesSnapshot = [NSArray arrayWithArray:delegates];
	NSEnumerator *e = [delegatesSnapshot objectEnumerator];
	id<NebulousSaveAsDelegate> delegate;
	while (delegate = [e nextObject]) {
		if ([delegate respondsToSelector:@selector(saveAsSuccess:)])
			[delegate saveAsSuccess:[destFolder stringByAppendingPathComponent:fileName]];
	}
	self.active = NO;
}

- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error {
	self.saving = NO;

	[NebulousStyle showBasicErrorAlert:[@"Could not upload file: " stringByAppendingString:[error localizedDescription]]];

	NSArray *delegatesSnapshot = [NSArray arrayWithArray:delegates];
	NSEnumerator *e = [delegatesSnapshot objectEnumerator];
	id<NebulousSaveAsDelegate> delegate;
	while (delegate = [e nextObject]) {
		if ([delegate respondsToSelector:@selector(saveAsFailed)])
			[delegate saveAsFailed];
	}
}

#pragma mark -

- (void) dealloc {
	client.delegate = nil;
	[client release];
		
	[destFolder release];
	[fileName release];
	[localPath release];
	[delegates release];
	
	[super dealloc];
}

@end
