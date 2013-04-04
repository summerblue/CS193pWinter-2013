//
//  AskerViewController.m
//  KitchenSink
//
//  Created by CS193p Instructor.
//  Copyright (c) 2013 Stanford University. All rights reserved.
//

#import "AskerViewController.h"

@interface AskerViewController ()
@property (weak, nonatomic) IBOutlet UILabel *questionLabel;
@property (weak, nonatomic) IBOutlet UITextField *answerTextField;
@end

@implementation AskerViewController

// Every time this controller's view appears, we reset the question
//   and clear out the answer from previous appearances (if any).
// Usually this is segued to (i.e. instantiated), so the answer's already clear.
// We also make the answer text field become the first responder
//   (so the keyboard will appear).

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.questionLabel.text = self.question;
    self.answerTextField.text = nil;
    [self.answerTextField becomeFirstResponder];
}

// The answer is just whatever is in the answer text field.

- (NSString *)answer
{
    return self.answerTextField.text;
}

@end
