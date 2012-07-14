//
//  SubjectsViewController.h
//  TagPad
//
//  Created by Malcolm Hall on 30/03/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

@class Study,Subject;

@interface SubjectsViewController : UITableViewController {
    Study* study;
    id delegate;
    Subject* subject;
}
@property (retain) Study* study;
@property (assign) IBOutlet id delegate;
@property (retain) Subject* subject;

-(void)refreshData;

@end
