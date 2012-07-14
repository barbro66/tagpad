//
//  Copyright (c) 2010 Nuclear Elements, Inc. http://nuclearelements.com/
//  The above line must remain intact. And this use of this source code is subject to the terms in LICENSE.txt
//

#import "NebulousCredits.h"
#import "NebulousController.h"

@implementation NebulousCredits

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
		
	if ([self respondsToSelector:@selector(setContentSizeForViewInPopover:)])
		self.contentSizeForViewInPopover = self.view.frame.size;
		
	NSString *plistPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"NebulousController.plist"];
	
	NSDictionary *plistContents = [NSDictionary dictionaryWithContentsOfFile:plistPath];
	
	credits.text = [credits.text stringByReplacingOccurrencesOfString:@"$version" withString:(NSString *) [plistContents objectForKey:@"version"]];
	
	[super viewDidLoad];
}

//- (void)viewWillAppear:(BOOL)animated {
//	self.contentSizeForViewInPopover = initialLoadedFrame.size;
//}

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
    [super dealloc];
}


@end
