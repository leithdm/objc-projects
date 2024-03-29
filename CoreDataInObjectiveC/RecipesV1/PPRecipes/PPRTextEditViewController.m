/***
 * Excerpted from "Core Data in Objective-C, Third Edition",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material,
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose.
 * Visit http://www.pragmaticprogrammer.com/titles/mzcd3 for more book information.
***/
#import "PPRTextEditViewController.h"

@interface PPRTextEditViewController () <UITextFieldDelegate>

@end

@implementation PPRTextEditViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  [[self navigationItem] setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)]];
  
  if (![[self navigationItem] rightBarButtonItem]) {
    [[self navigationItem] setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)]];
  }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
    return UIDeviceOrientationIsPortrait(interfaceOrientation);
  } else {
    return YES;
  }
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  [[self textField] becomeFirstResponder];
  [[self textView] becomeFirstResponder];
}

- (BOOL)handleTextCompletion
{
  NSError *error = nil;
  NSString *text = nil;
  if ([self textView]) {
    text = [[self textView] text];
  } else {
    text = [[self textField] text];
  }
  
  BOOL success = [self textChangedBlock](text, &error); //http://nscookbook.com/2013/06/ios-programming-recipe-25-implementing-blocks-part-i/
  if (success) {
    [[self navigationController] popViewControllerAnimated:YES];
    return YES;
  }
  
  UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
  [alertView show];
  
  return NO;
}

- (IBAction)done:(id)sender;
{
  [self handleTextCompletion];
}

- (IBAction)cancel:(id)sender;
{
  [[self navigationController] popViewControllerAnimated:YES];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)$textField
{
  return [self handleTextCompletion];
}

@end
