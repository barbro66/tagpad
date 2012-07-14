//
//  AnalysisViewController.m
//  TagPad
//
//  Created by Malcolm Hall on 09/05/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AnalysisViewController.h"
#import "Subject.h"
#import "Study.h"
#import "StudyViewController.h"
#import "AnalysisCell.h"
#import "TagBarButton.h"
#import "TagViewController.h"
#import "NSString+md5.h"

@implementation AnalysisViewController
@synthesize analysisCell;

-(void)tagButtonPressed:(UIBarButtonItem*)tagButton{
    if([chooseTagPopover isPopoverVisible]){
        [chooseTagPopover dismissPopoverAnimated:YES];
    }else{
        
        if(!chooseTagPopover){
            chooseTagPopover = [[UIPopoverController alloc] initWithContentViewController:chooseTagNavigationController];
        }
        NSMutableArray* aa = studyView.study.tags;
        tagViewController.navigationItem.title = @"Filter Tags";
        tagViewController.listContent = aa;
        tagViewController.canCreateTags = NO;
        tagViewController.searchDisplayController.searchBar.text = tagViewController.searchDisplayController.searchBar.text;
        [tagViewController.tableView reloadData];
        chooseTagPopover.popoverContentSize = CGSizeMake(900, 800);
        [chooseTagPopover presentPopoverFromBarButtonItem:tagButton permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }
}

-(IBAction)chooseTagDone:(id)sender{
    [chooseTagPopover dismissPopoverAnimated:YES];
}

//check if the tag is one of the selected ones in the tag chooser and if so reload the data
-(void)updateForTag:(NSString*)title{
    if(![tagViewController.selectedTags count] || [tagViewController.selectedTags containsObject:title]){
        [self updateTags];
    }
}

-(void)tagViewController:(TagViewController*)tvc didChooseTag:(NSString*)title{
  [self updateTags];
}

-(IBAction)clearTagsPressed:(id)sender{
    [tagViewController.selectedTags removeAllObjects];
    tagViewController.searchDisplayController.searchBar.text = tagViewController.searchDisplayController.searchBar.text;
    [tagViewController.tableView reloadData];
    [self updateTags];
}

-(void)updateTags{
    if(!subjects){
        subjects = [[NSMutableArray alloc] init];
    }
    [subjects removeAllObjects];

    BOOL noFilter = [tagViewController.selectedTags count] == 0;
    NSLog(@"Filter? %d",noFilter);
    //build the data to display
    //adds all subjects and matching tags
    NSArray* s = [studyView.study subjects];
    for(Subject* subject in s){
        NSMutableArray* tags = [NSMutableArray array];
        if(noFilter){
            [tags addObjectsFromArray:subject.tags];
        }
        else{
            for(NSString* title in tagViewController.selectedTags){ 
                for(NSDictionary* tagDict in subject.tags){
                    if([[tagDict objectForKey:@"title"] isEqualToString:title]){
                        [tags addObject:tagDict];
                    }
                }
            }
        }
        
        if([tags count]){
            //sort tags by time
            NSArray* sortedTags = [tags sortedArrayUsingComparator:(NSComparator)^(id a, id b) {
                NSDictionary* tag1 = (NSDictionary*)a;
                NSDictionary* tag2 = (NSDictionary*)b;
                NSTimeInterval time1 = [[tag1 objectForKey:@"time"] doubleValue];
                NSTimeInterval time2 = [[tag2 objectForKey:@"time"] doubleValue];
                return time1 > time2; 
            }];
            NSDictionary* d = [NSDictionary dictionaryWithObjectsAndKeys:sortedTags, @"tags",
                               subject,@"subject",nil];
            [subjects addObject:d];
        }
    }
    [self.tableView reloadData];
    [self selectCurrentSubject];

}

-(void)selectCurrentSubject{

    //highlight the row for the current audio file.
    int i = 0;
    for(NSDictionary* d in subjects){
        Subject* subject = [d objectForKey:@"subject"];
        if([subject.codename isEqualToString:studyView.subject.codename]){
            //set the right one selected
            [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
            return;
        }
        i++;
    }
    if([subjects count]){
    //if we get here then the currently loaded subject no longer appears in the table so just select the first one
        NSIndexPath* firstRow = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView selectRowAtIndexPath:firstRow animated:NO scrollPosition:UITableViewScrollPositionNone];
        [self tableView:self.tableView didSelectRowAtIndexPath:firstRow];
    }
    
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
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

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateTags];
    [self selectCurrentSubject];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [subjects count];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    float f = 68.0f/255.0f;
    cell.backgroundColor = [UIColor colorWithRed:f green:f blue:f alpha:1];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"AnalysisCell";
    
    AnalysisCell *cell = (AnalysisCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"AnalysisCell" owner:self options:nil];
        cell = analysisCell;
        self.analysisCell = nil;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
       // cell.contentView.backgroundColor = [UIColor grayColor];
    }
    NSDictionary* subjectDict = [subjects objectAtIndex:indexPath.row];
    Subject* subject = [subjectDict objectForKey:@"subject"];
   
    // Configure the cell...
    
    UILabel* subjectLabel = cell.subjectLabel;
    UIView* tagBar = cell.tagBar;
    for(UIView* v in tagBar.subviews){
        [v removeFromSuperview];
    }
    subjectLabel.text = [subject displayName];
    
    NSArray* tags = [subjectDict objectForKey:@"tags"];
    NSMutableArray* items = [NSMutableArray array];
    
    for(NSDictionary* tag in tags){
        NSString* title = [tag objectForKey:@"title"];
        TagBarButton *tagButton = [TagBarButton buttonWithType:UIButtonTypeCustom];
        tagButton.opaque = NO;
        [tagButton setFont:[UIFont boldSystemFontOfSize:13]];
        CGSize stringsize = [title sizeWithFont:[UIFont boldSystemFontOfSize:13]]; 
        
        NSTimeInterval tagTime = [[tag objectForKey:@"time"] doubleValue];
        double xx = tagTime * subject.durationPerPixel;
        
        //or whatever font you're using
        [tagButton setFrame:CGRectMake(xx,6,stringsize.width + 15, 25)];
        
        [tagButton setTitle:title forState:UIControlStateNormal];
        //playButton.backgroundColor = [UIColor blueColor];
        [tagButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        UIImage *buttonImageNormal = [UIImage imageNamed:@"compose_atombw.png"];
        
        int x = [title md52][0];
        UIColor* c = [studyView.colors objectAtIndex: x % (int)[studyView.colors count]];
        
        c = [UIColor colorWithCGColor:CGColorCreateCopyWithAlpha([c CGColor],0.4)];
        
        buttonImageNormal = [buttonImageNormal colorizeWithColor:c];
        
        UIImage *strechableButtonImageNormal = [buttonImageNormal stretchableImageWithLeftCapWidth:12 topCapHeight:0];
        
        [tagButton setBackgroundImage:strechableButtonImageNormal forState:UIControlStateNormal];

        [tagButton addTarget:self action:@selector(tagTouchDown:) forControlEvents:UIControlEventTouchDown];
        
        tagButton.subject = subject;
        tagButton.tag = tag;
        
        [tagBar addSubview:tagButton];
    }
    return cell;
}

-(void)tagTouchUpInside:(id)sender{
     NSLog(@"tagTouchUpInside");
    TagBarButton* item = (TagBarButton*)sender;
    [studyView playSubject:item.subject tag:item.tag];
    [self selectCurrentSubject];
    [NSObject cancelPreviousPerformRequestsWithTarget:studyView selector:@selector(showDeleteTag:) object:sender];
}


-(void)tagTouchDown:(id)sender{
    NSLog(@"tagTouchDown");
    [sender addTarget:self action:@selector(tagTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    //pause so it doesn't dissapear
    [studyView pausePlayback];
    [studyView performSelector:@selector(showDeleteTag:) withObject:sender afterDelay:1];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
    
    NSDictionary* subjectDict = [subjects objectAtIndex:indexPath.row];
    if(!subjectDict)
        return;
    Subject* subject = [subjectDict objectForKey:@"subject"];
    [studyView selectSubject:subject];
}

@end
