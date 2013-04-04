//
//  KitchenSinkViewController.m
//  KitchenSink
//
//  Created by CS193p Instructor.
//  Copyright (c) 2013 Stanford University. All rights reserved.
//

#import "KitchenSinkViewController.h"
#import "AskerViewController.h"

@implementation KitchenSinkViewController

// The "Ask" (Modal) segue goes from this VC to the AskerViewController
// Here we just prepare it by setting the question we want to ask.

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Ask"]) {
        AskerViewController *asker = segue.destinationViewController;
        asker.question = @"What food do you want in the sink?";
    }
}

// This unwinding method is wired up in the AskerViewController scene
//   to the Cancel button.

- (IBAction)cancelAsking:(UIStoryboardSegue *)segue
{
}

// This unwinding method is wired up in the AskerViewController scene
//   to the Done button.
// It should add food to the Kitchen Sink using the given answer.

- (IBAction)doneAsking:(UIStoryboardSegue *)segue
{
    AskerViewController *asker = segue.sourceViewController;
    NSLog(@"%@", asker.answer);
}

@end
