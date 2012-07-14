//
//  Copyright (c) 2010 Nuclear Elements, Inc. http://nuclearelements.com/
//  The above line must remain intact. And this use of this source code is subject to the terms in LICENSE.txt
//

#import "NebulousDirectory.h"
#import "NebulousController.h"
#import "NebulousStyle.h"

#define PROGRESS_BAR_VIEW_HEIGHT	30
#define VIEW_WIDTH	320 // add Retina display info in here later

@interface NebulousDirectory (PrivateAPI)
- (void) refreshDirectoryData;
- (void) updateToolbar;
- (void) showProgress;
@end


@implementation NebulousDirectory
@synthesize path;

#pragma mark -
#pragma mark Initialization

- (id)initWithPath:(NSString *) newPath {
	if (self = [super initWithNibName:nil bundle:nil]) {
		path = [newPath copy];
		refreshing = NO;
		
		DBSession *session = [DBSession sharedSession];	
		client = [[DBRestClient alloc] initWithSession:session];
		client.delegate = self;
		
		if ([path isEqualToString:@"/"]) {
			[[self navigationItem] setTitle:@"Home"];
		} else {
			[[self navigationItem] setTitle:[path lastPathComponent]];
		}		

	}
    return self;
}


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
		
	tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width) style:UITableViewStylePlain];
	tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	tableView.delegate = self;
	tableView.dataSource = self;
		
	[self.view addSubview:tableView];
		
	addBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addBtnHit:)];
	
	refreshBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshBtnHit)];
	
	logoffBtn = [[UIBarButtonItem alloc] initWithTitle:@"Log Off" style:UIBarButtonItemStyleBordered target:[NebulousController shared] action:@selector(logOff:)];
	
	UIActivityIndicatorView *dirRefreshing = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	refreshBtnActivity = [[UIBarButtonItem alloc] initWithCustomView:dirRefreshing];
	[dirRefreshing startAnimating];
	[dirRefreshing release];
				
	[super viewDidLoad];
}

- (void) maximizeFrame:(BOOL) animated {
	if (animated) {
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:NEBULOUS_TRANSITION_ANIM_LEN];
	}
	 
	tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);	

	if (animated)
		[UIView commitAnimations];
}

