//
//  StudyViewController.m
//  TagPad
//
//  Created by Malcolm Hall on 02/05/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "StudyViewController.h"
#import "CALevelMeter.h"
#import "RecordingViewController.h"
#import "AnalysisViewController.h"
#import "TagViewController.h"
#import "Product.h"
#import "Study.h"
#import "Subject.h"
#import "SubjectsViewController.h"
#import "TagBarButtonItem.h"
#import "UIImage+colorize.h"
#import <QuartzCore/QuartzCore.h>
#import "AudioJoiner.h"
#import "TagBarButton.h"


#define TAG_TIME 7.0f

//when press stop get it ready to play maybe not

@implementation StudyViewController
@synthesize volumeSlider,progressBar,currentTimeLabel,durationLabel,lvlMeter_in,playButton,recordOrStopButton,subjectsButton,myStudiesButton;
@synthesize audioRecorder,updateTimer,audioPlayer,recordingViewController;
@synthesize timelineIndexPath,analysisViewController;
@synthesize subject, study, tags,colors,heldTagButton;

void RouteChangeListener(void *                  inClientData,
                         AudioSessionPropertyID	inID,
                         UInt32                  inDataSize,
                         const void *            inData);

//either returns the recording or analysis view
-(UIView*)currentView{
    return nil;
}

-(NSTimeInterval)recordingDuration{
    //if audio recording name has a 2 on the end then add them
    NSTimeInterval firstTime = self.subject.recordingDuration;
    NSTimeInterval secondTime = self.audioRecorder.currentTime;
    return firstTime + secondTime;
}

-(IBAction)myStudiesButtonTapped:(id)sender{
    [subjectsPopover dismissPopoverAnimated:NO];
    
    //todo save everything
    CATransition* transition = [CATransition animation];
    //transition.duration = 1.0;
    transition.type = kCATransitionFade;
    transition.subtype = kCATransitionFromTop;
    
    [self.navigationController.view.layer 
     addAnimation:transition forKey:kCATransition];
    
    [self.navigationController popViewControllerAnimated:NO];
    
    //take screenshot
    UIImage* image = nil;
    
    UIGraphicsBeginImageContext(self.view.frame.size);
    {
        [self.view.layer renderInContext: UIGraphicsGetCurrentContext()];
        image = UIGraphicsGetImageFromCurrentImageContext();
    }
    UIGraphicsEndImageContext();
    [study saveScreenshot:image];
    
    //save the view we are on
    NSMutableDictionary* surveyDict = study.dictionary;
    [surveyDict setObject:[NSDate date] forKey:@"edited"];
    [surveyDict setObject:[NSNumber numberWithInt:modeSegmentedControl.selectedSegmentIndex] forKey:@"mode"];
    study.dictionary = surveyDict;
    [self saveSubject];
}

//updates both labels and tags.
-(void)updateForRecordingTime:(NSTimeInterval)interval{
    currentTimeLabel.text = [NSString stringWithFormat:@"%d:%02d", (int)interval / 60, (int)interval % 60, nil];
    durationLabel.text = [NSString stringWithFormat:@"%d:%02d", (int)interval / 60, (int)interval % 60, nil];
    progressBar.value = interval;
    progressBar.maximumValue = interval;
    [self reloadTagsForTime:interval];   
}

//updates current time, progress bar, looks for timeline segment changes, and tags.
-(void)updateForPlaybackTime:(NSTimeInterval)interval{
    currentTimeLabel.text = [NSString stringWithFormat:@"%d:%02d", (int)interval / 60, (int)interval % 60, nil];
    progressBar.value = interval;
    BOOL isStamp = NO;
    
    //todo optimize
    //this figures out if changed timeline segment.
    NSArray* stamps = self.subject.stamps;
    for(int i=[stamps count] - 1;i>=0;i--){
        NSDictionary* d = [stamps objectAtIndex:i];
        NSTimeInterval t = [[d objectForKey:@"time"] doubleValue];
        if(interval > t){
            NSIndexPath* n = [NSIndexPath fromString:[d objectForKey:@"index"]];
            isStamp = YES;
            if(!timelineIndexPath || timelineIndexPath.row != n.row || timelineIndexPath.section != n.section){
                self.timelineIndexPath = n;
                [recordingViewController timelineChangedIndexPath:timelineIndexPath];
            }
            break;
        }
    }
    if(!isStamp){
        self.timelineIndexPath = nil;
        [recordingViewController timelineChangedIndexPath:nil];
    }
    [self reloadTagsForTime:interval];   
}

