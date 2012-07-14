//
//  NSIndexPath+malc.m
//  TagPad
//
//  Created by Malcolm Hall on 22/04/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSIndexPath+malc.h"


@implementation NSIndexPath (NSIndexPath_malc)

-(NSString*)toString{
    return [NSString stringWithFormat:@"%d.%d",self.section,self.row];
}

+(NSIndexPath*)fromString:(NSString*)s{
    NSArray* parts = [s componentsSeparatedByString:@"."];
    return [NSIndexPath indexPathForRow:[[parts objectAtIndex:1] intValue] inSection:[[parts objectAtIndex:0] intValue]];
}

@end