- (void)viewWillAppear:(BOOL)animated {
	[saveAsPrompt viewWillAppear:animated];
	
	[[NSUserDefaults standardUserDefaults] setObject:path forKey:DEFAULT_LAST_OPENED_PATH];
	
	if ([path isEqualToString:@"/"]) {
		[[self navigationItem] setTitle:@"Home"];
		
		UIBarButtonItem *emptyBtn = [[UIBarButtonItem alloc] initWithCustomView:[[[UIView alloc] initWithFrame:CGRectMake(0,0,0,0)] autorelease]];
		[self.navigationItem setLeftBarButtonItem:emptyBtn];
		[emptyBtn release];
		
	} else {
		[[self navigationItem] setTitle:[path lastPathComponent]];
	}		

	[[NebulousController shared] setHideBtn:self];
		
	[self refreshDirectoryData];

	if ([NebulousController shared].saveAs.active) {
		if (saveAsPrompt == nil) {
			saveAsPrompt = [[NebulousSaveAsPrompt alloc] init];
			CGRect promptFrame = saveAsPrompt.view.frame;
			promptFrame.size.width = self.view.frame.size.width;
			saveAsPrompt.view.frame = promptFrame;
			[self.view insertSubview:saveAsPrompt.view belowSubview:tableView];
			saveAsPrompt.directoryData = directoryData;
		}
	
		saveAsPrompt.view.userInteractionEnabled = YES;
		[NebulousController shared].saveAs.destFolder = path;
		[[NebulousController shared].saveAs addDelegate:self];
		
		tableView.frame = CGRectMake(0, saveAsPrompt.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - saveAsPrompt.view.frame.size.height);
		
	} else {
		[saveAsPrompt.view removeFromSuperview];
		[saveAsPrompt release];
		saveAsPrompt = nil;
		
		[self maximizeFrame:NO];
	}
	
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {		    	
	[super viewDidAppear:animated];
	[self updateToolbar];
}

- (void)viewWillDisappear:(BOOL)animated {
	[saveAsPrompt viewWillDisappear:animated];
    [super viewWillDisappear:animated];
}

/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/
									 
#pragma mark -
#pragma mark Directory Data-related

- (void)configureToolbarNotRefreshing {
	UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	UIBarButtonItem *flex2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

	if ([NebulousController shared].opener.enableNewPath)
		self.toolbarItems = [NSArray arrayWithObjects:addBtn,flex,refreshBtn,flex2,logoffBtn,nil];
	else
		self.toolbarItems = [NSArray arrayWithObjects:refreshBtn,flex2,logoffBtn,nil];
	[flex release];
	[flex2 release];
	
	[self.navigationController setToolbarHidden:NO];	
}

- (void)configureToolbarRefreshing {
	UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	
	UIBarButtonItem *flex2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

	if ([NebulousController shared].opener.enableNewPath)
		self.toolbarItems = [NSArray arrayWithObjects:addBtn,flex,refreshBtnActivity,flex2,logoffBtn,nil];
	else
		self.toolbarItems = [NSArray arrayWithObjects:refreshBtnActivity,flex2,logoffBtn,nil];		

	[flex release];
	[flex2 release];
	
	[self.navigationController setToolbarHidden:NO];	
}

- (void)updateToolbar {
	if (refreshing)
		[self configureToolbarRefreshing];
	else
		[self configureToolbarNotRefreshing];
}

- (void) refreshDirectoryData {
	refreshing = YES;
	[client loadMetadata:path withHash:nil];
}

- (void) refreshBtnHit {
	[self refreshDirectoryData];
	[self updateToolbar];
}

#pragma mark -
#pragma mark Save As Delegates

- (void) saveAsSuccess:(NSString *) newCloudPath {
	[[NebulousController shared] hide];
}

- (void) saveAsCanceled {
	[[NebulousController shared] hide];
}

#pragma mark -
#pragma mark New File

- (BOOL) newFileEnabled {
	return [NebulousController shared].opener.newFileTypeLabel != nil && ![NebulousController shared].saveAs.active;
}

- (void) addBtnHit: (id) sender {
	
	[addSheet release];
	
	if ([self newFileEnabled])
		addSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:[NebulousController shared].opener.newFileTypeLabel,@"New Folder",nil];
	else
		addSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"New Folder",nil];	
	
	[addSheet showFromToolbar:self.navigationController.toolbar];
}

- (void) addSheetConfirmed:(NSInteger)buttonIndex {
	BOOL newFileEnabled = [self newFileEnabled];
	if (newFileEnabled && buttonIndex == 1 || !newFileEnabled && buttonIndex == 0) {
		NebulousNewPath *newfolder = [[NebulousNewPath alloc] initWithRootPath:path mode:NebulousNewPathTypeFolder];		
		newfolder.delegate = self;
		[self.navigationController pushViewController:newfolder animated:YES];
		[newfolder release];
	} else if (newFileEnabled && buttonIndex == 0) {
		NebulousNewPath *newfile = [[NebulousNewPath alloc] initWithRootPath:path mode:NebulousNewPathTypeFile];
		newfile.delegate = self;
		[self.navigationController pushViewController:newfile animated:YES];
		[newfile release];
	}
}

