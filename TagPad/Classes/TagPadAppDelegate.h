//
//  TagPadAppDelegate.h
//  TagPad
//
//  Created by Malcolm Hall on 01/03/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TagPadViewController,StudyBrowser,RecordingViewController;

@interface TagPadAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    TagPadViewController *viewController;
    StudyBrowser* _studyBrowser;
    RecordingViewController* recordingViewController;
    UINavigationController* navigationController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain) IBOutlet TagPadViewController *viewController;
@property (nonatomic, retain) IBOutlet StudyBrowser *studyBrowser;
@property (nonatomic, retain) IBOutlet RecordingViewController *recordingViewController;

@end

