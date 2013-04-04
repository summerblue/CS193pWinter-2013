//
//  PhotographerCDTVC.h
//  Photomania
//
//  Created by CS193p Instructor.
//  Copyright (c) 2013 Stanford University. All rights reserved.
//
//  Can do "setPhotographer:" segue and will call said method in destination VC.

#import "CoreDataTableViewController.h"

@interface PhotographerCDTVC : CoreDataTableViewController

// The Model for this class.
// Essentially specifies the database to look in to find all Photographers to display in this table.
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end
