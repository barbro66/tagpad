//
//  Copyright (c) 2010 Nuclear Elements, Inc. http://nuclearelements.com/
//  The above line must remain intact. And this use of this source code is subject to the terms in LICENSE.txt
//

#import <UIKit/UIKit.h>
#import "DropboxSDK.h"
#import "NebulousNewPath.h"
#import "NebulousSaveAsPrompt.h"

@interface NebulousDirectory : UIViewController <DBRestClientDelegate, UITableViewDelegate, UITableViewDataSource, NebulousNewPathDelegate, UIActionSheetDelegate, NebulousSaveAsDelegate> {
	BOOL refreshing;
	NSString *pathToDelete;
	
	// to release
	NebulousSaveAsPrompt *saveAsPrompt;
	
	NSIndexPath *curIndexPath;
	CGFloat	curProgress;
	NSString *path;	
	UIActionSheet *addSheet;
	UIActionSheet *delSheet;
	UIBarButtonItem *addBtn;
	UIBarButtonItem *logoffBtn;
	UIBarButtonItem *refreshBtnActivity;
	UIBarButtonItem *refreshBtn;
	UITableView *tableView;
	DBMetadata *directoryData;
	DBRestClient *client;
}

@property(nonatomic,readonly) NSString *path;
- (id) initWithPath:(NSString *) newPath;
- (void) doneLoading;
- (void) setLoadingProgress:(CGFloat) pct;

@end
