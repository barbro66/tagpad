//
//  TagBarButtonItem.h
//  TagPad
//
//  Created by Malcolm Hall on 07/05/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Subject;
@interface TagBarButton : UIButton {
    NSDictionary* tag;
    Subject* subject;
    
}
@property (retain) NSDictionary* tag;
@property (retain) Subject* subject;
@end
