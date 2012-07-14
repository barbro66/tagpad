//
//  AnalysisCell.m
//  TagPad
//
//  Created by Malcolm Hall on 09/05/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AnalysisCell.h"


@implementation AnalysisCell
@synthesize subjectLabel,tagBar;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)awakeFromNib{
    tagBar.layer.cornerRadius = 5;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    float f = 68.0f/255.0f;
    float f2 = 80.0f/255.0f;
    // Configure the view for the selected state
    if(selected){
        subjectLabel.textColor = [UIColor whiteColor];
        subjectLabel.shadowColor = [UIColor blackColor];
        subjectLabel.shadowOffset = CGSizeMake(0, 1);
        self.backgroundColor = [UIColor colorWithRed:f2 green:f2 blue:f2 alpha:1];
    }else{
        subjectLabel.textColor = [UIColor lightGrayColor];
        subjectLabel.shadowColor = [UIColor darkGrayColor];
        subjectLabel.shadowOffset = CGSizeMake(0, -1);
        
       self.backgroundColor = [UIColor colorWithRed:f green:f blue:f alpha:1];
       
    }
}

- (void)dealloc
{
    [super dealloc];
}

@end
