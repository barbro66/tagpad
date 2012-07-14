//
//  TagViewController.h
//  TagPad
//
//  Created by Malcolm Hall on 06/05/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

@class Survey;

@interface TagViewController : UITableViewController {
    NSArray			*listContent;			// The master content.
	NSMutableArray	*filteredListContent;	// The content filtered as a result of a search.
	
	// The saved state of the search UI if a memory warning removed the view.
    NSString		*savedSearchTerm;
    NSInteger		savedScopeButtonIndex;
    BOOL			searchWasActive;
    id delegate;
    Survey* survey;
    BOOL _canCreateTags;
    NSMutableArray* selectedTags;
}
@property (assign) IBOutlet id delegate;
@property (nonatomic, retain) NSArray *listContent;
@property (nonatomic, retain) NSMutableArray *filteredListContent;
@property (nonatomic, retain) Survey *survey;
@property (assign) BOOL canCreateTags;

@property (nonatomic, copy) NSString *savedSearchTerm;
@property (nonatomic) NSInteger savedScopeButtonIndex;
@property (nonatomic) BOOL searchWasActive;
@property (readonly) NSMutableArray* selectedTags;

-(BOOL)selectedContains:(NSString*)tag;

@end