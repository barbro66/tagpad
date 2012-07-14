#import "DLAlert.h"

void DLAlertWithTitleAndMessageAndDelegate(NSString *title, NSString *message, id delegate){
	
	if(!title){
		//use the app's name
		title = [[[NSBundle mainBundle] localizedInfoDictionary] objectForKey:@"CFBundleDisplayName"];
		if(!title){
			title = [[NSProcessInfo processInfo] processName];
		}
	}
	
	/* open an alert with an OK button */
	UIAlertView *alert;
	if(delegate){
		alert = [[UIAlertView alloc] initWithTitle:title 
													message:message
												   delegate:delegate
										  cancelButtonTitle:@"Cancel" 
										  otherButtonTitles: @"OK",nil];
	}else{
		alert = [[UIAlertView alloc] initWithTitle:title 
								   message:message
								  delegate:delegate
						 cancelButtonTitle:@"OK" 
						 otherButtonTitles: nil];
	}
	[alert show];
	[alert release];
}

void DLAlertWithTitleAndMessage(NSString *title, NSString *message)
{
	DLAlertWithTitleAndMessageAndDelegate(title,message,nil);
}

void DLAlertWithMessage(NSString *message)
{
	DLAlertWithTitleAndMessage(nil,message);
}


void DLAlertWithError(NSError *error)
{
    NSString *message = [NSString stringWithFormat:@"Error! %@ %@",
						 [error localizedDescription],
						 [error localizedFailureReason]];
	
	DLAlertWithMessage (message);
}



void DLAlertWithMessageAndDelegate(NSString *message, id delegate)
{
	DLAlertWithTitleAndMessageAndDelegate(nil,message,delegate);
}
