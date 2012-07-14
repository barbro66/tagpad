//
//  TagPadAppDelegate.m
//  TagPad
//
//  Created by Malcolm Hall on 01/03/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TagPadAppDelegate.h"
#import "TagPadViewController.h"
#import "StudyBrowser.h"
#import "NSString+UUID.h"
#import "AudioJoiner.h"

@implementation TagPadAppDelegate

@synthesize window;
@synthesize viewController;
@synthesize studyBrowser = _studyBrowser;
//@synthesize recordingViewController;
@synthesize navigationController;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after app launch. 
    [self.window addSubview:navigationController.view];
    [self.window makeKeyAndVisible];
    _studyBrowser.delegate = self;

//    NSArray* results = [[Model sharedModel] studies];
    
    //NSURL* f = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"sample.m4a" ofType:nil]];
   // AudioJoiner* aj = [[AudioJoiner alloc] initWithFirstFile:f secondFile:f delegate:self];
 //   [aj join];
    
	return YES;
}

-(void)studyBrowser:(StudyBrowser*)studyBrowser openStudy:(NSDictionary*)study{
    //recordingViewController.data = study;
    [self studyBrowserOpen:studyBrowser];
}

-(void)studyBrowserOpen:(StudyBrowser*)studyBrowser{
    
   
    //[navigationController pushViewController:recordingViewController animated:NO];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}


@end
