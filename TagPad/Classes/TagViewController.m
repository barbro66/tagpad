#import "TagViewController.h"
#import "Product.h"

@implementation TagViewController

@synthesize listContent, filteredListContent, savedSearchTerm, savedScopeButtonIndex, searchWasActive, delegate,survey,selectedTags;
@synthesize canCreateTags = _canCreateTags;

#pragma mark - 
#pragma mark Lifecycle methods

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.title = @"Tags";
	
	// create a filtered list that will contain products for the search results table.
	self.filteredListContent = [NSMutableArray arrayWithCapacity:[self.listContent count]];
	
	// restore search settings if they were saved in didReceiveMemoryWarning.
    if (self.savedSearchTerm)
	{
        [self.searchDisplayController setActive:self.searchWasActive];
        [self.searchDisplayController.searchBar setSelectedScopeButtonIndex:self.savedScopeButtonIndex];
        [self.searchDisplayController.searchBar setText:savedSearchTerm];
        
        self.savedSearchTerm = nil;
    }
	
	[self.tableView reloadData];
	self.tableView.scrollEnabled = YES;
}

- (void)viewDidUnload
{
	self.filteredListContent = nil;
}

- (void)viewDidDisappear:(BOOL)animated
{
    // save the state of the search UI so that it can be restored if the view is re-created
    self.searchWasActive = [self.searchDisplayController isActive];
    self.savedSearchTerm = [self.searchDisplayController.searchBar text];
    self.savedScopeButtonIndex = [self.searchDisplayController.searchBar selectedScopeButtonIndex];
}

- (void)dealloc
{
	[listContent release];
	[filteredListContent release];
	
	[super dealloc];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if(!self.canCreateTags || ![self.searchDisplayController.searchBar.text length] || [listContent containsObject:self.searchDisplayController.searchBar.text]){
        return 1; 
    }else{
        return 2;
    }
}

#pragma mark -
#pragma mark UITableView data source and delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	/*
	 If the requesting table view is the search display controller's table view, return the count of
     the filtered list, otherwise return the count of the main list.
	 */
    if(section == 0){
        if (tableView == self.searchDisplayController.searchResultsTableView)
        {
            return [self.filteredListContent count];
        }
        else
        {
            return [self.listContent count];
        }
    }else{
        return 1;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *kCellID = @"cellID";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellID];
	if (cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellID] autorelease];
		//cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	cell.accessoryType = UITableViewCellAccessoryNone;
	/*
	 If the requesting table view is the search display controller's table view, configure the cell using the filtered content, otherwise use the main list.
	 */
    if(indexPath.section == 0){
        cell.textLabel.textColor = [UIColor blackColor];
        //Product *product = nil;
        NSString* product = nil;
        if (tableView == self.searchDisplayController.searchResultsTableView)
        {
            product = [self.filteredListContent objectAtIndex:indexPath.row];
        }
        else
        {
            product = [self.listContent objectAtIndex:indexPath.row];
        }
        
        cell.textLabel.text = product;
        if([selectedTags containsObject:product]){
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    else{
        cell.textLabel.textColor = [UIColor blueColor];
        cell.textLabel.text = [NSString stringWithFormat: @"Add \"%@\"...",self.searchDisplayController.searchBar.text];
    }
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   // UIViewController *detailsViewController = [[UIViewController alloc] init];
	/*
	 If the requesting table view is the search display controller's table view, configure the next view controller using the filtered content, otherwise use the main list.
	 */
    if(indexPath.section == 0){
        //Product *product = nil;
        NSString* product = nil;
        if (tableView == self.searchDisplayController.searchResultsTableView)
        {
            product = [self.filteredListContent objectAtIndex:indexPath.row];
        }
        else
        {
            product = [self.listContent objectAtIndex:indexPath.row];
        }
        
        //update the table cell in both
        if(!self.canCreateTags){
           
        //}else{
            //multiselect mode
            if(!selectedTags){
                selectedTags = [[NSMutableArray alloc] init];
            }
            UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
            
            //find the other cell in the other table wether its the search or not
            UITableView* table2 = (tableView == self.searchDisplayController.searchResultsTableView ? self.tableView : self.searchDisplayController.searchResultsTableView);
            UITableViewCell* cell2 = nil;
            for(UITableViewCell* visibleCell in [table2 visibleCells]){
                if([visibleCell.textLabel.text isEqualToString:product]){
                    cell2 = visibleCell;
                    break;
                }
            }
            
            if(cell.accessoryType == UITableViewCellAccessoryNone){
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                cell2.accessoryType = UITableViewCellAccessoryCheckmark;
                [selectedTags addObject:product];
            }else{
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell2.accessoryType = UITableViewCellAccessoryNone;
                [selectedTags removeObject:product];
            }
            
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
         [delegate tagViewController:self didChooseTag:product];
        //detailsViewController.title = product.name;
    }else{
        //create new tag
        [delegate tagViewController:self didCreateTag:self.searchDisplayController.searchBar.text];
        self.searchDisplayController.searchBar.text = @"";
        [self.searchDisplayController setActive:NO];
    }
    
    //[[self navigationController] pushViewController:detailsViewController animated:YES];
   // [detailsViewController release];
}


#pragma mark -
#pragma mark Content Filtering

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
	/*
	 Update the filtered array based on the search text and scope.
	 */
	
	[self.filteredListContent removeAllObjects]; // First clear the filtered array.
	
	/*
	 Search the main list for products whose type matches the scope (if selected) and whose name matches searchText; add items that match to the filtered array.
	 */
	//for (Product *product in listContent)
    for (NSString *product in listContent)
	{
		if ([scope isEqualToString:@"All"])// || [product.type isEqualToString:scope])
		{
			NSComparisonResult result = [product compare:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchText length])];
            if (result == NSOrderedSame)
			{
				[self.filteredListContent addObject:product];
            }
		}
	}
}


#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

@end