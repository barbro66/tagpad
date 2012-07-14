//
//  Copyright (c) 2010 Nuclear Elements, Inc. http://nuclearelements.com/
//  The above line must remain intact. And this use of this source code is subject to the terms in LICENSE.txt
//

#import <UIKit/UIKit.h>
#import "NebulousSaveAs.h"
#import "DropboxSDK.h"

@interface NebulousSaveAsPrompt : UIViewController <NebulousSaveAsDelegate> {
	IBOutlet UIActivityIndicatorView *saveAsActivity;
	IBOutlet UIButton *saveAsOKBtn;
	IBOutlet UIButton *saveAsCancelBtn;
	IBOutlet UITextField *saveAsFileNameField;
	DBMetadata *directoryData;
}

@property (nonatomic,readonly) UITextField *saveAsFileNameField;
@property (nonatomic,retain) DBMetadata *directoryData;
- (IBAction) saveAsOKBtnHit:(id) sender;
- (IBAction) saveAsCancelBtnHit:(id) sender;

@end
