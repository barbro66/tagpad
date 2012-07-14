//
//  Copyright (c) 2010 Nuclear Elements, Inc. http://nuclearelements.com/
//  The above line must remain intact. And this use of this source code is subject to the terms in LICENSE.txt
//

#import <UIKit/UIKit.h>
#import "DropboxSDK.h"

typedef enum {
	NebulousNewPathTypeFile,
	NebulousNewPathTypeFolder,
} NebulousNewPathType;

@class NebulousNewPath;

@protocol NebulousNewPathDelegate
- (void) newFileDone:(NebulousNewPath *) newFileController withPath:(NSString *) returnedPath;
- (void) newFileCanceled:(NebulousNewPath *) newFileController;
@end


@interface NebulousNewPath : UIViewController <DBRestClientDelegate, UITextFieldDelegate> {
	
	IBOutlet UITextField *pathNameField;
	IBOutlet UIActivityIndicatorView *activity;
	IBOutlet UIButton *okBtn;
	IBOutlet UIButton *cancelBtn;
	
	NebulousNewPathType mode;
	NSString *rootPath;
	id<NebulousNewPathDelegate> delegate;
	
	BOOL keyboardHidingFromCancelBtn;
	
	// to release;
	DBRestClient *client;
}

@property(nonatomic,retain) id<NebulousNewPathDelegate> delegate;
@property(nonatomic,readonly) NebulousNewPathType mode;
- (id)initWithRootPath:(NSString *) newRootPath mode:(NebulousNewPathType) newMode;
- (IBAction) okBtnHit:(id) sender;
- (IBAction) cancelBtnHit:(id) sender;
@end
