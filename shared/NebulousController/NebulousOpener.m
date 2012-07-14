//
//  Copyright (c) 2010 Nuclear Elements, Inc. http://nuclearelements.com/
//  The above line must remain intact. And this use of this source code is subject to the terms in LICENSE.txt
//

#import "NebulousOpener.h"
#import "NebulousController.h"
#import "NebulousDirectory.h"
#import "NebulousStyle.h"

@implementation NebulousOpener

@synthesize enableNewPath;
@synthesize newFileTypeLabel;

- (id) init {
	if (self = [super init]) {
		fileHandlers = [[NSMutableDictionary alloc] initWithCapacity:3];		
	}
	return self;
}

- (void) resetClient {
	if (curClient != nil) {
		curClient.delegate = nil;
		[curClient release];
	}
	curClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
	curClient.delegate = self;
}

- (void) setHandler:(NSObject<NebulousFileHandler> *) handler forType:(NSString *) mimePrefix {
	[fileHandlers setObject:handler forKey:mimePrefix];
}

- (id<NebulousFileHandler>) handlerForMime:(NSString *) mime {
	NSEnumerator *keys = [[fileHandlers allKeys] objectEnumerator];
	NSString *key;
	while (key = [keys nextObject]) {
		if ([mime hasPrefix:key])
			return [fileHandlers objectForKey:key];
	}
	return nil;
}


// returns YES if handler exists for file
- (BOOL) handleFile: (DBMetadata *) fileMetadata {
	NSString *mime = @"text/plain";
	
	/*
	 Uncomment when/if Dropbox decides to allow for mime-types
	 NSString *mime = [fileMetadata objectForKey:@"mime_type"];
	 */
	id<NebulousFileHandler> handler = [self handlerForMime:mime];
	
	curHandler = handler;
	if (curHandler == nil)
		return NO;
	
	[curPath release];
	curPath = [fileMetadata.path copy];
	
	[self resetClient];
	
	BOOL safeToLoadFile = NO;
	NSFileManager *mgr = [NSFileManager defaultManager];
	if ([mgr fileExistsAtPath:TEMP_NEBULOUS_DOWNLOAD_STORE]) {
		NSError *error = nil;
		if ([mgr removeItemAtPath:TEMP_NEBULOUS_DOWNLOAD_STORE error:&error]) {
			safeToLoadFile = YES;
		} else {
			[NebulousStyle showBasicErrorAlert:[NSString stringWithFormat:@"Couldn't load file: %@",[error localizedDescription]]];
		}
	} else {
		safeToLoadFile = YES;
	}
	if (safeToLoadFile)
		[curClient loadFile:curPath intoPath:TEMP_NEBULOUS_DOWNLOAD_STORE];		
	
	return YES;
}

- (void) doneLoading {
	if ([[NebulousController shared] directoryViewIsTop])
		[(NebulousDirectory *) [NebulousController shared].topViewController doneLoading];	
}

#pragma mark -
#pragma mark DBRestClient Delegates

- (void)restClient:(DBRestClient*)client loadedFile:(NSString*)destPath {
	if (curClient != client)
		return;
		
	if ([curHandler respondsToSelector:@selector(loadedFile:into:)])
		[curHandler loadedFile:curPath into:destPath];
	
	[self doneLoading];
	
}
- (void)restClient:(DBRestClient*)client loadProgress:(CGFloat)progress forFile:(NSString*)destPath {
	if (curClient != client)
		return;
	
	if ([[NebulousController shared] directoryViewIsTop])
		[(NebulousDirectory *) [NebulousController shared].topViewController setLoadingProgress:progress];
	
	if ([curHandler respondsToSelector:@selector(loadProgress:forFile:)])
		[curHandler loadProgress:progress forFile:curPath];
}

- (void)restClient:(DBRestClient*)client loadFileFailedWithError:(NSError*)error {
	if (curClient != client)
		return;
	
	[self doneLoading];
	
	[NebulousStyle showBasicErrorAlert:[NSString stringWithFormat:@"Could not load file: %@",[error localizedDescription]]];
	
	if ([curHandler respondsToSelector:@selector(loadFailedForFile:withError:)])
		[curHandler loadFailedForFile:curPath withError:error];
}

#pragma mark -

- (void) dealloc {
	curClient.delegate = nil;
	[curClient release];
	[curPath release];

	[fileHandlers release];	
	
	[super dealloc];
}

@end
