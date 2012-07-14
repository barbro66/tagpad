//
//  Copyright (c) 2010 Nuclear Elements, Inc. http://nuclearelements.com/
//  The above line must remain intact. And this use of this source code is subject to the terms in LICENSE.txt
//

#import "NebulousUploader.h"
#import "NebulousStyle.h"

@implementation NebulousUploader

@synthesize delegate;

- (void) resetClient {
	if (curClient != nil) {
		curClient.delegate = nil;
		[curClient release];
	}
	curClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
	curClient.delegate = self;
}

- (void) uploadFile:(NSString *) localPath toCloudPath:(NSString *) cloudPath {
	
	[self resetClient];
	[curPath release];
	curPath = [cloudPath copy];
	[curClient uploadFile:[cloudPath lastPathComponent] toPath:[cloudPath stringByDeletingLastPathComponent] fromPath:localPath];		
}

- (void)restClient:(DBRestClient*)client uploadedFile:(NSString*)srcPath {
	if (curClient != client)
		return;
	
	if ([delegate respondsToSelector:@selector(uploadedFile:)])
		[delegate uploadedFile:curPath];
}

- (void)restClient:(DBRestClient*)client uploadProgress:(CGFloat)progress forFile:(NSString*)srcPath {
	if (curClient != client)
		return;
	
	if ([delegate respondsToSelector:@selector(uploadProgress:forFile:)])	
		[delegate uploadProgress:progress forFile:curPath];
}

- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error {
	if (curClient != client)
		return;
	
	if ([delegate respondsToSelector:@selector(uploadFailedForFile:withError:)])
		[delegate uploadFailedForFile:curPath withError:error];
}


- (void) dealloc {
	[curPath release];
	curClient.delegate = nil;
	[curClient release];
	[delegate release];	
	[super dealloc];
}

@end
