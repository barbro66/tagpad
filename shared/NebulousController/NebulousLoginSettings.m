//
//  Copyright (c) 2010 Nuclear Elements, Inc. http://nuclearelements.com/
//  The above line must remain intact. And this use of this source code is subject to the terms in LICENSE.txt
//

#import "NebulousLoginSettings.h"
#import "NebulousController.h"
#import "NebulousCredits.h"
#import "NebulousDirectory.h"
#import "NebulousStyle.h"

@interface NebulousLoginSettings (PrivateMethods)
- (void) gotoDirectories;
@end


@implementation NebulousLoginSettings

- (id)init {
    if (self = [super initWithNibName:@"NebulousLoginSettings" bundle:nil]) {
		self.navigationItem.title = @"Login Settings";
		self.navigationItem.leftBarButtonItem = nil;
		
		UIButton *infoBtn = [UIButton buttonWithType:UIButtonTypeInfoLight];
		CGRect infoFrame = infoBtn.frame;
		infoFrame.size.width += 20;
		infoBtn.frame = infoFrame;
		[infoBtn addTarget:self action:@selector(infoBtnHit:) forControlEvents:UIControlEventTouchUpInside];
		UIBarButtonItem *infoBarBtn = [[UIBarButtonItem alloc] initWithCustomView:infoBtn];
		[self.navigationItem setLeftBarButtonItem:infoBarBtn];
		[infoBtn release];
	}
    return self;
}

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

- (void)viewDidLoad {
    [super viewDidLoad];
	initialFrame = self.view.frame;
	
	[NebulousStyle skinButton:loginBtn with:@"stdButtonBlue"];
	
	if ([[DBSession sharedSession] isLinked] && [DEFAULTS boolForKey:DEFAULT_STAY_LOGGED]) {
		if ([PINController PINIsSet]) {
			PINController *pin = [[PINController alloc] init];
			pin.pinMode = PINModeVerifyPIN;
			pin.delegate = self;
			[self.navigationController pushViewController:pin animated:NO];
			[pin release];
		} else {
			[self gotoDirectories];
		}
	} else {
		if ([self respondsToSelector:@selector(setContentSizeForViewInPopover:)])
			self.contentSizeForViewInPopover = initialFrame.size;
		
		if (![DEFAULTS objectForKey:DEFAULT_STAY_LOGGED]) {
			[DEFAULTS setBool:YES forKey:DEFAULT_STAY_LOGGED];
			[stayLoggedSwitch setOn:YES];
			pinLabel.hidden = NO;
			pinSwitch.hidden = NO;
		} else {
			if ([DEFAULTS boolForKey:DEFAULT_STAY_LOGGED]) {
				[stayLoggedSwitch setOn:YES];
				[pinSwitch setHidden:NO];
				[pinLabel setHidden:NO];
			} else {
				[stayLoggedSwitch setOn:NO];
			}
		}
		
	}
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:YES];
	
	[self.navigationController setToolbarHidden:YES];
	
	[[NebulousController shared] setHideBtn:self];
}

#define POPOVER [NebulousController shared].popoverController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];	
			
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && POPOVER.popoverContentSize.height > initialFrame.size.height + 44) {
		[NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(setPopoverSize) userInfo:nil repeats:NO];
	}
}

- (void) setPopoverSize {
	// Hack to make the transition look smoother
	((UIView *) [self.navigationController.view.subviews objectAtIndex:1]).backgroundColor = [UIColor whiteColor];
	[POPOVER setPopoverContentSize:CGSizeMake(initialFrame.size.width, initialFrame.size.height + 44) animated:YES];	
}

- (void) gotoDirectories {

	NebulousDirectory *root = [[NebulousDirectory alloc] initWithPath:@"/"];
	[self.navigationController pushViewController:root animated:NO];
	[root autorelease];	

	if ([[NSUserDefaults standardUserDefaults] stringForKey:DEFAULT_LAST_OPENED_PATH]) {
	
		NSString *path = [[NSUserDefaults standardUserDefaults] stringForKey:DEFAULT_LAST_OPENED_PATH];
				
		NSArray *components = [path componentsSeparatedByString:@"/"];
		NSString *accumulatedPath = @"";
		
		for (int i=1; i < components.count; i++) {
			NSString *thisComponent = [components objectAtIndex:i];
			if ([thisComponent isEqualToString:@""])
				break;
			
			accumulatedPath = [accumulatedPath stringByAppendingFormat:@"/%@",thisComponent];
				
			NebulousDirectory *directory = [[NebulousDirectory alloc] initWithPath:accumulatedPath];
			[self.navigationController pushViewController:directory animated:NO];
			[directory autorelease];		
		}
	}
}

- (void) infoBtnHit:(id) sender {
	NebulousCredits *credits = [[NebulousCredits alloc] initWithNibName:@"NebulousCredits" bundle:nil];
	[self.navigationController pushViewController:credits animated:YES];
	[credits release];
}

- (IBAction) stayLoggedSwitchHit: (id) sender {
	[self clearPIN];
	if ([(UISwitch *) sender isOn]) {
		[DEFAULTS setBool:YES forKey:DEFAULT_STAY_LOGGED];
		[pinLabel setHidden:NO];
		[pinSwitch setHidden:NO];
		[pinSwitch setOn:NO];
	} else {
		[DEFAULTS setBool:NO forKey:DEFAULT_STAY_LOGGED];
		[pinLabel setHidden:YES];
		[pinSwitch setHidden:YES];
		[pinSwitch setOn:YES];
	}
}

#pragma mark -
#pragma mark PIN

- (void) clearPIN {
	pinSwitch.on = NO;
	[PINController clearPIN];
}

- (IBAction) pinSwitchHit:(id) sender {
	
	if ([(UISwitch *) sender isOn]) {
		
		PINController *pin = [[PINController alloc] init];
		pin.pinMode = PINModeNewPINFirst;
		[pin setDelegate:self];
		[[self navigationController] pushViewController:pin animated:YES];
		
		[pin release];	
	} else {
		[self clearPIN];
	}
}

- (void) pinSet {
	pinSwitch.on = YES;
	[self.navigationController popToViewController:self animated:NO];
	[self loginBtnHit:loginBtn];
}

- (void) pinVerified {
	[self gotoDirectories];
}

- (void) pinCanceled {
	[self clearPIN];
	[self.navigationController popToViewController:self animated:YES];
}
- (void) pinReset {
	[[DBSession sharedSession] unlink];
	[self clearPIN];
	[self.navigationController popToViewController:self animated:YES];
}


#pragma mark -
#pragma mark Logging in


- (IBAction) loginBtnHit: (id) sender {
	
	DBLoginController* controller = [[DBLoginController new] autorelease];
	controller.delegate = self;	
	controller.popover = [NebulousController shared].popoverController;
	[self.navigationController pushViewController:controller animated:YES];
	
	if (!pinSwitch.on)
		[self clearPIN];
}

#pragma mark -
#pragma mark DBLoginController Delegates

- (void)loginControllerDidLogin:(DBLoginController*)controller {
	[self gotoDirectories];	
}
- (void)loginControllerDidCancel:(DBLoginController*)controller {
	[self.navigationController popToViewController:self animated:YES];
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
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
