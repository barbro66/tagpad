//
//  Copyright (c) 2010 Nuclear Elements, Inc. http://nuclearelements.com/
//  The above line must remain intact. And this use of this source code is subject to the terms in LICENSE.txt
//

#import "PINController.h"
#import "NebulousStyle.h"

@interface PINController (PrivateMethods)
- (void) updateDisplay;
- (void) reset;
@end

@implementation PINController

static int MAX_PIN_ATTEMPTS = 10;
static NSString *PINCONTROLLER_PIN_ATTEMPTS		= @"kPinAttempts";
static NSString *PINCONTROLLER_PIN				= @"PinControllerPIN";

@synthesize delegate;
@synthesize doneBtn;
@synthesize firstPIN;

+ (BOOL) PINIsSet {
	return ([[NSUserDefaults standardUserDefaults] objectForKey:PINCONTROLLER_PIN] != nil);
}

+ (int) prevPIN {
	return ([(NSNumber *) [[NSUserDefaults standardUserDefaults] objectForKey:PINCONTROLLER_PIN] intValue]);	
}

+ (void) clearPIN {
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:PINCONTROLLER_PIN];
}

- (void) resetController {
	numsEntered = 0;
	[self updateDisplay];
}

- (PINMode) pinMode {
	return pinMode;
}
- (void) setPinMode:(PINMode) newMode {
	pinMode = newMode;
	if (pinMode == PINModeNewPINFirst) {
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		[defaults removeObjectForKey:PINCONTROLLER_PIN_ATTEMPTS];
	}
}

- (id)init {
    if (self = [super initWithNibName:@"PINController" bundle:nil]) {

    }
    return self;
}

- (void) applyScrollEnabled {
	if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation))
		scroller.scrollEnabled = NO;
	else
		scroller.scrollEnabled = YES;	
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {

	self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
	[scroller addSubview:content];
	[scroller setContentSize:content.frame.size];
	[self applyScrollEnabled];
		
	if ([self respondsToSelector:@selector(setContentSizeForViewInPopover:)])
		self.contentSizeForViewInPopover = self.view.frame.size;
	
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated {

	
	// upper-left navigation button
	if (pinMode == PINModeNewPINFirst || pinMode == PINModeNewPINSecond) {
		UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelBtnHit:)];
		[self.navigationItem setLeftBarButtonItem:cancelBtn];
		[cancelBtn release];		
	} else if (pinMode == PINModeVerifyPIN) {
		UIBarButtonItem *emptyBtn = [[UIBarButtonItem alloc] initWithCustomView:[[[UIView alloc] initWithFrame:CGRectMake(0,0,0,0)] autorelease]];
		[self.navigationItem setLeftBarButtonItem:emptyBtn];
		[emptyBtn release];		
		
		UIBarButtonItem *resetBtn = [[UIBarButtonItem alloc] initWithTitle:@"Reset" style:UIBarButtonItemStyleBordered target:self action:@selector(resetBtnHit:)];
		[self.navigationItem setRightBarButtonItem:resetBtn];
		[resetBtn release];
	}
		
	if (pinMode == PINModeNewPINSecond) 
		prompt.text = @"Please re-enter your passcode:";
	
	[self.navigationController setToolbarHidden:YES];
	
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}
			
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	[self applyScrollEnabled];
}

- (int) pinIntFromNums {
	return num1 * 1000 + num2 * 100 + num3 * 10 + num4;
}

