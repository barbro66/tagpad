//
//  MyCell.h
//  TagPad
//
//  Created by Malcolm Hall on 01/03/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MyCell : UITableViewCell {
    UILabel* numberLabel;
    UILabel* questionLabel;
}
@property (nonatomic, retain) IBOutlet UILabel *numberLabel;
@property (nonatomic, retain) IBOutlet UILabel *questionLabel;
@end
