//
//  Copyright (c) 2010 Nuclear Elements, Inc. http://nuclearelements.com/
//  The above line must remain intact. And this use of this source code is subject to the terms in LICENSE.txt
//

#import "NebulousController.h"
#import "NebulousStyle.h"
#import "DropboxSDK.h"
#import "NebulousLoginSettings.h"

static NebulousController* _sharedDropbox = nil;

@implementation NebulousController

@synthesize popoverController;
@synthesize opener;
@synthesize saveAs;

+ (NebulousController *) shared {
	return _sharedDropbox;
}

- (id)initWithConsumerKey: (NSString *) key consumerSecret: (NSString *) secret {
	loginSettings = [[NebulousLoginSettings alloc] init];
	
	if (_sharedDropbox != nil)
		return _sharedDropbox;
	
	if (self = [super initWithRootViewController:loginSettings]) {		
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminate:) name:UIApplicationWillTerminateNotification object:nil];				
		opener = [[NebulousOpener alloc] init];
		
		consumerKey = [key copy];
		consumerSecret = [secret copy];
		
		if ([DBSession sharedSession] == nil) {
			DBSession *session = [[DBSession alloc] initWithConsumerKey:key consumerSecret:secret];
			[DBSession setSharedSession:session];
			[session release];
		}
			
		_sharedDropbox = self;		
	}
	return self;
}


#pragma mark -
#pragma mark Directory Commands

- (void) logOff: (id) sender {
	[[DBSession sharedSession] unlink];
	[loginSettings clearPIN];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:DEFAULT_LAST_OPENED_PATH];

	[self popToRootViewControllerAnimated:YES];
}

- (void) hide {
	[self clearSaveAs];
	
	if (NSClassFromString(@"UIPopoverController") && (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad))
		[popoverController dismissPopoverAnimated:YES];
	else
		[self dismissModalViewControllerAnimated:YES];
}

- (void) setHideBtn:(UIViewController *)vc {	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
		UIBarButtonItem *hideBtn = [[UIBarButtonItem alloc] initWithTitle:@"Hide" style:UIBarButtonItemStyleBordered target:[NebulousController shared] action:@selector(hide)];
		[vc.navigationItem setRightBarButtonItem:hideBtn];
		[hideBtn release];
	}		
}

#pragma mark -
#pragma mark Opening Files

- (void) setNewFileTypeLabel:(NSString *) newFileTypeLabel {
	opener.newFileTypeLabel = newFileTypeLabel;
}

- (void) setEnableNewPath:(BOOL) enableNewPath {
	opener.enableNewPath = enableNewPath;
}

- (void) setHandler:(NSObject<NebulousFileHandler> *) handler forType:(NSString *) mimePrefix {
	[opener setHandler:handler forType:mimePrefix];
}

#pragma mark -
#pragma mark Uploading Files

- (void) uploadFile:(NSString *) localPath toCloudPath:(NSString *) cloudPath {
	if (uploader == nil)
		uploader = [[NebulousUploader alloc] init];
		
	[uploader uploadFile:localPath toCloudPath:cloudPath];
}

- (void) setUploadDelegate:(id<NebulousFileUploadDelegate>) uploadDelegate {
	if (uploader == nil)
		uploader = [[NebulousUploader alloc] init];
	uploader.delegate = uploadDelegate;
}

#pragma mark -
#pragma mark Changing File Modes

- (void) setSaveAsDelegate:(id<NebulousSaveAsDelegate>) saveAsDelegate {
	[saveAs	addDelegate:saveAsDelegate];
}

- (void) setToSaveAs:(NSString *) fileName fromLocalPath:(NSString *) localPath {
	if (saveAs == nil)
		saveAs = [[NebulousSaveAs alloc] init];
	
	saveAs.active = YES;
	saveAs.localPath = localPath;
	saveAs.fileName = fileName;
}

- (void) clearSaveAs {
	saveAs.active = NO;
}

#pragma mark -

- (BOOL) directoryViewIsTop {
	return [self.topViewController class] == [NebulousDirectory class];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)applicationWillTerminate:(UIApplication *)application {
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)dealloc {
	[loginSettings release];

	[uploader release];
	[opener release];

	[consumerKey release];
	[consumerSecret	release];
    [super dealloc];
}

@end
