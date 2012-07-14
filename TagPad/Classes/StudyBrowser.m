//
//  FileChooser.m
//  TagPad
//
//  Created by Malcolm Hall on 27/03/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "StudyBrowser.h"
#import "RecordingViewController.h"
#import "AudioSplitter.h"
#import "NSIndexPath+malc.h"
#import "MBProgressHUD.h"
#import "StudyViewController.h"
#import "Study.h"
#import "Subject.h"
#import "DLAlert.h"
#include <CommonCrypto/CommonDigest.h>

static int kTrashAlertSheet = 1;
static int kImportAlertSheet = 2;

@implementation StudyBrowser
@synthesize delegate,uploads,splits,studiesAndButtons,uploadHistory,currentlyUploading;

-(IBAction)shareTapped:(id)sender{
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    HUD = [[MBProgressHUD alloc] initWithWindow:window];
    [window addSubview:HUD];
    HUD.delegate = self;
    [HUD setLabelText:@"Processing audio..."];
    [HUD show:YES];
    //NSString* p = [[NSBundle mainBundle] pathForResource:@"questions.txt" ofType:nil];
    //[nebulous uploadFile:p toCloudPath: @"/cock/macccc.txt"];
    self.splits = [NSMutableArray array];
    
    // Load in the uploadHistory for this study -bb     
    self.uploadHistory = [[[self currentStudy] dictionary] objectForKey:@"uploadHistory"];
    
    //survey name folder
    NSArray* subjects = [[self currentStudy] subjects];
    for(Subject* subject in subjects){
        NSString* folder = [subject.dictionary objectForKey:@"folder"]; // the UUID of the subject
        NSNumber* inc = [subject.dictionary objectForKey:@"increment"];
       // NSString* subjectId = [[studyDict objectForKey:@"title"] stringByAppendingString:[inc stringValue]];
        
        NSString* audioFile = subject.audioFile;
        
        NSArray* stamps = subject.stamps;
        
      //  if([stamps count] == 0) //safety
        //    continue;
        
        /*
        //get the first stamp and check if it is not zero which means we started with no question selected
        //and if it is make it so the intro goes out to 0.0.m4a
        NSDictionary* prevStamp = [stamps objectAtIndex:0];
        NSNumber* start = [prevStamp objectForKey:@"time"];
        if([start doubleValue] > 2){ // if intro is greater than 2 seconds we'll save it.
            NSString* dest = [[audioFile stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"0.0.m4a"];
            NSArray* split = [NSArray arrayWithObjects:audioFile,dest,0,start, nil]; // go from zero to the start
            [self.splits addObject:split];
        }
        prevStamp = nil;
        for(NSDictionary* stamp in stamps){
            if(prevStamp){
                start = [prevStamp objectForKey:@"time"];
                NSString* index = [prevStamp objectForKey:@"index"];
                NSIndexPath* indexPath = [NSIndexPath fromString:index];
                NSString* questionNumber = [NSString stringWithFormat:@"%d.%d",indexPath.section+1,indexPath.row+1];
                NSNumber* end = [stamp objectForKey:@"time"];
                NSString* dest = [[audioFile stringByDeletingLastPathComponent] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.m4a",questionNumber]];
                NSArray* split = [NSArray arrayWithObjects:audioFile,dest,start,end, nil];
                [self.splits addObject:split];
                NSLog(@"%@ %@ %@",index, start,end);
            }
            prevStamp = stamp;
        }
        //save last segment
        */
        
        for(int i=0;i<[stamps count];i++){
            NSDictionary* stamp = [stamps objectAtIndex:i];
            NSNumber* start = [stamp objectForKey:@"time"];
            //check if first timestamp is non zero and if it is save the intro to 0.0.m4a 
            if(i == 0 && [start doubleValue] > 2){
                NSString* introdest = [[audioFile stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"0.0.m4a"];
                NSArray* introsplit = [NSArray arrayWithObjects:audioFile,introdest,[NSNumber numberWithDouble:0],start, nil];
                [self.splits addObject:introsplit];
               
            }
            //save the normal section
            NSNumber* end = nil;
            if(i < [stamps count] - 1){ // get the end as the next time stamp
                end = [[stamps objectAtIndex:i+1] objectForKey:@"time"];
            }else{
                //use the end of the file
                end = [NSNumber numberWithDouble: subject.recordingDuration];
            }
            NSString* index = [stamp objectForKey:@"index"];
            NSIndexPath* indexPath = [NSIndexPath fromString:index];
            NSString* questionNumber = [NSString stringWithFormat:@"%d.%d",indexPath.section+1,indexPath.row+1];
            
            NSString* dest = [[audioFile stringByDeletingLastPathComponent] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.m4a",questionNumber]];
            
            //check if that dest has already been used and if so put the time after the question number in filename
            for(NSArray* prevSplit in splits){
                if([[prevSplit objectAtIndex:1] isEqualToString:dest]){
                    dest = [[audioFile stringByDeletingLastPathComponent] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@@%d.m4a",questionNumber,[start intValue]]];
                    break;
                }
            }
            
            //delete the dest in case it existed previously so our audio append routine works in nextSplit
            NSError* error = nil;
            //[[NSFileManager defaultManager] removeItemAtPath:dest error:&error];
            NSArray* split = [NSArray arrayWithObjects:audioFile,dest,start,end, nil];
            [self.splits addObject:split];
            
        }
        //
    }
    [self nextSplit];
}

-(void)nextSplit{
    //if none left hide UI
    if(![splits count]){
        [self performSelectorOnMainThread:@selector(beginUploading) withObject:nil waitUntilDone:NO];
        return;
    }
    NSArray* array = [splits objectAtIndex:0];
    NSString* audioFile = [array objectAtIndex:0];
    NSString* dest = [array objectAtIndex:1];
    NSNumber* start = [array objectAtIndex:2];
    NSNumber* end = [array objectAtIndex:3];
    
    
    
    [[AudioSplitter alloc] initWithSoundFileURL:[NSURL fileURLWithPath:audioFile] destination:[NSURL fileURLWithPath:dest] start:[start doubleValue] end:[end doubleValue] delegate:self];
    [splits removeObjectAtIndex:0];
}

- (void)audioSplitterDidFinish:(AudioSplitter *)audioSplitter splitFile:(NSURL*)splitFile{
    [audioSplitter release];
    [self nextSplit];
}


-(void)beginUploading{
    [HUD setLabelText:@"Uploading to DropBox..."];
    self.uploads = [NSMutableArray array];
    NSDictionary* studyDict = [[self currentStudy] dictionary];
    NSString* dropboxPath = [studyDict objectForKey:@"dropboxPath"];
    NSArray* subjects = [self currentStudy].subjects;
    //survey name folder
    
    NSMutableString* allAnswers=[NSMutableString string];
    NSArray* sections=[studyDict objectForKey:@"sections"];
    Study* study=[self currentStudy];
    NSString* studiesDirectory=[[study documentsDirectory] stringByAppendingPathComponent: study.identifier ];
    int x=0; int y=0;
    NSMutableArray* tags=[NSMutableArray array];
    
    for(Subject* subject in subjects){
        NSString* folder = [subject.dictionary objectForKey:@"folder"];
        NSNumber* inc = [subject.dictionary objectForKey:@"increment"];
        NSString* subjectId = [[studyDict objectForKey:@"title"] stringByAppendingString:[inc stringValue]];
        NSDictionary* answers = subject.answers;
        NSMutableString* answerString = [NSMutableString string];
        
        // **** build up allAnswers string which will be save as the csv file of all the answers -bb
        [allAnswers appendString:[subject displayName]];
        x=0; y=0;
        for (NSDictionary* section in sections) {
            y=0;
            NSArray* questions=[section objectForKey:@"questions"];
            for (NSDictionary* question in questions)
            {
                NSString* path=[NSString stringWithFormat:@"%d.%d",(x),(y)];
                NSString* readPath=[NSString stringWithFormat:@"%d.%d",(x+1),(y+1)];
                id answer=[answers objectForKey:path];
                [allAnswers appendString: @","];
                
                if (answer)  {
                    if([answer isKindOfClass:[NSString class]]){
                        [allAnswers appendString:([answer stringByReplacingOccurrencesOfString: @"," withString:@"-"])];
                        // as its a csv file you cant have commas in the answers
                    }else{
                        NSArray* arr = (NSArray*)answer;
                        for(NSString* arrayItem in arr){
                            [allAnswers appendString:(arrayItem)];
                        }
                    }
                } 
                y++;
                
            }
            x++;
        }
        
        // **** create individual answers files for each subject
        [allAnswers appendString:@"\n"];
        [answerString appendFormat:@"Subject Name: %@\n",[subject displayName]];
        [answerString appendFormat:@"Subject Info: %@\n\n",[subject.dictionary objectForKey:@"info"]];
        NSArray* sortedQuestions = [[answers allKeys] sortedArrayUsingComparator:(NSComparator)^(id a, id b) { 
            return [a compare:b options:NSNumericSearch]; 
        }];        
        
        for(NSString* key in sortedQuestions){
            NSIndexPath* q = [NSIndexPath fromString:key];
            [answerString appendFormat:@"%d.%d\n",q.section+1,q.row+1];
            id a = [answers objectForKey:key];
            if([a isKindOfClass:[NSString class]]){
                [answerString appendString:a];
                [answerString appendString:@"\n"];
            }else{
                NSArray* arr = (NSArray*)a;
                for(NSString* arrayItem in arr){
                    [answerString appendString:arrayItem];
                    [answerString appendString:@"\n"];
                }
            }
            [answerString appendString:@"\n"];
        }
        
        
        [answerString writeToFile:[[subject directory] stringByAppendingPathComponent:@"answers.txt"] atomically:NO encoding:NSUTF8StringEncoding error:nil];
        
        //Collect an array of all the tags and their details -bb
        for (NSDictionary* tag in [subject tags]) {
            NSDictionary* newTag=[NSDictionary dictionaryWithObjectsAndKeys: [subject displayName],@"subject",[tag objectForKey:@"title"],@"title",[tag objectForKey:@"time"],@"time",nil];
            [tags addObject:newTag];
        }

        //upload every audio file in the folder
        NSString* cloudFolder = [NSString stringWithFormat:@"%@/%@",dropboxPath,[subject displayName]];

        for(NSString* filename in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[subject directory] error:nil]){
            if([[filename pathExtension] isEqualToString:@"m4a"] || [filename isEqualToString:@"answers.txt"]){
                NSString* localFile = [[subject directory] stringByAppendingPathComponent:filename];
                NSString* cloudFile = [cloudFolder stringByAppendingPathComponent:filename];
                NSArray* array = [NSArray arrayWithObjects:localFile, cloudFile, nil];
                [self.uploads addObject:array];
            }
        }
        
        
        //queue each question audio file   
    }
    
    //Export AllAnswers.csv and upload to dropbox -bb
    [allAnswers writeToFile: [studiesDirectory stringByAppendingPathComponent:@"AllAnswers.csv"] atomically:NO encoding:NSUTF8StringEncoding error:nil];            
    NSString* localFile = [studiesDirectory stringByAppendingPathComponent:@"AllAnswers.csv"];
    NSString* cloudFile = [dropboxPath stringByAppendingPathComponent:@"AllAnswers.csv"];
    NSArray* array = [NSArray arrayWithObjects:localFile, cloudFile, nil];
    [self.uploads addObject:array];
    
    //Export AllTags.csv using tags and upload to dropbox -bb
    NSMutableString* tagFile= [NSMutableString string];
    [tags sortUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES],[NSSortDescriptor sortDescriptorWithKey:@"subject" ascending:YES],nil]];
    
    //Sort tags by tag name and then by subject -bb
    for (NSDictionary* tag in tags) [tagFile appendFormat:@"%@,%@,%@\n",[tag valueForKey:@"title"],[tag valueForKey:@"subject"],(NSNumber*) [tag valueForKey:@"time"]];
    [tagFile writeToFile: [studiesDirectory stringByAppendingPathComponent:@"AllTags.csv"] atomically:NO encoding:NSUTF8StringEncoding error:nil];
    
    localFile = [studiesDirectory stringByAppendingPathComponent:@"AllTags.csv"];
    cloudFile = [dropboxPath stringByAppendingPathComponent:@"AllTags.csv"];
    array = [NSArray arrayWithObjects:localFile, cloudFile, nil];
    [self.uploads addObject:array];
    
    
    
    /*
     localFile = allTagsPath;
     cloudFile = [dropboxPath stringByAppendingPathComponent:@"TagList.txt"];
     array = [NSArray arrayWithObjects:localFile, cloudFile, nil];
     [self.uploads addObject:array];
     
     */ 
    
    [self nextUpload];
}

