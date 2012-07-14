//
//  AnalysisViewController.h
//  TagPad
//
//  Created by Malcolm Hall on 09/05/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


@class StudyViewController,AnalysisCell,TagViewController;

@interface AnalysisViewController : UITableViewController {
    NSMutableArray* subjects;
    //use to call stuff like play audio
    IBOutlet StudyViewController* studyView;
    AnalysisCell* analysisCell;
    UIPopoverController* chooseTagPopover;
    IBOutlet UINavigationController* chooseTagNavigationController;
    IBOutlet TagViewController* tagViewController;
}
@property (retain) IBOutlet AnalysisCell* analysisCell;
@property (copy) NSString* currentTag;

-(void)updateForTag:(NSString*)title;
-(void)tagButtonPressed:(UIBarButtonItem*)tagButton;
-(IBAction)chooseTagDone:(id)sender;
-(IBAction)clearTagsPressed:(id)sender;
-(void)updateTags;
@end