-(void)reloadTagsForTime:(NSTimeInterval)interval{
    NSMutableArray* removes = [NSMutableArray array];
    //check if any tags need to be removed and update any colours
    for(TagBarButtonItem* t in tagBar.items){
        NSTimeInterval tagTime = [[t.tag objectForKey:@"time"] doubleValue];
        NSTimeInterval diff = tagTime - interval;
        //NSLog(@"%f",diff);
        if(diff < -TAG_TIME || diff > TAG_TIME){
            NSLog(@"Remove");
            [removes addObject:t];
            continue;
        }
    }
    NSMutableArray* items = [NSMutableArray arrayWithArray:tagBar.items];
    [items removeObjectsInArray:removes];
    
    //add any new tags
    for(NSDictionary* tag in tags){
        NSTimeInterval tagTime = [[tag objectForKey:@"time"] doubleValue];
        NSTimeInterval diff = tagTime - interval;
        if(diff < TAG_TIME && diff > -TAG_TIME){
            BOOL shouldAdd = YES;
            //check if already on the bar
            for(TagBarButtonItem* t in tagBar.items){
                if(t.tag == tag){
                    shouldAdd = NO;
                    break;
                }
            }
            //add the new item
            if(shouldAdd){
                NSLog(@"Added");
                NSString* title = [tag objectForKey:@"title"];
                TagBarButton *tagButton = [TagBarButton buttonWithType:UIButtonTypeCustom];
                tagButton.opaque = NO;
                [tagButton setFont:[UIFont boldSystemFontOfSize:13]];
                CGSize stringsize = [title sizeWithFont:[UIFont boldSystemFontOfSize:13]]; 
                //or whatever font you're using
                [tagButton setFrame:CGRectMake(0,0,stringsize.width + 15, 25)];
                
                [tagButton setTitle:title forState:UIControlStateNormal];
                //playButton.backgroundColor = [UIColor blueColor];
                [tagButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                
                UIImage *buttonImageNormal = [UIImage imageNamed:@"compose_atombw.png"];
                
                unichar ch = [title characterAtIndex:0];
                int x = (int)ch;
                UIColor* c = [colors objectAtIndex: x % (int)[colors count]];
                
                c = [UIColor colorWithCGColor:CGColorCreateCopyWithAlpha([c CGColor],0.4)];
                
                buttonImageNormal = [buttonImageNormal colorizeWithColor:c];
                
                UIImage *strechableButtonImageNormal = [buttonImageNormal stretchableImageWithLeftCapWidth:12 topCapHeight:0];
                
                [tagButton setBackgroundImage:strechableButtonImageNormal forState:UIControlStateNormal];
                
                /*
                 UIImage *buttonImagePressed = [UIImage imageNamed:@"whiteButton.png"];
                 UIImage *strechableButtonImagePressed = [buttonImagePressed stretchableImageWithLeftCapWidth:12 topCapHeight:0];
                 [playButton setBackgroundImage:strechableButtonImagePressed forState:UIControlStateHighlighted];
                 
                 [self.view addSubview:playButton];
                 */
                [tagButton addTarget:self action:@selector(tagTouchDown:) forControlEvents:UIControlEventTouchDown];
                
                tagButton.subject = subject;
                tagButton.tag = tag;
                
                TagBarButtonItem* t = [[TagBarButtonItem alloc] initWithCustomView:tagButton];
                t.tag = tag;
                [items addObject:t];
            }
        }
    }
    [tagBar setItems:items animated:YES];
    for(TagBarButtonItem* t in tagBar.items){
        NSTimeInterval tagTime = [[t.tag objectForKey:@"time"] doubleValue];
        NSTimeInterval diff = tagTime - interval;
        
        //update alpha
        if(diff<0){
            diff = diff * -1;
        }
        diff = TAG_TIME - diff;
        //NSLog(@"%f",diff);
        //min alpha is 0.2
        double ttt = TAG_TIME;
        double fraction = diff / ttt;
        t.customView.layer.opacity = fraction;
    }
}

-(void)tagTouchUpInside:(id)sender{
    NSLog(@"tagTouchUpInside");
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showDeleteTag:) object:sender];
}

