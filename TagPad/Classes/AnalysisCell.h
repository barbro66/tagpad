//
//  AnalysisCell.h
//  TagPad
//
//  Created by Malcolm Hall on 09/05/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AnalysisCell : UITableViewCell {
    UILabel* subjectLabel;
    UIView* tagBar;
}

@property (nonatomic, retain) IBOutlet UILabel *subjectLabel;
@property (nonatomic, retain) IBOutlet UIView *tagBar;

@end