-(void)nextUpload{
    //if none left hide UI
    if(![uploads count]){
        [HUD hide:YES];
   
        [UIApplication sharedApplication].idleTimerDisabled = NO;
        
        // set the uploadHistory in the dictionary and flush it to disk -bb 
        NSMutableDictionary* mid=[[self currentStudy] dictionary];
        [mid setValue:uploadHistory forKey:@"uploadHistory"];
        [[self currentStudy] setDictionary:mid]; 
        
        
        return;
    }
    NSArray* array = [uploads objectAtIndex:0];
    NSString* localFile = [array objectAtIndex:0];
    NSString* cloudPath = [array objectAtIndex:1];
    
    // CurrentlyUploading is the current file and its size -bb
    
    NSString* currentFileSize=[NSString stringWithFormat:@"%d",[[[NSFileManager defaultManager] attributesOfItemAtPath:localFile error:nil] fileSize]];
    self.currentlyUploading=[NSArray arrayWithObjects: localFile,currentFileSize,nil];
  
    NSLog(@"%@",self.currentlyUploading);
      
        
    if (![[localFile pathExtension] isEqualToString:@"m4a"] |
        ![self.uploadHistory containsObject:self.currentlyUploading]) {     // only upload the file if its one of the text files, or it hasn't been uploaded before -bb

            
        
        [nebulous uploadFile:localFile toCloudPath:cloudPath];
        [uploads removeObjectAtIndex:0];

        //    
    } else {
        [uploads removeObjectAtIndex:0];

        [self performSelector:@selector(nextUpload) withObject:nil afterDelay:0];         // need this here to trigger nextUpload again
        
    }

}

