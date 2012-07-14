//
//  Copyright (c) 2010 Nuclear Elements, Inc. http://nuclearelements.com/
//  The above line must remain intact. And this use of this source code is subject to the terms in LICENSE.txt
//

#import "NebulousSaveAsPrompt.h"
#import "NebulousStyle.h"
#import "NebulousController.h"

@implementation NebulousSaveAsPrompt

@synthesize directoryData;
@synthesize saveAsFileNameField;

- (id) init {
    if ((self = [super initWithNibName:@"NebulousSaveAs" bundle:nil])) {
		[[NebulousController shared].saveAs addDelegate:self];

    }
    return self;
}


/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


- (void) startActivity {
	saveAsFileNameField.enabled = NO;
	saveAsOKBtn.enabled = NO;
	[saveAsActivity startAnimating];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void) stopActivity {
	saveAsFileNameField.enabled = YES;
	saveAsOKBtn.enabled = YES;
	[saveAsActivity stopAnimating];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}


- (void)viewDidLoad {
	[super viewDidLoad];
	
	saveAsFileNameField.text = [NebulousController shared].saveAs.fileName;
	
	[NebulousStyle skinButton:saveAsOKBtn with:@"stdButtonBlue"];
	[NebulousStyle skinButton:saveAsCancelBtn with:@"stdButtonGray"];	
}
- (void)viewWillAppear:(BOOL)animated {
	if([NebulousController shared].saveAs.saving)
		[self startActivity];
	else
		[self stopActivity];
	
	saveAsFileNameField.text = [NebulousController shared].saveAs.fileName;
	[[NebulousController shared].saveAs addDelegate:self];
}

- (void)viewWillDisappear:(BOOL)animated {
	[NebulousController shared].saveAs.fileName = saveAsFileNameField.text;
	[[NebulousController shared].saveAs removeDelegate:self];
}

- (BOOL) alreadyHaveFileNamed:(NSString *) newFileName {
	NSEnumerator *e = [[directoryData contents] objectEnumerator];
	DBMetadata *fileMetadata;
	while (fileMetadata = [e nextObject]) {
		if (![fileMetadata isDirectory] && [[[fileMetadata path] lastPathComponent] isEqualToString:newFileName])
			return YES;
	}
	return NO;
}

- (IBAction) saveAsOKBtnHit:(id) sender {
	[saveAsFileNameField resignFirstResponder];

	NSString *fileName = saveAsFileNameField.text;
	[NebulousController shared].saveAs.fileName = fileName;
	
	if ([self alreadyHaveFileNamed:fileName]) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"\"%@\" already exists. Do you want to replace it?",fileName] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Replace",nil];
		[alert show];
		[alert release];
	} else {
		[self startActivity];
		[NebulousController shared].saveAs.save;
	}
}
		 
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	// OK Button
	if (buttonIndex == 1) {
		[self startActivity];
		[NebulousController shared].saveAs.save;		
	}
}
		 
		 

- (IBAction) saveAsCancelBtnHit:(id) sender {
	if ([saveAsFileNameField isFirstResponder]) {
		[saveAsFileNameField resignFirstResponder];
	} else if ([saveAsActivity isAnimating]) {
		[self stopActivity];
		[[NebulousController shared].saveAs stopSave];
	} else {
		[[NebulousController shared].saveAs cancel];
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[self saveAsOKBtnHit:textField];
	return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	[NebulousController shared].saveAs.fileName = textField.text;
}

#pragma mark -
#pragma mark SaveAs Delegate Methods

- (void) saveAsCanceled {
	self.view.userInteractionEnabled = NO;
	[[NebulousController shared].saveAs removeDelegate:self];
	[self stopActivity];
}
- (void) saveAsFailed {
	[self stopActivity];
}

#pragma mark -

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];    
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void) dealloc {
	[directoryData release];
	[super dealloc];
}

@end