-(void)tagTouchDown:(id)sender{
    NSLog(@"tagTouchDown");
    [sender addTarget:self action:@selector(tagTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    //pause so it doesn't dissapear
    [self pausePlayback];
    [self performSelector:@selector(showDeleteTag:) withObject:sender afterDelay:1];
}

-(void)showDeleteTag:(id)sender{
    [sender removeTarget:self action:@selector(tagTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    NSLog(@"showDeleteTag");
    UIActionSheet* actionSheet =  [[UIActionSheet alloc] initWithTitle:nil
                                                              delegate:self
                                                     cancelButtonTitle:nil
                                                destructiveButtonTitle:@"Delete Tag"
                                                     otherButtonTitles:nil];
    //actionSheet.tag = kTrashAlertSheet;
    CGRect r = [sender frame];
    [actionSheet showFromRect:CGRectMake(r.size.width / 2.0f, r.origin.y, 1, 1) inView:sender animated:YES];
    //[actionSheet showInView:sender];
    [actionSheet release];
    self.heldTagButton = sender;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == -1)
        return;
    [tags removeObject:self.heldTagButton.tag];
    //save them
    self.subject.tags = tags;
    //make the dot appear
    [self redrawTimeline];
    
    //remove all the tags
    tagBar.items = nil;
    //make the tag appear if we are paused
    [self reloadTagsForTime:[self currentTime]];
    
    //update analysis view if this tag is in the current choice
    [analysisViewController updateForTag:[heldTagButton.tag objectForKey:@"title"]];
}

- (void)updateCurrentTime
{
    //choose between audio player or audio recorder
    if(recording){
        [self updateForRecordingTime:self.recordingDuration];
    }else{
        [self updateForPlaybackTime:self.audioPlayer.currentTime];
    }
}

- (IBAction)modeSegmentedControlChanged:(UISegmentedControl*)sender{
    [self switchToView:modeSegmentedControl.selectedSegmentIndex animated:YES];
}

-(void)switchToView:(NSInteger)index animated:(BOOL)animated{
    NSLog(@"modeSegmentedControlChanged");
    
    if(index == 0){ // recording
        subjectsButton.title = @"Subjects";
        if(animated){
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:1.0]; 
            [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:mainView cache:YES];
        }
        [analysisViewController.view removeFromSuperview];
        [mainView addSubview: recordingViewController.view];
        
    }else{ // analysis
        [analysisViewController viewWillAppear:YES];
        subjectsButton.title = @"Tags";
        if(animated){
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:1.0]; 
            [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:mainView cache:YES];
        }
        [recordingViewController.view removeFromSuperview];
        [mainView addSubview:analysisViewController.view];
    }
    if(animated){
        [UIView commitAnimations];
    }
}

- (void)updateViewForPlayerState:(AVAudioPlayer *)p
{
	if (updateTimer){
		[updateTimer invalidate];
        NSLog(@"Timer stopped");
    }
    
	if (p.playing)
	{
        [self updateCurrentTime];
        playButton.title = @"Stop";
        recordOrStopButton.enabled = NO;
		[lvlMeter_in setPlayer:p];
		updateTimer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(updateCurrentTime) userInfo:p repeats:YES];
        NSLog(@"Timer started");
	}
	else
	{
        playButton.title = @"Play";
        recordOrStopButton.enabled = YES;
		[lvlMeter_in setPlayer:nil];
		updateTimer = nil;
	}
}


-(void)updateViewForPlayerInfo:(AVAudioPlayer*)p
{
	durationLabel.text = [NSString stringWithFormat:@"%d:%02d", (int)p.duration / 60, (int)p.duration % 60, nil];
	progressBar.maximumValue = p.duration;
	volumeSlider.value = p.volume;
    progressBar.value = 0;
    currentTimeLabel.text = @"0.00";
    playButton.enabled = YES;
    [self redrawTimeline];
}

