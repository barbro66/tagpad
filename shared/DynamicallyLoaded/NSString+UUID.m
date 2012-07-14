//
//  NSString+UUID.m
//  
//
//  Created by Malcolm Hall on 13/07/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "NSString+UUID.h"


@implementation NSString (UUID)

+ (NSString*) stringWithUUID {
	CFUUIDRef uuidObj = CFUUIDCreate(nil);//create a new UUID
	//get the string representation of the UUID
	NSString *uuidString = (NSString*)CFUUIDCreateString(nil, uuidObj);
	CFRelease(uuidObj);
	return [uuidString autorelease];
}

@end
