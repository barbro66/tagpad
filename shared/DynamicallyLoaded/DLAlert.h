

void DLAlertWithTitleAndMessageAndDelegate(NSString *title, NSString *message, id delegate);
void DLAlertWithTitleAndMessage(NSString *title, NSString *message);
void DLAlertWithMessage(NSString *message);
void DLAlertWithError(NSError *error);
void DLAlertWithMessageAndDelegate(NSString *message, id delegate);

//this is an example of the delegate method you could have
/*
- (void)alertView:(UIAlertView *)alert clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 0) {
		//the user clicked the Cancel button 
        return;
    }
	
	//the user clicked OK so do something
}
*/