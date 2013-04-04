//
//  AskerViewController.h
//  KitchenSink
//
//  Created by CS193p Instructor.
//  Copyright (c) 2013 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AskerViewController : UIViewController

// The public interface for this just allows setting a question
//   and then getting an answer back.

@property (nonatomic, strong) NSString *question;
@property (nonatomic, readonly) NSString *answer;

@end
