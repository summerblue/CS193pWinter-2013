//
//  AttributedStringViewController.m
//  Shutterbug
//
//  Created by CS193p Instructor.
//  Copyright (c) 2013 Stanford University. All rights reserved.
//
//  Just displays a view controller with a UITextView showing the Model (an NSAttributedString)

#import "AttributedStringViewController.h"

@interface AttributedStringViewController ()
@property (weak, nonatomic) IBOutlet UITextView *textView;
@end

@implementation AttributedStringViewController

// update the text view with the attributed string

- (void)setText:(NSAttributedString *)text
{
    _text = text;
    self.textView.attributedText = text;
}

// update the text view with the attributed string
//  (in case the attributed string was set before the outlet to the text view was loaded)

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.textView.attributedText = self.text;
}

@end
