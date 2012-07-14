//
//  Copyright (c) 2010 Nuclear Elements, Inc. http://nuclearelements.com/
//  The above line must remain intact. And this use of this source code is subject to the terms in LICENSE.txt
//

#import "NebulousNewPath.h"
#import "NebulousController.h"
#import "NebulousStyle.h"

#define TEMP_NEBULOUS_NEWFILE_STORE	[NSTemporaryDirectory() stringByAppendingPathComponent:@"tempNewFileDropboxFile.txt"]

@implementation NebulousNewPath

@synthesize delegate;
@synthesize mode;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

- (id)initWithRootPath:(NSString *) newRootPath mode:(NebulousNewPathType) newMode {
    if ((self = [super initWithNibName:@"NebulousNewPath" bundle:nil])) {
		mode = newMode;
		rootPath = [newRootPath copy];
		keyboardHidingFromCancelBtn = NO;
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];		
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

	if (mode == NebulousNewPathTypeFolder)
		pathNameField.placeholder = @"Folder name";

	[[NebulousController shared] setHideBtn:self];
	
	[NebulousStyle skinButton:okBtn with:@"stdButtonBlue"];
	[NebulousStyle skinButton:cancelBtn with:@"stdButtonGray"];
}

- (void)viewDidAppear:(BOOL)animated {
	[pathNameField becomeFirstResponder];
	[self.navigationController setToolbarHidden:YES];
}

- (void) startActivity {
	pathNameField.enabled = NO;
	okBtn.enabled = NO;
	[activity startAnimating];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void) stopActivity {
	[activity stopAnimating];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	pathNameField.enabled = YES;
	okBtn.enabled = YES;
}

- (IBAction) okBtnHit:(id) sender {
	if (client == nil) {
		DBSession *session = [DBSession sharedSession];
		client = [[DBRestClient alloc] initWithSession:session];
		client.delegate = self;
	}
	
	[self startActivity];
		
	[pathNameField resignFirstResponder];

	if (mode == NebulousNewPathTypeFile) {		
		NSError *error = nil;
		if ([@"" writeToFile:TEMP_NEBULOUS_NEWFILE_STORE atomically:YES encoding:NSASCIIStringEncoding error:&error]) {
			[client uploadFile:pathNameField.text toPath:rootPath fromPath:TEMP_NEBULOUS_NEWFILE_STORE];
		} else {
			[NebulousStyle showBasicErrorAlert:[@"Could not create file: " stringByAppendingString:[error localizedDescription]]];
			[self stopActivity];
		}
	} else if (mode == NebulousNewPathTypeFolder) {
		[client createFolder:[rootPath stringByAppendingPathComponent:pathNameField.text]];
	}	
}

- (void) cancelBtnDelayedAction {
	[delegate newFileCanceled:self];
}

- (IBAction) cancelBtnHit:(id) sender {
	if ([activity isAnimating])
		delegate = nil;
	
	if ([pathNameField isFirstResponder]) {
		keyboardHidingFromCancelBtn = YES;
		[pathNameField resignFirstResponder];
	} else {
		[self cancelBtnDelayedAction];
	}
}


#pragma mark -
#pragma mark DBRestClient Delegates

- (void)restClient:(DBRestClient*)client uploadedFile:(NSString*)srcPath {
	[self stopActivity];

	if (delegate != nil)
		[delegate newFileDone:self withPath:[rootPath stringByAppendingPathComponent:pathNameField.text]];
}

- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error {
	[self stopActivity];

	[NebulousStyle showBasicErrorAlert:[@"Could not create file: " stringByAppendingString:[error localizedDescription]]];
}

- (void)restClient:(DBRestClient*)client createdFolder:(DBMetadata*)folder {
	[self stopActivity];

	if (delegate != nil)
		[delegate newFileDone:self withPath:[rootPath stringByAppendingPathComponent:pathNameField.text]];
}

- (void)restClient:(DBRestClient*)client createFolderFailedWithError:(NSError*)error {
	[self stopActivity];

	[NebulousStyle showBasicErrorAlert:[@"Could not create folder: " stringByAppendingString:[error localizedDescription]]];	
}

#pragma mark -
#pragma mark Keyboard delegate

- (void)keyboardWillHide:(NSNotification *)notification {
    
    NSDictionary* userInfo = [notification userInfo];
    
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];

	if (keyboardHidingFromCancelBtn)
		[NSTimer scheduledTimerWithTimeInterval:animationDuration target:self selector:@selector(cancelBtnDelayedAction) userInfo:nil repeats:NO];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[self okBtnHit:okBtn];
	return NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	client.delegate = nil;
	[client release];
    [super dealloc];
}


@end
