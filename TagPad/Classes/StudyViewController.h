//
//  StudyViewController.h
//  TagPad
//
//  Created by Malcolm Hall on 02/05/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "MBProgressHUD.h"

@class CALevelMeter;
@class RecordingViewController;
@class AnalysisViewController;
@class Study;
@class Subject,SubjectsViewController,TagViewController,TagBarButton;


@interface StudyViewController : UIViewController <AVAudioPlayerDelegate,AVAudioRecorderDelegate,MBProgressHUDDelegate,UIActionSheetDelegate>{
    Study* study;
    Subject* subject;
    
    //subviews of recording and analysis are added and removed
    IBOutlet UIView* mainView;
    
    //toolbar
    UISlider *volumeSlider;
    UISlider *progressBar;
    UILabel *currentTimeLabel;
    UILabel *durationLabel;
    CALevelMeter *lvlMeter_in;
    UIBarButtonItem *playButton;
    UIBarButtonItem *recordOrStopButton;
    UIBarButtonItem *subjectsButton;
    UIBarButtonItem *myStudiesButton;
    UIView* timelineView;
    
    //audio
    BOOL recording; // if recording or paused recording
    AVAudioRecorder* audioRecorder;
    AVAudioPlayer						*audioPlayer;
    NSTimer								*updateTimer;
    
    RecordingViewController* recordingViewController;
    NSIndexPath* timelineIndexPath;
    IBOutlet UISegmentedControl* modeSegmentedControl;
    
    
    UIPopoverController* tagPopover;
    IBOutlet UINavigationController* tagNavigationController;
    IBOutlet UIButton* addTagButton;
    IBOutlet TagViewController* tagViewController;
    
    UIPopoverController* subjectsPopover;
    IBOutlet UINavigationController* subjectsNavigationController;
    IBOutlet SubjectsViewController* subjectsViewController;
    
    //tags
    NSMutableArray* tags;
    IBOutlet UIToolbar* tagBar;
    
    NSArray* colors;
    
    MBProgressHUD *HUD;
    TagBarButton* heldTagButton;

}

//UUID
@property (retain) Subject* subject;
@property (retain) Study* study;

//timeline data
@property (retain) NSIndexPath* timelineIndexPath;

@property (retain) NSMutableArray* tags;

@property (retain) IBOutlet UISlider *volumeSlider;
@property (retain) IBOutlet UISlider *progressBar;
@property (retain) IBOutlet UILabel *currentTimeLabel;
@property (retain) IBOutlet UILabel *durationLabel;
@property (retain) IBOutlet CALevelMeter *lvlMeter_in;
@property (retain) IBOutlet UIBarButtonItem *playButton;
@property (retain) IBOutlet UIBarButtonItem *recordOrStopButton;
@property (retain) IBOutlet UIBarButtonItem *subjectsButton;
@property (retain) IBOutlet UIBarButtonItem *myStudiesButton;
@property (retain) IBOutlet RecordingViewController *recordingViewController;
@property (retain) IBOutlet AnalysisViewController *analysisViewController;

@property (nonatomic, retain)	NSTimer			*updateTimer;
@property (nonatomic, assign)	AVAudioPlayer	*audioPlayer;
@property (retain) AVAudioRecorder* audioRecorder;
@property (readonly) NSTimeInterval recordingDuration;
@property (assign) TagBarButton* heldTagButton;

- (void)initializePlayer;
- (IBAction)myStudiesButtonTapped:(id)sender;
- (IBAction)recordButtonPressed:(UIButton*)sender;
- (IBAction)playButtonPressed:(UIButton*)sender;
- (IBAction)volumeSliderMoved:(UISlider*)sender;
- (IBAction)progressSliderMoved:(UISlider*)sender;
- (IBAction)modeSegmentedControlChanged:(UISegmentedControl*)sender;
- (IBAction)addTagButtonPressed:(UIButton*)sender;

- (void)setupAudioUI;
- (NSString*)directoryForSubject;
-(NSTimeInterval)currentTime;
- (void)switchToView:(NSInteger)index animated:(BOOL)animated;

-(IBAction)subjectsButtonPressed:(UIBarButtonItem*)sender;
-(IBAction)newSubjectTapped:(id)sender;
-(void)saveSubject;
-(void)loadSubject;
-(void)selectSubject:(Subject*)subject;
-(void)redrawTimeline;
-(void)reloadTagsForTime:(NSTimeInterval)interval;
-(void)startRecording;
-(void)stopRecording;
-(void)startPlayback;
-(void)pausePlayback;
-(void)preparePlayback;
@property (readonly) NSArray* colors;
-(void)playSubject:(Subject*)sub tag:(NSDictionary*)tag;
-(void)completeRecording;
-(IBAction)helpButtonTapped:(id)sender;
-(void)showDeleteTag:(id)sender;
@end
