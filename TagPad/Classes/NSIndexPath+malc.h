//
//  NSIndexPath+malc.h
//  TagPad
//
//  Created by Malcolm Hall on 22/04/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSIndexPath (NSIndexPath_malc)

-(NSString*)toString;
+(NSIndexPath*)fromString:(NSString*)s;

@end
