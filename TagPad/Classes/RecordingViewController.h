//
//  RecordingViewController.h
//  TagPad
//
//  Created by Malcolm Hall on 27/03/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

@class CALevelMeter;
@class SubjectsViewController;
@class AnswersController;
@class StudyViewController;
@class Subject;
@class MyCell;

@interface RecordingViewController : UIViewController {
    id delegate;
    MyCell* myCell;
	NSDictionary* data;
    NSIndexPath* currentIndex;
    IBOutlet UITableView* _tableView;
    IBOutlet UIButton* nextButton;
    
    //temporary while recording then saved on exit
    NSMutableDictionary* answers;
    NSMutableArray* recordingStamps;
    
    IBOutlet UITextField* nameTextField;
    IBOutlet UITextField* infoTextField;
    
    IBOutlet UITextView* answerTextView;
    
    
    IBOutlet AnswersController* answersController;
    IBOutlet UIView* answerView;
    
    IBOutlet UILabel* emptyLabel;
    
    //use to call stuff like play audio
    IBOutlet StudyViewController* studyView;
}

@property (assign) id delegate;
@property (nonatomic, assign) IBOutlet MyCell* myCell;
@property (retain) NSIndexPath* currentIndex;
@property (retain) NSDictionary* data;
@property (retain) NSMutableDictionary* answers;
@property (retain) NSMutableArray* recordingStamps;
@property (readonly) UITableView* tableView;

-(void)loadStamps;


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)loadSubject;
- (void)saveSubject;
- (IBAction)nextButtonPressed:(UIButton*)sender;

//interface
-(void)updateCurrentTimeForPlayer:(AVAudioPlayer *)p;
-(void)startRecording;
-(void)resumeRecording;
-(void)pauseRecording;

-(void)closeStudy;
-(void)refreshView;
@end
