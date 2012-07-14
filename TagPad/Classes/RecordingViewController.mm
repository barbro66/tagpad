//
//  RecordingViewController.m
//  TagPad
//
//  Created by Malcolm Hall on 27/03/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RecordingViewController.h"
#import "SubjectsViewController.h"
#import "AnswersController.h"
#import "NSIndexPath+malc.h"
#import "StudyViewController.h"
#import "Product.h"
#import "Study.h"
#import "Subject.h"
#import "MyCell.h"

@implementation RecordingViewController
@synthesize delegate,myCell,currentIndex,data,recordingStamps,answers;
@synthesize tableView = _tableView;

//can be valid or nil
-(void)timelineChangedIndexPath:(NSIndexPath *)n
{
    [self tableView:_tableView didSelectRowAtIndexPath:n];
}


#pragma mark Recording routines

-(void)startRecording{
    //init the stamps array if necessary
    self.recordingStamps = [NSMutableArray arrayWithArray: studyView.subject.stamps];
    if(!self.recordingStamps){
        self.recordingStamps = [NSMutableArray array];
    }
    
    NSDictionary* lastStamp = [self.recordingStamps lastObject];
    NSString* lastStampIndex = [lastStamp objectForKey:@"index"];
    
    //if this row isn't selected then select it
    if(lastStamp && ![self.tableView indexPathForSelectedRow]){
        [self tableView:self.tableView didSelectRowAtIndexPath:[NSIndexPath fromString:lastStampIndex]];
    }
    
    //create a new timestamp
    if(self.currentIndex){
        //check if the current stamp is different from the last recording stamp
        NSDictionary* lastStamp = [self.recordingStamps lastObject];
        BOOL makeStamp = YES;
        if(lastStamp){
            NSString* lastStampIndex = [lastStamp objectForKey:@"index"];
            if([lastStampIndex isEqualToString:[currentIndex toString]]){
                makeStamp = NO;
            }
        }
        //don't make a new stamp if it hasn't changed while recording was stopped.
        if(makeStamp){
            NSDictionary* d = [NSDictionary dictionaryWithObjectsAndKeys:[currentIndex toString],@"index",
                           [NSNumber numberWithDouble:studyView.recordingDuration],@"time",nil];
            [self.recordingStamps addObject:d];
        }
    }
}

