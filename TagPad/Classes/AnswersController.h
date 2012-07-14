//
//  AnswersController.h
//  TagPad
//
//  Created by Malcolm Hall on 08/04/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AnswersController : NSObject <UITableViewDelegate> {
    UITableView* _tableView;
    NSArray* choices;
    NSMutableArray* checkedRows;
}
@property (retain) NSArray* choices; // array of indexes
@property (retain) NSMutableArray* checkedRows;
@property (retain) IBOutlet UITableView* tableView;
@property (assign) NSArray* answers;


@end
