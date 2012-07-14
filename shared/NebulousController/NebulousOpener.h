//
//  Copyright (c) 2010 Nuclear Elements, Inc. http://nuclearelements.com/
//  The above line must remain intact. And this use of this source code is subject to the terms in LICENSE.txt
//

#import <Foundation/Foundation.h>
#import "DropboxSDK.h"

@protocol NebulousFileHandler <NSObject>
@optional
- (void)loadedFile:(NSString *) dropboxPath into:(NSString*)destPath;
- (void)loadProgress:(CGFloat)progress forFile:(NSString *) dropboxPath;
- (void)loadFailedForFile:(NSString *) dropboxPath withError:(NSError*)error;
@end

#define TEMP_NEBULOUS_DOWNLOAD_STORE	[NSTemporaryDirectory() stringByAppendingPathComponent:@"tempDownloadDropboxFile.txt"]

@interface NebulousOpener : NSObject <DBRestClientDelegate> {
	id<NebulousFileHandler> curHandler;	
	
	BOOL enableNewPath;
	
	// to release
	DBRestClient *curClient;
	NSString *curPath;
	NSString *newFileTypeLabel;
	NSMutableDictionary *fileHandlers;
	
}

@property(nonatomic,copy) NSString *newFileTypeLabel;
@property(nonatomic,assign) BOOL enableNewPath;
- (void) setHandler:(NSObject<NebulousFileHandler> *) handler forType:(NSString *) mimePrefix;
- (BOOL) handleFile: (DBMetadata *) fileMetadata;


@end