- (void)newFileDone:(NebulousNewPath *)newFileController withPath:(NSString *) returnedPath {
	[self.navigationController popToViewController:self animated:NO];

	if ([newFileController mode] == NebulousNewPathTypeFile) {
		DBMetadata *fileMetadata = [[DBMetadata alloc] initWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"text/plain",@"mime_type",returnedPath,@"path",nil]];
				
		NebulousController *dropbox = [NebulousController shared];
		if (dropbox.opener != nil) {
			if ([dropbox.opener handleFile:fileMetadata]) {
				[self showProgress];	
			} else {
				// error, no handler (ignore for now, because we're handling all file types)
			}
		}
		[fileMetadata release];
	} else if ([newFileController mode] == NebulousNewPathTypeFolder) {
		NebulousDirectory *directory = [[NebulousDirectory alloc] initWithPath:returnedPath];
		[self.navigationController pushViewController:directory animated:YES];
		[directory release];
	}
}

- (void)newFileCanceled:(NebulousNewPath *)newFileController {
	[self.navigationController popToViewController:self animated:YES];
}

#pragma mark -
#pragma mark Progress Bar-related

- (void) showProgressForCell:(UITableViewCell *) cell {
	UIProgressView *progress = (UIProgressView *) [cell viewWithTag:1];
	
	if (curProgress == 0) {
		progress.hidden = YES;
	} else {
		progress.progress = curProgress;
		progress.hidden = NO;
	}
	
	if (cell.accessoryView == nil) {
		UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		cell.accessoryView = activity;
		[activity startAnimating];
		[activity release];		
	}
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];	
}

- (void) showProgressForIndexPath:(NSIndexPath *) indexPath {
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	if (cell == nil)
		return;
	[self showProgressForCell:cell];
}

- (void) showProgress {
	[self showProgressForIndexPath:curIndexPath];
}

- (void) hideProgressForCell:(UITableViewCell *) cell {
	UIProgressView *progress = (UIProgressView *) [cell viewWithTag:1];	
	
	progress.progress = 0;
	progress.hidden = YES;
	cell.accessoryView = nil;
}

- (void) hideProgressForIndexPath: (NSIndexPath *) indexPath {	
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	if (cell == nil)
		return;
	[self hideProgressForCell:cell];
}

#pragma mark public methods

- (void) doneLoading {
	curProgress = 0;
	[self hideProgressForIndexPath:curIndexPath];
	[curIndexPath release];
	curIndexPath = nil;
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];	
}

- (void) setLoadingProgress:(CGFloat)pct {
	curProgress = pct;
	[self showProgressForIndexPath:curIndexPath];
}

#pragma mark -
#pragma mark Table Delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.

	if (refreshing) {
		return 0;		
	} else {
		if (directoryData == nil)
			return 0;
		
		int count = [[directoryData contents] count];		
		return count;
	}
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableViewLocal cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"PathListingCell";
    
    UITableViewCell *cell = [tableViewLocal dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.textLabel.text;

		UIView *progressContainer = [[UIView alloc] initWithFrame:CGRectMake(10, 35, 270, 3)];
		progressContainer.clipsToBounds = YES;
		
		UIProgressView *progress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
		progress.frame = CGRectMake(-5, -4, 280, 11);
		progress.hidden = YES;
		progress.tag = 1;
		progress.progress = 0;
		
		[progressContainer addSubview:progress];
		[progress release];
		
		[cell.contentView addSubview:progressContainer];

		[progressContainer release];
		
	}
	
    // Configure the cell...
	
	if ([indexPath compare:curIndexPath] == NSOrderedSame)
		[self showProgressForCell:cell];
	else
		[self hideProgressForCell:cell];

	DBMetadata *fileMetadata = [[directoryData contents] objectAtIndex:indexPath.row];

	NSString *filePath = [fileMetadata path];
	[[cell textLabel] setText:[filePath lastPathComponent]];
		
	NSString *pathToIcon = [@"" stringByAppendingFormat:@"%@/%@.png",[[NSBundle mainBundle] bundlePath],[fileMetadata icon]];
	if (![[NSFileManager defaultManager] fileExistsAtPath:pathToIcon])
		pathToIcon = [@"" stringByAppendingFormat:@"%@/page_white.png",[[NSBundle mainBundle] bundlePath],[fileMetadata icon]];	
	cell.imageView.image = [UIImage imageWithContentsOfFile:pathToIcon];
	
    return cell;
}

