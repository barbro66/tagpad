//
//  Copyright (c) 2010 Nuclear Elements, Inc. http://nuclearelements.com/
//  The above line must remain intact. And this use of this source code is subject to the terms in LICENSE.txt
//

#import "NebulousStyle.h"

@implementation NebulousStyle

UIColor *_bgColor = nil;
+ (UIColor *) bgColor {
	if (_bgColor == nil)
		_bgColor = [[UIColor whiteColor] retain];
	return _bgColor;
}
+ (void) setBgColor:(UIColor *)bgColor {
	[_bgColor release];
	_bgColor = [bgColor retain];
}

UIColor *_txtColor = nil;
+ (UIColor *) txtColor {
	if (_txtColor == nil)
		_txtColor = [[UIColor blackColor] retain];
	return _txtColor;
}
+ (void) setTxtColor:(UIColor *)txtColor {
	[_txtColor release];
	_txtColor = [txtColor retain];
}

UIColor *_separatorColor = nil;
+ (UIColor *) separatorColor {
	if (_separatorColor == nil)
		_separatorColor = [[UIColor colorWithWhite:.8 alpha:1] retain];
	return _separatorColor;
}
+ (void) setSeparatorColor:(UIColor *) separatorColor {
	[_separatorColor release];
	_separatorColor = [separatorColor retain];
}

UIScrollViewIndicatorStyle _indicatorStyle = UIScrollViewIndicatorStyleDefault;
+ (UIScrollViewIndicatorStyle) indicatorStyle {
	return _indicatorStyle;
}

+ (void) setIndicatorStyle:(UIScrollViewIndicatorStyle)indicatorStyle {
	_indicatorStyle = indicatorStyle;
}

UIImage *_textFieldImg = nil;
+ (UIImage *) textFieldImg {
	if (_textFieldImg == nil)
		_textFieldImg = [[[UIImage imageNamed:@"stdTextFieldWhite.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:0] retain];
	return _textFieldImg;
}
+ (void) setTextFieldImg:(NSString *)textFieldFileName {
	[_textFieldImg release];
	_textFieldImg = [[[UIImage imageNamed:textFieldFileName] stretchableImageWithLeftCapWidth:10 topCapHeight:0] retain];
}

UIBarStyle _barStyle = UIBarStyleDefault;
+ (UIBarStyle) barStyle {
	return _barStyle;
}
+ (void) setBarStyle:(UIBarStyle)barStyle {
	_barStyle = barStyle;
}

UIKeyboardAppearance _keyboardAppearance = UIKeyboardAppearanceDefault;
+ (UIKeyboardAppearance) keyboardAppearance {
	return _keyboardAppearance;
}
+ (void) setKeyboardAppearance: (UIKeyboardAppearance) keyboardAppearance {
	_keyboardAppearance = keyboardAppearance;
}

#pragma mark -

+ (void) applyStyleToView:(UIView *) theView level:(int) lvl  {
//	NSString *tabs = @"";
//	for (int i = 0; i < lvl; i++)
//		tabs = [tabs stringByAppendingString:@"\t"];
//	dolog(@"%@%@",tabs,theView);
	
	if ([theView class] == [UIView class]) {
		theView.backgroundColor = [NebulousStyle bgColor];
		for (int i = 0; i < [theView.subviews count]; i++)
			[NebulousStyle applyStyleToView:(UIView *) [theView.subviews objectAtIndex:i] level:lvl+1];
	} else if ([theView class] == [UITableView class]) {
		theView.backgroundColor = [NebulousStyle bgColor];
		((UITableView *) theView).separatorColor = [NebulousStyle separatorColor];
		((UITableView *) theView).indicatorStyle = [NebulousStyle indicatorStyle];
	} else if ([theView class] == [UITextView class]) {
		theView.backgroundColor = [NebulousStyle bgColor];
		((UITextView *) theView).textColor= [NebulousStyle txtColor];
	} else if ([theView class] == [UITextField class]) {
		((UITextField *) theView).borderStyle = UITextBorderStyleNone;
		((UITextField *) theView).background = [NebulousStyle textFieldImg];
		((UITextField *) theView).leftViewMode = UITextFieldViewModeAlways;
		((UITextField *) theView).leftView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 31)] autorelease];
		((UITextField *) theView).textColor = [NebulousStyle txtColor];
		((UITextField *) theView).keyboardAppearance = [NebulousStyle keyboardAppearance];
	} else if ([theView class] == [UITableViewCell class]) {
		theView.backgroundColor = [UIColor clearColor];
		((UITableViewCell *) theView).contentView.backgroundColor = [UIColor clearColor];
		
		((UITableViewCell *) theView).textLabel.textColor = [NebulousStyle txtColor];
		[NebulousStyle applyStyleToView:((UITableViewCell *) theView).contentView level:lvl+1];
		[NebulousStyle applyStyleToView:((UITableViewCell *) theView).backgroundView level:lvl+1];
	} else if ([theView class] == [UILabel class]) {
		((UILabel *) theView).textColor = [NebulousStyle txtColor];
	}
}


+ (void) applyStyleToView:(UIView *) theView {
	[NebulousStyle applyStyleToView:theView level:0];
}

+ (void) applyStyleToNavigationController:(UINavigationController *) nav {
	nav.navigationBar.barStyle = nav.toolbar.barStyle = [NebulousStyle barStyle];
	nav.view.backgroundColor = [NebulousStyle bgColor];
}

+ (void) skinButton:(UIButton *) btn with:(NSString *) bgname {
	NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
	NSString *defbg = [bundlePath stringByAppendingPathComponent:[bgname stringByAppendingString:@".png"]];
	NSString *hibg = [bundlePath stringByAppendingPathComponent:[bgname stringByAppendingString:@"Hi.png"]];

	UIImage *defimg = [[UIImage imageWithContentsOfFile:defbg] stretchableImageWithLeftCapWidth:28 topCapHeight:0];
	UIImage *hiimg = [[UIImage imageWithContentsOfFile:hibg] stretchableImageWithLeftCapWidth:28 topCapHeight:0];
	
	[btn setBackgroundImage:defimg forState:UIControlStateNormal];
	[btn setBackgroundImage:hiimg forState:UIControlStateHighlighted];
	[btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[btn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
}

#pragma mark -
#pragma mark Basic Alert View

+ (void) showBasicErrorAlert:(NSString *) msg {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"%@ %@",msg,@"To take a screenshot, hold the power button and tap the home button."] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert autorelease];	
}
	 

@end

	 