-(void)redrawTimeline{
    //set up timeline
    CGRect r = CGRectMake(progressBar.frame.origin.x+15, progressBar.frame.origin.y, progressBar.frame.size.width-30, 25);
    if(timelineView){
        [timelineView removeFromSuperview];
        timelineView = nil;
    }
    timelineView = [[[UIView alloc] initWithFrame:r] autorelease];
    timelineView.backgroundColor = [UIColor colorWithRed:40.0/255.0 green:40.0/255.0 blue:40.0/255.0 alpha:1.0];
    [self.view insertSubview:timelineView belowSubview:progressBar];
    
    NSTimeInterval duration = 0;
    if(recording){
        duration = audioRecorder.currentTime;
    }else{
        duration = audioPlayer.duration;
    }
    if(duration == 0)
        duration = 1;
    
    double durationPerPixel = (double)r.size.width / duration;
    BOOL alternate = NO;
    UIColor* grey = [UIColor colorWithRed:55.0/255.0 green:55.0/255.0 blue:55.0/255.0 alpha:1.0];
    UIColor* grey2 = [UIColor colorWithRed:100.0/255.0 green:100.0/255.0 blue:100.0/255.0 alpha:1.0];
    int lastMajor = -1;
    for(int i =0;i<[self.subject.stamps count];i++){
        NSDictionary* curStamp = [self.subject.stamps objectAtIndex:i];
        NSNumber* start = [curStamp objectForKey:@"time"];
        NSString* index = [curStamp objectForKey:@"index"];
        NSIndexPath* indexPath = [NSIndexPath fromString:index];
        
        int majorNumber = indexPath.section+1;
        int minorNumber = indexPath.row+1;
        
        NSNumber* end = nil;
        if(i == [self.subject.stamps count] - 1){ 
            //if last stamp
            end = [NSNumber numberWithDouble:duration];
        }else{
            NSDictionary* stamp = [self.subject.stamps objectAtIndex:i+1];
            end = [stamp objectForKey:@"time"];
        }
        
        double x = [start doubleValue] * durationPerPixel;
        double width = ([end doubleValue] - [start doubleValue]) * durationPerPixel;
        
        // NSLog(@"%f %f",x,width);
        
        CGRect chunkFrame = CGRectMake(x, 0, width, 25);
        UIView * bit = [[[UIView alloc] initWithFrame:chunkFrame] autorelease];
        bit.backgroundColor = (alternate? grey: grey2);
        alternate = !alternate;
        [timelineView addSubview:bit];
        
        UILabel* label = [[[UILabel alloc] initWithFrame:chunkFrame] autorelease];
        
        if(lastMajor!=majorNumber){
            //questionNumber = [NSString stringWithFormat:@"%d.%d",majorNumber,minorNumber];
            label.text = [NSString stringWithFormat:@"%d",majorNumber];
            label.font = [UIFont boldSystemFontOfSize:18];
            label.textColor = [UIColor whiteColor];
        }else{
            //questionNumber = [NSString stringWithFormat:@".%d",minorNumber];
            label.text = [NSString stringWithFormat:@"%d",minorNumber];
            label.font = [UIFont systemFontOfSize:14];
            label.textColor = (alternate ? grey: grey2);
        }
        lastMajor = majorNumber;
        label.lineBreakMode = UILineBreakModeClip;
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = UITextAlignmentLeft;
        
        [timelineView addSubview:label];
        // NSString* dest = [[audioFile stringByDeletingLastPathComponent] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.m4a",questionNumber]];
        //NSArray* split = [NSArray arrayWithObjects:audioFile,dest,start,end, nil];
        //[self.splits addObject:split];
        // NSLog(@"%@ %@ %@",index, start,end);
        
        // NSDictionary* d = [NSDictionary dictionaryWithObjectsAndKeys:[self stringFromIndexPath:currentIndex],@"index",
        // [NSNumber numberWithDouble:n] ,@"time",nil];
    }
    
    //draw tag lines
    
    //add any new tags
    for(NSDictionary* tag in tags){
        NSTimeInterval tagTime = [[tag objectForKey:@"time"] doubleValue];
        double xx = tagTime * durationPerPixel;
        
        NSString* title = [tag objectForKey:@"title"];
        CGRect chunkFrame = CGRectMake(xx, 15, 5, 10);
        UIView * tagLine = [[[UIView alloc] initWithFrame:chunkFrame] autorelease];
        
        unichar ch = [title characterAtIndex:0];
        int x = (int)ch;
        UIColor* c = [colors objectAtIndex: x % (int)[colors count]];
        
        c = [UIColor colorWithCGColor:CGColorCreateCopyWithAlpha([c CGColor],0.4)];
        
        tagLine.backgroundColor = c;
        [timelineView addSubview:tagLine];
    }
    
}

