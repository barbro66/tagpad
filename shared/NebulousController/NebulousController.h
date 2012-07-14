//
//  Copyright (c) 2010 Nuclear Elements, Inc. http://nuclearelements.com/
//  The above line must remain intact. And this use of this source code is subject to the terms in LICENSE.txt
//

#import <Foundation/Foundation.h>
#import "NebulousDirectory.h"
#import "NebulousLoginSettings.h"
#import "NebulousUploader.h"
#import "NebulousOpener.h"
#import "NebulousSaveAs.h"

#define DEFAULT_LAST_OPENED_PATH	@"NebulousDefaultLastPath"

@interface NebulousController : UINavigationController {
	
	// to release
	UIPopoverController *popoverController;	
	
	NebulousLoginSettings *loginSettings;

	NebulousUploader *uploader;
	NebulousOpener *opener;
	NebulousSaveAs *saveAs;
	
	NSString *consumerKey;
	NSString *consumerSecret;
}

#pragma mark -
#pragma mark The Methods you'll want to use

// public
@property(nonatomic,retain) UIPopoverController *popoverController;
+ (NebulousController *) shared;
- (id) initWithConsumerKey: (NSString *) key consumerSecret: (NSString *) secret;
- (void) hide;

- (void) setHandler:(id<NebulousFileHandler>) handler forType:(NSString *) mimePrefix;
- (void) setEnableNewPath:(BOOL) enableNewPath;
- (void) setNewFileTypeLabel:(NSString *) newFileTypeLabel;

- (void) setUploadDelegate:(id<NebulousFileUploadDelegate>) uploadDelegate;
- (void) uploadFile:(NSString *) localPath toCloudPath:(NSString *) cloudPath;

- (void) setToSaveAs:(NSString *) presetFileName fromLocalPath:(NSString *) localPath;
- (void) setSaveAsDelegate:(id<NebulousSaveAsDelegate>) saveAsDelegate;
- (void) clearSaveAs;

// internal to this API
@property(nonatomic,readonly) NebulousOpener *opener;
@property(nonatomic,readonly) NebulousSaveAs *saveAs;
- (void) setHideBtn:(UIViewController *) vc;
- (BOOL) directoryViewIsTop;


@end