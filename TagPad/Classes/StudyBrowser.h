//
//  FileChooser.h
//  TagPad
//
//  Created by Malcolm Hall on 27/03/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NebulousController.h"

@class MBProgressHUD;
@class Study;

@interface StudyBrowser : UIViewController <NebulousFileHandler> {
    IBOutlet UIScrollView* scrollView; 
    id delegate;
    NebulousController *nebulous;
	UIPopoverController *popover;
    IBOutlet UIButton* importButton;
    IBOutlet UIButton* trashButton;
    IBOutlet UIButton* shareButton;
    IBOutlet UIButton* helpButton;
    
    IBOutlet UILabel* titleLabel;
    IBOutlet UILabel* editedLabel;
    IBOutlet UINavigationItem* navItem;
    NSMutableArray* uploads;
    NSMutableArray* uploadHistory;

    NSMutableArray* splits;
    MBProgressHUD *HUD;
    NSArray* studiesAndButtons;
    int lastStudyIndex;
   
    NSArray* currentlyUploading;
}  
@property (assign) id delegate;
@property (retain) NSMutableArray* uploads;
@property (retain) NSMutableArray* splits;
@property (retain) NSArray* studiesAndButtons;
@property (retain) NSMutableArray* uploadHistory;

@property (retain) NSArray* currentlyUploading;


-(void)surveyTapped:(id)sender;
-(IBAction)importTapped:(id)sender;
-(IBAction)shareTapped:(id)sender;
-(IBAction)trashTapped:(id)sender;
-(IBAction)helpTapped:(id)sender;

-(int)currentIndex;
-(void)updateLabels;
-(Study*)currentStudy;
-(void)reloadStudies;

//continue splitting
-(void)nextSplit;

//start dropbox
-(void)beginUploading;
-(void)nextUpload;
-(NSString*)fileMD5:(NSString*)path;

-(void)setCurrentIndex:(int)index;
-(void)showDropBox;

@end
