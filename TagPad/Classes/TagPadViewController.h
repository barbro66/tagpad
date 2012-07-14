//
//  TagPadViewController.h
//  TagPad
//
//  Created by Malcolm Hall on 01/03/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TagPadViewController : UITableViewController {
	IBOutlet UITableViewCell* myCell;
	NSDictionary* data;
	IBOutlet UINavigationBar* bar;
}
@property (nonatomic, assign) UITableViewCell* myCell;
@end

