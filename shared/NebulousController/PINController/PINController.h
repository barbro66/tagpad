//
//  Copyright (c) 2010 Nuclear Elements, Inc. http://nuclearelements.com/
//  The above line must remain intact. And this use of this source code is subject to the terms in LICENSE.txt
//

#import <UIKit/UIKit.h>

typedef enum {
	PINModeNewPINFirst,
	PINModeNewPINSecond,
	PINModeVerifyPIN
} PINMode;

@protocol PINControllerDelegate <NSObject>
- (void) pinSet;
- (void) pinVerified;
- (void) pinCanceled;
- (void) pinReset;
@end


@interface PINController : UIViewController <UIAlertViewDelegate> {
	
	IBOutlet UIScrollView *scroller;
	IBOutlet UIView *content;
	
	IBOutlet UIImageView *bolus1;
	IBOutlet UIImageView *bolus2;
	IBOutlet UIImageView *bolus3;
	IBOutlet UIImageView *bolus4;

	IBOutlet UILabel *prompt;	
	IBOutlet UILabel *doneLabel;
	IBOutlet UIButton *doneBtn;
	IBOutlet UILabel *attemptLabel;
		
	int num1;
	int num2;
	int num3;
	int num4;
	int numsEntered;
	PINMode pinMode;
	int firstPIN;
		
	// release
	id<PINControllerDelegate> delegate;
}

+ (BOOL) PINIsSet;
+ (void) clearPIN;

- (IBAction) numpadBtnHit:(id) sender;
- (IBAction) doneBtnHit:(id) sender;

@property(nonatomic,readonly) UIButton *doneBtn;
@property(nonatomic,retain) id<PINControllerDelegate> delegate;
@property(nonatomic,assign) PINMode pinMode;
@property(nonatomic,assign) int firstPIN;

@end
