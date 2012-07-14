//
//  Copyright (c) 2010 Nuclear Elements, Inc. http://nuclearelements.com/
//  The above line must remain intact. And this use of this source code is subject to the terms in LICENSE.txt
//

#import <Foundation/Foundation.h>
#import "DropboxSDK.h"

@protocol NebulousSaveAsDelegate <NSObject>
@optional
- (void) saveAsSuccess:(NSString *) newCloudPath;
- (void) saveAsCanceled;
- (void) saveAsFailed;
@end

@interface NebulousSaveAs : NSObject <DBRestClientDelegate> {

	BOOL active;
	BOOL saving;
	
	// to release;
	DBRestClient *client;
	NSMutableArray *delegates;
	NSString *destFolder;
	NSString *localPath;
	NSString *fileName;
}

@property (nonatomic,assign) BOOL active;
@property (nonatomic,assign) BOOL saving;
@property (nonatomic,copy) NSString *localPath;
@property (nonatomic,copy) NSString *fileName;
@property (nonatomic,copy) NSString *destFolder;
- (void) addDelegate:(id<NebulousSaveAsDelegate>) delegate;
- (void) removeDelegate:(id<NebulousSaveAsDelegate>) delegate;
- (void) save;
- (void) stopSave;
- (void) cancel;
@end