- (void) updateDisplay {
	bolus1.hidden = bolus2.hidden = bolus3.hidden = bolus4.hidden = YES;
	doneBtn.hidden = doneLabel.hidden = attemptLabel.hidden = YES;
	
	if (numsEntered > 0)
		bolus1.hidden = NO;
	if (numsEntered > 1)
		bolus2.hidden = NO;
	if (numsEntered > 2)
		bolus3.hidden = NO;
	if (numsEntered > 3) {
		bolus4.hidden = NO;

		
		if (pinMode == PINModeNewPINFirst) {
			PINController *reentry = [[PINController alloc] init];
			reentry.pinMode = PINModeNewPINSecond;
			reentry.firstPIN = [self pinIntFromNums];
			[reentry setDelegate:delegate];
			[[self navigationController] pushViewController:reentry animated:YES];
			[reentry release];
		} else if (pinMode == PINModeNewPINSecond) {
			doneLabel.hidden = NO;
			doneBtn.hidden = NO;				
			if (firstPIN != [self pinIntFromNums]) {
				doneLabel.text = @"Your passcodes do not match.";
				[doneBtn setTitle:@"Press OK to try again" forState:UIControlStateNormal];
				// - PKD
				[NebulousStyle skinButton:doneBtn with:@"stdButtonGray"];
				
			} else {
				// - PKD
				[NebulousStyle skinButton:doneBtn with:@"stdButtonBlue"];
				
				// the XIB text is fine
			}
		} else if (pinMode == PINModeVerifyPIN) {
			if ([PINController prevPIN] != [self pinIntFromNums]) {

				NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
				int pinAttempts;
				if ([defaults objectForKey:PINCONTROLLER_PIN_ATTEMPTS] == nil) {
					[defaults setInteger:1 forKey:PINCONTROLLER_PIN_ATTEMPTS];
					pinAttempts = 1;
				} else {
					pinAttempts = [defaults integerForKey:PINCONTROLLER_PIN_ATTEMPTS];
					pinAttempts++;
					[defaults setInteger:pinAttempts forKey:PINCONTROLLER_PIN_ATTEMPTS];
				}
				
				
				if (pinAttempts >= MAX_PIN_ATTEMPTS) {
					[PINController clearPIN];
					[delegate pinReset];
				} else {
					doneLabel.text = @"Invalid passcode.";
					doneLabel.hidden = NO;

					[doneBtn setTitle:@"Press OK to try again" forState:UIControlStateNormal];				
					doneBtn.hidden = NO;
					// - PKD
					[NebulousStyle skinButton:doneBtn with:@"stdButtonBlue"];


					attemptLabel.text = [NSString stringWithFormat:@"%d attempts remaining before reset.", (MAX_PIN_ATTEMPTS - pinAttempts)];
					attemptLabel.hidden = NO;
				}
			} else {
					[delegate pinVerified];
			}			
		}
		
	}
}

- (IBAction) numpadBtnHit:(id) sender {
	int tag = [(UIButton *) sender tag];
	tag *= -1; // tag numbers greater than or equal to 3 screw the toolbar when the PopOver resizes
	if (tag == 10) {
		if (numsEntered > 0) {
			numsEntered--;
			[self updateDisplay];
		}
	} else {
		if (numsEntered == 0)
			num1 = tag;
		if (numsEntered == 1)
			num2 = tag;
		if (numsEntered == 2)
			num3 = tag;
		if (numsEntered == 3)
			num4 = tag;
		if (numsEntered < 4) {
			numsEntered++;
			[self updateDisplay];
		}
	}
}

- (IBAction) doneBtnHit:(id) sender {
	if (pinMode == PINModeNewPINFirst)
		return;

	if (pinMode == PINModeNewPINSecond) {
		if (firstPIN == [self pinIntFromNums]) {
			[[NSUserDefaults standardUserDefaults] setInteger:[self pinIntFromNums] forKey:PINCONTROLLER_PIN];
			[delegate pinSet];
		} else {
			// get previous pin controller, reset it, and go back (hacky)
			int indexOfPrevPINController = [[[self navigationController] viewControllers] count] - 2;
			[(PINController *) [self.navigationController.viewControllers objectAtIndex:indexOfPrevPINController] resetController];
			[[self navigationController] popViewControllerAnimated:YES];								
		}
		return;
	}
	
	if (pinMode == PINModeVerifyPIN) {
		[self resetController];
	}
}

- (void) cancelBtnHit:(id) sender {
	[delegate pinCanceled];
}

- (void) resetBtnHit:(id) sender {
	[PINController clearPIN];
	[delegate pinReset];
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
	[delegate release];
    [super dealloc];
}


@end