- (void)awakeFromNib
{	
    [[AVAudioSession sharedInstance] setDelegate: self];
}


-(void)pausePlayback
{
	[self.audioPlayer pause];
	[self updateViewForPlayerState:self.audioPlayer];
}

-(void)startPlayback
{
    //check if at the end of track and if so, set it back to the beginning like all other audio players do.
    if(self.audioPlayer.currentTime == self.audioPlayer.duration){
        self.audioPlayer.currentTime = 0;
    }
    //check if the player has been initialisaed and can play
    //if(!self.audioPlayer || ![self.audioPlayer play]){
    //initialize and play
    //  [self initializePlayer];
    if(![self.audioPlayer play]){
        NSLog(@"Could not play 2%@\n", audioPlayer.url);
    }
    //}
    
    //update the UI with duration and start the progress timer.
    //[self updateViewForPlayerInfo:audioPlayer];
    [self updateViewForPlayerState:audioPlayer];
}


-(void)initializePlayer{
    if(!self.subject.audioFile)
        return;
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: nil];
    
    NSURL *soundFileURL = [NSURL fileURLWithPath:self.subject.audioFile];
    
    NSError* error = nil;
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:&error];	
    if (self.audioPlayer)
    {
        //fileName.text = [NSString stringWithFormat: @"%@ (%d ch.)", [[player.url relativePath] lastPathComponent], player.numberOfChannels, nil];
        audioPlayer.numberOfLoops = 0;
        audioPlayer.delegate = self;
    }
}


- (IBAction)playButtonPressed:(UIButton *)sender
{
	if (audioPlayer.playing == YES)
		[self pausePlayback];
	else
		[self startPlayback];
}

- (IBAction)volumeSliderMoved:(UISlider *)sender
{
	audioPlayer.volume = [sender value];
}

- (IBAction)progressSliderMoved:(UISlider *)sender
{
    //slider is only operational when playing
    if(!recording){
        audioPlayer.currentTime = sender.value;
        [self updateForPlaybackTime:audioPlayer.currentTime];
    }
}

#pragma mark AudioSession handlers

void RouteChangeListener(	void *                  inClientData,
                         AudioSessionPropertyID	inID,
                         UInt32                  inDataSize,
                         const void *            inData)
{
	StudyViewController* This = (StudyViewController*)inClientData;
	
	if (inID == kAudioSessionProperty_AudioRouteChange) {
		
		CFDictionaryRef routeDict = (CFDictionaryRef)inData;
		NSNumber* reasonValue = (NSNumber*)CFDictionaryGetValue(routeDict, CFSTR(kAudioSession_AudioRouteChangeKey_Reason));
		
		int reason = [reasonValue intValue];
        
		if (reason == kAudioSessionRouteChangeReason_OldDeviceUnavailable) {
			[This pausePlayback];
		}
	}
}

#pragma mark AVAudioPlayer delegate methods

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)p successfully:(BOOL)flag
{
    NSLog(@"audioPlayerDidFinishPlaying");
	if (flag == NO)
		NSLog(@"Playback finished unsuccessfully");
    
    //	[p setCurrentTime:0];
    //progressBar.value = progressBar.maximumValue;
	[self updateViewForPlayerState:p];
	//[self performSelector:@selector(updateViewForPlayerState:) withObject:p afterDelay:0];
}

- (void)playerDecodeErrorDidOccur:(AVAudioPlayer *)p error:(NSError *)error
{
	NSLog(@"ERROR IN DECODE: %@\n", error); 
}

