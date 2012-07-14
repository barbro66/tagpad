//
//  Copyright (c) 2010 Nuclear Elements, Inc. http://nuclearelements.com/
//  The above line must remain intact. And this use of this source code is subject to the terms in LICENSE.txt
//

#import <Foundation/Foundation.h>

#define NEBULOUS_TRANSITION_ANIM_LEN .7

@interface NebulousStyle : NSObject {

}

+ (UIColor *) bgColor;
+ (void) setBgColor:(UIColor *) bgColor;
+ (UIColor *) txtColor;
+ (void) setTxtColor:(UIColor *) txtColor;
+ (UIColor *) separatorColor;
+ (void) setSeparatorColor:(UIColor *) separatorColor;
+ (UIScrollViewIndicatorStyle) indicatorStyle;
+ (void) setIndicatorStyle: (UIScrollViewIndicatorStyle) indicatorStyle;
+ (UIImage *) textFieldImg;
+ (void) setTextFieldImg:(NSString *)textFieldFileName;
+ (UIBarStyle) barStyle;
+ (void) setBarStyle:(UIBarStyle) barStyle;
+ (UIKeyboardAppearance) keyboardAppearance;
+ (void) setKeyboardAppearance: (UIKeyboardAppearance) keyboardAppearance;
	
+ (void) applyStyleToView:(UIView *) theView;
+ (void) applyStyleToNavigationController:(UINavigationController *) nav;
+ (void) skinButton:(UIButton *) btn with:(NSString *)bgname;

+ (void) showBasicErrorAlert:(NSString *) msg;

@end
