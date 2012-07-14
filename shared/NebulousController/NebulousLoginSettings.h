//
//  Copyright (c) 2010 Nuclear Elements, Inc. http://nuclearelements.com/
//  The above line must remain intact. And this use of this source code is subject to the terms in LICENSE.txt
//

#import <UIKit/UIKit.h>
#import "DropboxSDK.h"
#import "PINController.h"

#define DEFAULT_STAY_LOGGED		@"StayLogged"
#define DEFAULTS				[NSUserDefaults standardUserDefaults]


@interface NebulousLoginSettings : UIViewController <DBLoginControllerDelegate, PINControllerDelegate, UITextFieldDelegate> {
	CGRect initialFrame;
	
	IBOutlet UIButton *loginBtn;
	IBOutlet UILabel *stayLoggedLabel;
	IBOutlet UISwitch *stayLoggedSwitch;
	IBOutlet UISwitch *pinSwitch;
	IBOutlet UILabel *pinLabel;	
	
}

- (id)init;

- (IBAction) stayLoggedSwitchHit: (id) sender;
- (IBAction) pinSwitchHit:(id) sender;
- (IBAction) loginBtnHit: (id) sender;

- (void) clearPIN;

@end