// we will only get these notifications if playback was interrupted
- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)p
{
	NSLog(@"Interruption begin. Updating UI for new state");
	// the object has already been paused,	we just need to update UI
	[self updateViewForPlayerState:p];
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)p
{
	NSLog(@"Interruption ended. Resuming playback");
	//[self startPlayback];
}

- (IBAction)recordButtonPressed:(UIButton*) sender {
    if (recording) {        
        [self stopRecording];
    }else{
        [self startRecording];
    }
}

-(void)startRecording{
    
    //invalidate the audio player so the audio file will be reopened if played
    self.audioPlayer = nil;
    
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryRecord error: nil];
    NSDictionary *recordSettings =
    [[NSDictionary alloc] initWithObjectsAndKeys:
     [NSNumber numberWithFloat: 44100.0], AVSampleRateKey,
     [NSNumber numberWithInt: kAudioFormatMPEG4AAC], AVFormatIDKey,
     [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,
     [NSNumber numberWithInt: AVAudioQualityHigh],AVEncoderAudioQualityKey,
     nil];
    
    //either record to audio or to temp audio2 if it exists
    
    NSURL *soundFileURL = nil;
    //if([[NSFileManager defaultManager] fileExistsAtPath:self.subject.audioFile]){
    NSString *soundFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent: @"audio.m4a"];
    //NSLog(@"%@",soundFilePath);
    soundFileURL = [NSURL fileURLWithPath:soundFilePath];
    ///    }else{
    //     soundFileURL = [NSURL fileURLWithPath:self.subject.audioFile];
    //}
    
    NSError* error = nil;
    self.audioRecorder =
    [[AVAudioRecorder alloc] initWithURL: soundFileURL
                                settings: recordSettings
                                   error: &error];
    [recordSettings release];
    if(error){
        NSLog(@"%@",[error description]);
    }
    //does stamp stuff before recording really starts
    [recordingViewController startRecording];
    
    audioRecorder.delegate = self;
    [audioRecorder prepareToRecord];
    [audioRecorder record];
    recordOrStopButton.title = @"Stop";
    recording = YES;
    myStudiesButton.enabled = NO;
    playButton.enabled = NO;
    subjectsButton.enabled = NO;
    [lvlMeter_in setPlayer:(AVAudioPlayer*) audioRecorder];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    updateTimer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(updateCurrentTime) userInfo:nil repeats:YES];
}

-(void)stopRecording{
    //save the duration
    self.subject.recordingDuration = self.recordingDuration;
    [audioRecorder stop];
    
    NSURL* tempUrl = audioRecorder.url;
    self.audioRecorder = nil;
    
    //save the stamps etc
    [recordingViewController stopRecording];
    
    //if the audio file is audio2 then append it to audio 1
    
    //if the mov already exists then append the caf to it
    NSLog(@"%@",[tempUrl path]);
    //if([[[tempUrl path] lastPathComponent] isEqualToString:@"audio.caf"]){
    if([[NSFileManager defaultManager] fileExistsAtPath:self.subject.audioFile]){
        NSURL* soundFileURL = [NSURL fileURLWithPath:self.subject.audioFile];
        
        [[[AudioJoiner alloc] initWithFirstFile:soundFileURL secondFile:tempUrl delegate:self] autorelease];
        
        //show a HUD
        UIWindow* mainWindow = [[UIApplication sharedApplication].windows objectAtIndex:0];
        HUD = [[MBProgressHUD alloc] initWithWindow:mainWindow];
        [mainWindow addSubview:HUD];
        HUD.delegate = self;
        [HUD setLabelText:@"Saving audio..."];
        [HUD show:YES];
    }else{
        NSError* error = nil;
        [[NSFileManager defaultManager] moveItemAtPath:[tempUrl path] toPath:self.subject.audioFile error:&error];
        
        [self completeRecording];
    }
}

//a m4a
- (void)audioJoinerDidFinish:(AudioJoiner *)audioJoiner joinedFile:(NSString*)joinedFile{
    // NSError* error = nil;
    
    //  [[NSFileManager defaultManager] copyItemAtPath:joinedFile toPath:self.subject.audioFile error:&error];
    
    //  [[NSFileManager defaultManager] moveItemAtPath:joinedFile toPath:self.subject.audioFile error:&error];
    // [[NSFileManager defaultManager] removeItemAtPath:joinedFile error:&error];
    // [audioJoiner release];
    
    //  [HUD hide:YES];
    
    NSLog(@"audioJoinerDidFinish");
    NSError* error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:self.subject.audioFile error:&error];
    [[NSFileManager defaultManager] moveItemAtPath:joinedFile toPath:self.subject.audioFile error:&error];
    [HUD hide:YES];
    [self completeRecording];
}


