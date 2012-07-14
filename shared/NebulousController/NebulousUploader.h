//
//  Copyright (c) 2010 Nuclear Elements, Inc. http://nuclearelements.com/
//  The above line must remain intact. And this use of this source code is subject to the terms in LICENSE.txt
//

#import <Foundation/Foundation.h>
#import "DropboxSDK.h"

@protocol NebulousFileUploadDelegate <NSObject>
@optional
- (void)uploadedFile:(NSString *) dropboxPath;
- (void)uploadProgress:(CGFloat)progress forFile:(NSString*)dropboxPath;
- (void)uploadFailedForFile:(NSString *) dropboxPath withError:(NSError *) error;
@end

@interface NebulousUploader : NSObject <DBRestClientDelegate> {
	// to release;
	id<NebulousFileUploadDelegate> delegate;
	DBRestClient *curClient;
	NSString *curPath;
}

@property (nonatomic,retain) id<NebulousFileUploadDelegate> delegate;
- (void) uploadFile:(NSString *) localPath toCloudPath:(NSString *) cloudPath;

@end
