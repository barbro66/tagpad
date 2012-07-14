//
//  TagBarButtonItem.m
//  TagPad
//
//  Created by Malcolm Hall on 07/05/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TagBarButton.h"


@implementation TagBarButton

@synthesize tag,subject;

- (void)dealloc {
    self.tag = nil;
    self.subject = nil;
    [super dealloc];
}

@end
