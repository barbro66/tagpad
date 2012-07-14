//
//  TagBarButtonItem.m
//  TagPad
//
//  Created by Malcolm Hall on 07/05/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TagBarButtonItem.h"


@implementation TagBarButtonItem
@synthesize tag,subject;

- (void)dealloc {
    self.subject = nil;
    self.tag = nil;
    [super dealloc];
}

@end
