README:

------------------------------------------------------------------------------------------------------------------

CoreData error :


In you appdelegate, you can add method :

-(void) fatalCoreDataError:(NSError *) error


Example:

-(void) fatalCoreDataError:(NSError *) error {
    
    UIAlertView *alertView = [[UIAlertViewalloc] initWithTitle:NSLocalizedString(@"Internal error", nil)
                                                        message:NSLocalizedString(@"There was a fatal error in the app and it cannot continue.\n\nPress OK to terminate the app. Sorry for the incovenience.", nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                              otherButtonTitles:nil];
    
    [alertView show];
}

#pragma mark - UIAlertViewDelegate

-(void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    abort();
}

------------------------------------------------------------------------------------------------------------------