- (void)uploadedFile:(NSString *) dropboxPath{

    // Add the details of the uploaded file to uploadHistory -bb
    
    [self.uploadHistory addObject:self.currentlyUploading];

    //cant start another upload from within an upload so push the event on the stack
    [self performSelector:@selector(nextUpload) withObject:nil afterDelay:0];
}

- (void)uploadProgress:(CGFloat)progress forFile:(NSString*)dropboxPath{
    
}

- (void)uploadFailedForFile:(NSString *) dropboxPath withError:(NSError *) error{
    NSLog(@"%@",[error description]);
    //DLAlertWithError(error);
    [HUD setLabelText:@"Possible upload errors detected..."];
   
    // If it hits an error then try and continue -bb
    
    [self performSelector:@selector(nextUpload) withObject:nil afterDelay:0];

   // [HUD hide:YES];
}

-(IBAction)surveyTapped:(id)sender{
    //[delegate studyBrowserOpen:self];
    CATransition* transition = [CATransition animation];
    transition.type = kCATransitionFade;
    transition.subtype = kCATransitionFromTop;
    [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
    
    StudyViewController* r = [[[StudyViewController alloc] initWithNibName:@"StudyViewController" bundle:nil] autorelease];
    r.study = [self currentStudy];
    lastStudyIndex = [self currentIndex];
    [self.navigationController pushViewController:r animated:NO];
    
}



- (void)loadedFile:(NSString *) dropboxPath into:(NSString*)destPath {
	BOOL result=[Study createStudyFromFile:destPath title:[[dropboxPath lastPathComponent] stringByDeletingPathExtension] dropboxPath:dropboxPath];
    if (!result) {
        UIAlertView* alert = [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not read file - incorrect format.  Please check that the file is a .txt file" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
        [alert show];
        return;
    }  
    [self reloadStudies];
    [popover dismissPopoverAnimated:NO];
    [self setCurrentIndex:0];
    [self surveyTapped:nil];
	
}

-(IBAction)helpTapped:(id)sender{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.tagpad.info/help"]];
}

- (void)loadFailedForFile:(NSString *) dropboxPath withError:(NSError*)error {
	// handle error
}



- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    static NSInteger previousPage = 0;
    CGFloat pageWidth = scrollView.frame.size.width;
    float fractionalPage = scrollView.contentOffset.x / pageWidth;
    NSInteger page = lround(fractionalPage);
    if (previousPage != page) {
        // Page has changed
        
        [self updateLabels];
        previousPage = page;
    }
}

-(void)updateLabels{
    Study* study = [self currentStudy];
    if(study){
    //NSString* title = [[Model sharedModel] titleForPackage:currentPackage];
        NSDictionary* dict = study.dictionary;
        titleLabel.text = [dict objectForKey:@"title"];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterLongStyle];
        [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
        
        [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
        editedLabel.text = [dateFormatter stringFromDate:[dict objectForKey:@"edited"]];
        [dateFormatter release];
        
        navItem.title = [NSString stringWithFormat:@"My Studies (%d of %d)",[self currentIndex] + 1,[studiesAndButtons count]];
    }else{
        titleLabel.text = @"Tap import to create a new study or tap help";
        navItem.title = @"My Studies";
    }
    trashButton.enabled = [studiesAndButtons count];
    shareButton.enabled = [studiesAndButtons count];
    editedLabel.hidden = [studiesAndButtons count] == 0;
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
    [popover release];
	[nebulous release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if (!nebulous) {
        NSString* key = @"j6cfp2br37u240m";
        NSString* secret = @"dxsw6bcv9f9wo0z";
        /*
        if([[UIDevice currentDevice].uniqueIdentifier isEqualToString:@"0e8fc1449e90602d06cd2a783fe6a7cbb176f6c5"]){
            key = @"nghqszgr40q1g06";
            secret = @"2cjqjhd5820grq4";
        }
        */
		nebulous = [[NebulousController alloc] initWithConsumerKey:key consumerSecret:secret];
		[nebulous setUploadDelegate: self];
		[nebulous setHandler:self forType:@"text"];
	}
    [self reloadStudies];
    [self setCurrentIndex:lastStudyIndex];
}

-(void)reloadStudies{
    for(UIView* v in [scrollView subviews]){
        [v removeFromSuperview];
    }
    NSArray* studies = [Study studies];
    self.studiesAndButtons = [NSMutableArray array];
    double x = 10;
    for(Study* study in studies){
        UIButton* b = [UIButton buttonWithType:UIButtonTypeCustom];
        b.frame = CGRectMake(x , 0, 640, 440);
        //b.backgroundColor = [UIColor whiteColor];
        UIImage* screenshot = [study screenshot];
        if(screenshot){
            [b setBackgroundImage:screenshot forState:UIControlStateNormal];
        }else{
            b.backgroundColor = [UIColor whiteColor];
        }
        //listen for clicks
        [b addTarget:self action:@selector(surveyTapped:) forControlEvents:UIControlEventTouchUpInside];
        [scrollView addSubview:b];
        x += 640 + 10;
        
        NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:study, @"study",b,@"button",nil];
        [studiesAndButtons addObject:dict];
    }
    scrollView.contentSize = CGSizeMake(x, 440);
    [self updateLabels];
   
   
}

-(IBAction)trashTapped:(id)sender{
    UIActionSheet* actionSheet =  [[UIActionSheet alloc] initWithTitle:nil
                                 delegate:self
                        cancelButtonTitle:nil
                   destructiveButtonTitle:@"Delete Survey"
                                          otherButtonTitles:nil];
    actionSheet.tag = kTrashAlertSheet;
    CGRect r = trashButton.frame;
    [actionSheet showFromRect:CGRectMake(r.origin.x, r.origin.y, r.size.width, 1) inView:self.view animated:YES];
    [actionSheet release];
}


-(IBAction)importTapped:(id)sender{
    //if on dropbox
    if([[DBSession sharedSession] isLinked]){
        [self showDropBox];
    }else{
        //show choices
        UIActionSheet* actionSheet =  [[UIActionSheet alloc] initWithTitle:nil
                                                                  delegate:self
                                                         cancelButtonTitle:nil
                                                    destructiveButtonTitle:nil
                                                         otherButtonTitles:@"Setup DropBox",@"Demo Study",nil];
        
        actionSheet.tag = kImportAlertSheet;
        CGRect r = importButton.frame;
        [actionSheet showFromRect:CGRectMake(r.origin.x, r.origin.y, r.size.width, 1) inView:self.view animated:YES];
        [actionSheet release];
    }
  
}

-(void)showDropBox{
    /*
     [[Model sharedModel] createStudyFromFile:[[NSBundle mainBundle] pathForResource:@"questions" ofType:@"txt"] title:@"survey"];
     [self reloadStudies];
     //   [self surveyTapped:nil];
     return;
     */
	if (popover == nil) {
		popover = [[UIPopoverController alloc] initWithContentViewController:nebulous];
        
		// allows Nebulous Controller to dismiss itself
		[nebulous setPopoverController:popover];
	}
    CGRect r = importButton.frame;
	[popover presentPopoverFromRect:CGRectMake(r.origin.x, r.origin.y, r.size.width, 1)  inView:self.view permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
    // [self surveyTapped:nil];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == -1)
        return;
    if(actionSheet.tag == kTrashAlertSheet){
        [[self currentStudy] remove];
        [self reloadStudies];
    }else{
        if(buttonIndex == 0){ // dropbox
            [self showDropBox];
        }
        else{
            NSString* path = [[NSBundle mainBundle] pathForResource:@"Demo.txt" ofType:nil];
            NSString* dropboxPath = @"/Demo Study";
            [Study createStudyFromFile:path title:@"Demo Study" dropboxPath:dropboxPath];
            [self reloadStudies];
            
            [popover dismissPopoverAnimated:NO];
            [self setCurrentIndex:0];
            [self surveyTapped:nil];
        }
    }
}

-(int)currentIndex{
    CGFloat pageWidth = scrollView.frame.size.width;
    float fractionalPage = scrollView.contentOffset.x / pageWidth;
    NSInteger page = lround(fractionalPage);
    return page;
}

-(void)setCurrentIndex:(int)index{
    CGFloat pageWidth = scrollView.frame.size.width;
    scrollView.contentOffset = CGPointMake(index * pageWidth, 0);
}
     
-(Study*)currentStudy{
    if([studiesAndButtons count] > 0){
        return [[studiesAndButtons objectAtIndex:[self currentIndex]] objectForKey:@"study"];
    }else{
        return nil;
    }
}

-(UIButton*)currentButton{
    if([studiesAndButtons count] > 0){
        return [[studiesAndButtons objectAtIndex:[self currentIndex]] objectForKey:@"button"];
    }else{
        return nil;
    }
}

- (void)hudWasHidden {
    // Remove HUD from screen when the HUD was hidded
    [HUD removeFromSuperview];
    [HUD release];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    [self updateLabels];
    UIImage* screenshot = [[self currentStudy] screenshot];
    
    UIButton* button = [self currentButton];
    if(screenshot){
        [button setBackgroundImage:screenshot forState:UIControlStateNormal];
    }else{
        button.backgroundColor = [UIColor whiteColor];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

@end