- (void)tableView:(UITableView *)localTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	[localTableView deselectRowAtIndexPath:indexPath animated:NO];
	
	DBMetadata *fileMetadata = [[directoryData contents] objectAtIndex:indexPath.row];
	
	if ([fileMetadata isDirectory]) {
		NSString *newPath = [fileMetadata path];
		NebulousDirectory *directory = [[NebulousDirectory alloc] initWithPath:newPath];
		[self.navigationController pushViewController:directory animated:YES];
		[directory release];		
	} else {
		if ([NebulousController shared].saveAs.active) {
			NSString *fileName = [[fileMetadata path] lastPathComponent];
			saveAsPrompt.saveAsFileNameField.text = fileName;
			[NebulousController shared].saveAs.fileName = fileName;
		} else {
			NebulousController *dropbox = [NebulousController shared];
			if (dropbox.opener != nil) {
				if ([dropbox.opener handleFile:fileMetadata]) {
					if (curIndexPath != nil) {
						[self hideProgressForIndexPath:curIndexPath];
						[curIndexPath release];
					}
					curProgress = 0;
					curIndexPath = [indexPath copy];
					[self showProgressForIndexPath:indexPath];
				} else {
					// error if no handler
				}
			}
		}
	}
}

- (void)tableView:(UITableView *)localTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle != UITableViewCellEditingStyleDelete) {
		return;
	}
			
	if (delSheet != nil)
		[delSheet release];

	DBMetadata *fileMetadata = [[directoryData contents] objectAtIndex:indexPath.row];
	
	pathToDelete = [fileMetadata path];
	
	if ([fileMetadata isDirectory])
		delSheet = [[UIActionSheet alloc] initWithTitle:@"Are you sure you want to delete this folder and all its contents? (You can undo this from Dropbox's website)" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete Folder" otherButtonTitles:nil];		
	else
		delSheet = [[UIActionSheet alloc] initWithTitle:@"Are you sure you want to delete this file? (You can undo this from Dropbox's website)" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete File" otherButtonTitles:nil];				
		
	[delSheet showFromToolbar:self.navigationController.toolbar];
}


- (void) delSheetConfirmed {
	[client deletePath:pathToDelete];	
}


#pragma mark -
#pragma mark Dropbox Client Delegates
		 
- (void)restClient:(DBRestClient*)client loadedMetadata:(DBMetadata*)metadata {
	
	if (directoryData != nil)
		[directoryData release];
	directoryData = [metadata retain];
	saveAsPrompt.directoryData = metadata;
	refreshing = NO;
	[self updateToolbar];
	[tableView reloadData];
}

- (void)restClient:(DBRestClient*)client loadMetadataFailedWithError:(NSError*)error {
	[NebulousStyle showBasicErrorAlert:[NSString stringWithFormat:@"Error getting directory info: %@",[error localizedDescription]]];
	
	if (directoryData != nil)
		[directoryData release];
	directoryData = nil;
	refreshing = NO;
	[self updateToolbar];
}

- (void)restClient:(DBRestClient*)client deletedPath:(NSString *)path {
	[self refreshDirectoryData];
	[self updateToolbar];
}

- (void)restClient:(DBRestClient*)client deletePathFailedWithError:(NSError*)error {
	[NebulousStyle showBasicErrorAlert:[NSString stringWithFormat:@"Could not delete file: %@",[error localizedDescription]]];
}


#pragma mark -

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (actionSheet == addSheet) {
		[self addSheetConfirmed:buttonIndex];
	} else if (actionSheet == delSheet) {
		[self delSheetConfirmed];
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
	[saveAsPrompt release];
	
	[path release];
	[addSheet release];
	[delSheet release];
	[addBtn release];
	[logoffBtn release];
	[refreshBtn release];
	[refreshBtnActivity release];
	[directoryData release];
	client.delegate = nil;
	[client release];
    [super dealloc];
}


@end

