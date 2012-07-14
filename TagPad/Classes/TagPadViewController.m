//
//  TagPadViewController.m
//  TagPad
//
//  Created by Malcolm Hall on 01/03/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TagPadViewController.h"

@implementation TagPadViewController
@synthesize myCell;

- (void)viewDidLoad {
	if(!data){
		//Path get the path to MyTestList.plist
		NSString *path = [[NSBundle mainBundle] pathForResource:@"questions" ofType:@"plist"];
		//Next create the dictionary from the contents of the file.
		data = [[NSDictionary alloc] initWithContentsOfFile:path];
	}
	bar.topItem.title = [data objectForKey:@"title"];
	[super viewDidLoad];
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
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"MyCell" owner:self options:nil];
        cell = myCell;
        self.myCell = nil;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
	
	NSDictionary* section = [[data objectForKey:@"sections"] objectAtIndex:indexPath.section];
	NSArray* questions = (NSArray*)[section objectForKey:@"questions"];
	
	UILabel* numberLabel = (UILabel*)[cell viewWithTag:1];
	numberLabel.text = [NSString stringWithFormat:@"%d.%d:",indexPath.section + 1,indexPath.row + 1];
		
	UILabel* questionLabel = (UILabel*)[cell viewWithTag:2];
	questionLabel.text = [questions objectAtIndex:indexPath.row];
	questionLabel.frame = CGRectMake(questionLabel.frame.origin.x, questionLabel.frame.origin.y, 661, 29);
	[questionLabel sizeToFit];
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	NSDictionary* section = [[data objectForKey:@"sections"] objectAtIndex:indexPath.section];
	NSArray* questions = (NSArray*)[section objectForKey:@"questions"];
	UIFont *cellFont = [UIFont fontWithName:@"Helvetica" size:24];
    CGSize constraintSize = CGSizeMake(661.0f, MAXFLOAT);
    CGSize labelSize = [[questions objectAtIndex:indexPath.row] sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
    return labelSize.height + 100;
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor grayColor];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	[tableView cellForRowAtIndexPath:indexPath].backgroundColor = [UIColor whiteColor];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_3_0){
	[tableView cellForRowAtIndexPath:indexPath].backgroundColor = [UIColor grayColor];
}

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

@end
