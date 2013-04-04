//
//  PhotosByPhotographerCDTVC.h
//  Photomania
//
//  Created by CS193p Instructor.
//  Copyright (c) 2013 Stanford University. All rights reserved.
//

#import "CoreDataTableViewController.h"
#import "Photographer.h"

@interface PhotosByPhotographerCDTVC : CoreDataTableViewController

// The Model for this class.
// It displays all the Photo objects taken by this Photographer
//   (i.e. all Photo objects whose "whoTook" is this Photographer).
@property (nonatomic, strong) Photographer *photographer;

@end