//called when its stopped
-(void)stopRecording{
    //stamps are saved when recording is ended
    studyView.subject.stamps = self.recordingStamps;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	NSDictionary* sect = [[data objectForKey:@"sections"] objectAtIndex:section];
	NSArray* questions = [sect objectForKey:@"questions"];
	return [questions count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
	return [[data objectForKey:@"sections"] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
	NSString* sectionTitle = [[[data objectForKey:@"sections"] objectAtIndex:section] objectForKey:@"title"];
	return [NSString stringWithFormat:@"%d: %@",section + 1,sectionTitle];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *MyIdentifier = @"MyIdentifier";
	
    MyCell *cell = (MyCell*)[tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"MyCell" owner:self options:nil];
        cell = myCell;
        self.myCell = nil;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

	NSDictionary* section = [[data objectForKey:@"sections"] objectAtIndex:indexPath.section];
	NSArray* questions = (NSArray*)[section objectForKey:@"questions"];
	
	UILabel* numberLabel = cell.numberLabel;
	numberLabel.text = [NSString stringWithFormat:@"%d.%d:",indexPath.section + 1,indexPath.row + 1];
    
	UILabel* questionLabel = cell.questionLabel;
    NSDictionary* questionDict = [questions objectAtIndex:indexPath.row];
	questionLabel.text = [questionDict objectForKey:@"question"];
	questionLabel.frame = CGRectMake(questionLabel.frame.origin.x, questionLabel.frame.origin.y, 369, 29);
	[questionLabel sizeToFit];
    
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	NSDictionary* section = [[data objectForKey:@"sections"] objectAtIndex:indexPath.section];
	NSArray* questions = (NSArray*)[section objectForKey:@"questions"];
	UIFont *cellFont = [UIFont fontWithName:@"Helvetica" size: 18];
    CGSize constraintSize = CGSizeMake(369, MAXFLOAT);
    NSDictionary* questionDict = [questions objectAtIndex:indexPath.row];
    NSString* question = [questionDict objectForKey:@"question"];
    CGSize labelSize = [question sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
    
    return labelSize.height + 20;
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(self.currentIndex && indexPath.row == currentIndex.row && indexPath.section == currentIndex.section){
        cell.backgroundColor = [UIColor whiteColor];
    }else{
        cell.backgroundColor = [UIColor grayColor];
    }
}

-(void)saveCurrentAnswer{
    if(self.currentIndex){
        if([answersController.tableView superview]){ // if table is showing
            [answers setObject:[answersController answers] forKey:[currentIndex toString]];
        }else{
            [answers setObject: answerTextView.text forKey:[currentIndex toString]];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //save text in index path
    if(self.currentIndex){
        [self saveCurrentAnswer];
        if([answersController.tableView superview]){ // if table is showing
            [answers setObject:[answersController answers] forKey:[currentIndex toString]];
        }else{
            [answers setObject: answerTextView.text forKey:[currentIndex toString]];
        }
        [tableView cellForRowAtIndexPath:currentIndex].backgroundColor = [UIColor grayColor];
    }
   	
    if(indexPath){
        [tableView cellForRowAtIndexPath:indexPath].backgroundColor = [UIColor whiteColor];
        self.currentIndex = indexPath;
        //get the index before and scroll that to the top
        int prevCellRow = indexPath.row;
        int prevCellSection = currentIndex.section;
        if(indexPath.row > 0){
            prevCellRow--;
        }else{
            if(prevCellSection > 0){
                prevCellSection--;
                //get last row in section
                prevCellRow = [tableView numberOfRowsInSection:prevCellSection] - 1;
            }
        }
        NSIndexPath* prevCellIndex = [NSIndexPath indexPathForRow:prevCellRow inSection:prevCellSection];
        
        [_tableView selectRowAtIndexPath:prevCellIndex animated:YES scrollPosition:UITableViewScrollPositionTop];
        
        
        NSDictionary* section = [[data objectForKey:@"sections"] objectAtIndex:indexPath.section];
        NSArray* questions = (NSArray*)[section objectForKey:@"questions"];
        NSDictionary* questionDict = [questions objectAtIndex:indexPath.row];
        NSArray* choices = [questionDict objectForKey:@"choices"];
        answersController.choices = choices;
        
        [answersController.tableView setContentOffset:CGPointMake(0, 0) animated:NO];
        [answersController.tableView reloadData];
        [answersController.tableView flashScrollIndicators];
        if([choices count]){
            //asnwers should be array
            [answerView addSubview:answersController.tableView];
            [answersController setAnswers:[answers objectForKey:[currentIndex toString]]];
            [answerTextView resignFirstResponder];
        }else{
            //answers should be string
            [answersController.tableView removeFromSuperview];
            answerTextView.text = [answers objectForKey:[currentIndex toString]];
            if (answerTextView.text.length==0) {
                [emptyLabel setHidden: NO];
            }else{
                [emptyLabel setHidden: YES];
            }
        }
        
        //if recording then log timestamps
        if([studyView.audioRecorder isRecording]){
            NSTimeInterval n = [studyView recordingDuration];
            NSDictionary* d = [NSDictionary dictionaryWithObjectsAndKeys:[currentIndex toString],@"index",
                               [NSNumber numberWithDouble:n] ,@"time",nil];
            [recordingStamps addObject:d];
            
            
        }
        /*
        else{
            //otherwise move the playhead to first instance of that answer on the timeline
            NSString* currentIndexString = [currentIndex toString];
            for(NSDictionary* d in studyView.subject.stamps){
                if([[d objectForKey:@"index"] isEqualToString:currentIndexString]){
                    //double t = [[d objectForKey:@"time"] doubleValue];
                    [studyView playSubject:studyView.subject tag:d early:NO];
                    break;
                }
                     
            } 
        }
         */
       
        
    }else{
        //clear everything
        self.currentIndex = nil;
        [_tableView setContentOffset:CGPointMake(0, 0) animated:YES];
        [answersController.tableView removeFromSuperview];
        answerTextView.text = @"";
        
    }
}

-(IBAction)textViewDidBeginEditing:(UITextView*)sender{
    [emptyLabel setHidden: YES];
    
}

-(IBAction)textViewDidEndEditing:(UITextView*)sender{
    [emptyLabel setHidden: YES];
    // [sender resignFirstResponder];
    
}

-(IBAction)nextButtonPressed:(UIButton*)sender{
    NSInteger nSections = [self.tableView numberOfSections];
    NSIndexPath *nextIndexPath = nil;
    if(!self.currentIndex){
        nextIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    }
    else{
        for (int j=currentIndex.section; j<nSections; j++) {
            NSInteger nRows = [self.tableView numberOfRowsInSection:j];
            int start = 0;
            //if still in the current section then start from the current row
            if(currentIndex.section == j){
               start = (currentIndex.row + 1 < nRows ? currentIndex.row + 1 : nRows);
            }
            //loop the remaining rows until we get an index
            for (int i=start; i<nRows; i++) {
                nextIndexPath = [NSIndexPath indexPathForRow:i inSection:j];
                break;
            }
            //got one so break.
            if(nextIndexPath){
                break;
            }
        }
    }
    if(nextIndexPath){
        [self tableView:_tableView didSelectRowAtIndexPath:nextIndexPath];
    }
    [emptyLabel setHidden:YES];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    

    //hopefully load subject has already been called
    [self refreshView];
    
    //todo remove
    [answersController.tableView removeFromSuperview];
    answersController.tableView.layer.cornerRadius = 5;
    answerTextView.layer.cornerRadius = 5;
  //  progressBar.frame = CGRectMake(progressBar.frame.origin.x, progressBar.frame.origin.y, progressBar.frame.size.width, 50);
}

//this resets the UI and audio player for the new subject
-(void)loadSubject{
    self.currentIndex = nil;
    
    //loads up the questions
    self.data = studyView.study.dictionary;
        //  self.currentInfdex = [NSIndexPath indexPathForRow:0 inSection:0];
    
    //Path get the path to MyTestList.plist
    //NSString *path = [[NSBundle mainBundle] pathForResource:@"questions" ofType:@"plist"];
    //Next create the dictionary from the contents of the file.
    //data = [[NSDictionary alloc] initWithContentsOfFile:path];
    
    //[_tableView selectRowAtIndexPath:currentIndex animated:NO scrollPosition:UITableViewScrollPositionTop];
    
    //load old answers
    self.answers = studyView.subject.answers;
    if(!answers){
        self.answers = [NSMutableDictionary dictionary];
    }
    [self refreshView]; // if view hasn't loaded this is redundant
}

-(void)refreshView{
    answerTextView.text = nil;
    [answersController.tableView removeFromSuperview];
    
    NSDictionary* sub = studyView.subject.dictionary;
    nameTextField.placeholder = studyView.subject.codename;
    nameTextField.text = [sub objectForKey:@"name"];
    if(!nameTextField.text || [nameTextField.text isEqualToString:@""]){ // prevent probs with dicts later on
       // nameTextField.secureTextEntry = NO;
    }else{
       // nameTextField.secureTextEntry = YES;
    }
    infoTextField.text = [sub objectForKey:@"info"];
    if(!infoTextField.text){
        infoTextField.text = @"";
    }
    [self.tableView reloadData];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [_tableView reloadData];
}


-(void)saveSubject{
    if(studyView.subject){ // safety
        NSMutableDictionary* d = studyView.subject.dictionary;
        if(nameTextField.text){
            [d setObject:nameTextField.text forKey:@"name"];
        }
        if(infoTextField.text){
            [d setObject:infoTextField.text forKey:@"info"];
        }
        [studyView.subject setDictionary:d];
        
        if(self.currentIndex)
        {
            [self saveCurrentAnswer];
        }
        //save new answers
        studyView.subject.answers = self.answers;
    }
}


- (void)dealloc
{
	
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}



@end