//resets the UI back from recording
-(void)completeRecording{
    recordOrStopButton.title = @"Record";
    myStudiesButton.enabled = YES;
    playButton.enabled = YES;
    subjectsButton.enabled = YES;
    
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    //  [[AVAudioSession sharedInstance] setActive: NO error: nil];
    
    //make the timeline update when stop is pressed.
    [updateTimer invalidate];
    updateTimer = nil;
    recording = NO;
    
    //refresh the timeline
    [self preparePlayback];
}

-(void)audioJoiner:(AudioJoiner *)audioJoiner didFailWithError:(NSError *)error{
    NSLog(@"%@",[error description]);
    [HUD hide:YES];
}

- (void)hudWasHidden {
    // Remove HUD from screen when the HUD was hidded
    [HUD removeFromSuperview];
    [HUD release];
}


-(void)loadSubject{
    //load
    self.tags = subject.tags;
    if(!self.tags){
        self.tags = [NSMutableArray array];
    }    //setup progress bar with correct duration
    
    [self preparePlayback];
    
    [recordingViewController loadSubject];
    tagBar.items = nil;
    [self reloadTagsForTime:0];
}

- (IBAction)addTagButtonPressed:(UIButton*)sender{
    if(!tagPopover){
        tagPopover = [[UIPopoverController alloc] initWithContentViewController:tagNavigationController];
    }
    NSMutableArray* aa = self.study.tags;
    tagViewController.listContent = aa;
    tagViewController.canCreateTags = YES;
    tagViewController.navigationItem.title = @"Add Tag";
    tagViewController.searchDisplayController.searchBar.text = tagViewController.searchDisplayController.searchBar.text;
    [tagViewController.tableView reloadData];
    tagPopover.popoverContentSize = CGSizeMake(900, 800);
    [tagPopover presentPopoverFromRect:addTagButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
}

//called on subject load and after recording stopped
-(void)preparePlayback{
    [self initializePlayer];
    //if an audio file exists then update the view
    if (self.audioPlayer)
	{
        [self updateViewForPlayerInfo:audioPlayer];
		[self updateViewForPlayerState:audioPlayer];
	}else{
        //if there is no audio yet then dont let play happen
        playButton.enabled = NO;
        durationLabel.text = @"0.00";
        progressBar.value = 0;
        [timelineView removeFromSuperview];
        timelineView = nil;
    }
}
//used for when creating tags.
-(NSTimeInterval)currentTime{
    if(recording){
        return audioRecorder.currentTime;
    }else{
        return audioPlayer.currentTime;
    }
}


-(void)tagViewController:(TagViewController*)tvc didChooseTag:(NSString*)title{
    NSLog(@"didChooseTag: %@",title);
    
    NSDictionary* d = [NSDictionary dictionaryWithObjectsAndKeys:title,@"title",
                       [NSNumber numberWithDouble:[self currentTime]] ,@"time",nil];
    [tags addObject:d];
    //save them
    self.subject.tags = tags;
    //make the dot appear
    [self redrawTimeline];
    //make the tag appear if we are paused
    [self reloadTagsForTime:[self currentTime]];
    
    //update analysis view if this tag is in the current choice
    [analysisViewController updateForTag:title];
    [tagPopover dismissPopoverAnimated:YES];
}

-(void)tagViewController:(TagViewController*)tvc didCreateTag:(NSString*)title{
    NSLog(@"didCreateTag: %@",title);
    NSMutableArray* studyTags = self.study.tags;
    if(!studyTags){
        studyTags = [NSMutableArray array];
    }
    [studyTags addObject:title];
    self.study.tags = studyTags;
    //do the normal stuff
    [self tagViewController:tvc didChooseTag:title];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    if(!colors){
        colors = [[NSArray alloc]initWithObjects:[UIColor redColor]
                  
                  ,[UIColor greenColor]
                  
                  ,[UIColor blueColor]
                  
                  ,[UIColor cyanColor]
                  
                  ,[UIColor yellowColor]
                  
                  ,[UIColor magentaColor]
                  
                  ,[UIColor orangeColor]
                  
                  ,[UIColor purpleColor]
                  
                  ,[UIColor brownColor], nil];
    }
    
    // Do any additional setup after loading the view from its nib.
    [progressBar setMinimumTrackImage:[UIImage imageNamed:@"nothing.png"] forState:UIControlStateNormal];
    [progressBar setMaximumTrackImage:[UIImage imageNamed:@"nothing.png"] forState:UIControlStateNormal];
    [progressBar setThumbImage:[UIImage imageNamed:@"Ruler_Playhead.png"] forState:UIControlStateNormal];
    progressBar.minimumValue = 0.0;
    
    //[mainView addSubview:recordingViewController.view];
    
    //set the initial subject.
    NSArray* subjs = self.study.subjects;
    if([subjs count]){
        self.subject = [subjs objectAtIndex:0];
    }else{
        self.subject = [self.study createSubject];
    }
    [self loadSubject];
    
    //restore either view from last time
    NSDictionary* studyDictionary = self.study.dictionary;
    int i = [[studyDictionary objectForKey:@"mode"] intValue];
    modeSegmentedControl.selectedSegmentIndex = i;
    [self switchToView:i animated:NO]; // this loads the views
}

-(IBAction)newSubjectTapped:(id)sender{
    //change subject in recording view and reset everything
    [subjectsPopover dismissPopoverAnimated:YES];
    self.subject = [self.study createSubject];
    [self loadSubject];
}

-(void)selectSubject:(Subject*)subject{
    //save current
    [self saveSubject];
    self.subject = subject;
    [self loadSubject];
    [subjectsPopover dismissPopoverAnimated:YES];
}

//subjects or tags
-(IBAction)subjectsButtonPressed:(UIBarButtonItem*)sender{
    UIBarButtonItem* subjectsButton = sender;
    
    if(modeSegmentedControl.selectedSegmentIndex == 0){ // recording
        [self saveSubject];
        if (subjectsPopover == nil) {
            //SubjectsViewController* s = [[SubjectsViewController alloc] initWithNibName:@"SubjectsViewController" bundle:nil];
            subjectsPopover = [[UIPopoverController alloc] initWithContentViewController:subjectsNavigationController];
            //		[subjectsPopover setPopoverController:popover];
        }
        if([subjectsPopover  isPopoverVisible]){
            [subjectsPopover dismissPopoverAnimated:YES];
        }else{
            subjectsViewController.study = self.study;
            subjectsViewController.subject = self.subject;
            [subjectsPopover presentPopoverFromBarButtonItem:subjectsButton permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        }
    }else{ // analysis
        [self.analysisViewController tagButtonPressed:sender];
    }
}

-(void)playSubject:(Subject*)sub tag:(NSDictionary*)tag{
    NSTimeInterval time = [[tag objectForKey:@"time"] doubleValue];
    time-= TAG_TIME;
    if(time<0){
        time = 0;
    }
    if(![self.subject.identifier isEqualToString:sub.identifier]){
        //change subject
        [self selectSubject:sub];
        [self startPlayback];
        self.audioPlayer.currentTime = time;
    }else{
        self.audioPlayer.currentTime = time;
        [self startPlayback];
    }
    //start playing at the tag's time
    
    
    //set the play head
    //    [self startPlayback];
    //  [self performSelector:@selector(startPlayback) withObject:nil afterDelay:0];
    
}

-(void)saveSubject{
    //if recording stop
    if(recording){
        [self stopRecording];
    }else{
        [self.audioPlayer stop];
        self.audioPlayer = nil;   
        [self updateViewForPlayerState:self.audioPlayer]; //stop the timer
    }
    
    [recordingViewController saveSubject];
    //save tags
    self.subject.tags = tags;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [playButton release];
	[volumeSlider release];
	[progressBar release];
	[currentTimeLabel release];
	[durationLabel release];
	[lvlMeter_in release];
	
	[updateTimer release];
	[audioPlayer release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}




@end
