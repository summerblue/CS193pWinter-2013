//
//  PhotosByPhotographerMapViewController.h
//  Photomania
//
//  Created by CS193p Instructor.
//  Copyright (c) 2013 Stanford University. All rights reserved.
//

#import "MapViewController.h"
#import "Photographer.h"

@interface PhotosByPhotographerMapViewController : MapViewController

// displays all Photos by the given photographer on the mapView

@property (nonatomic, strong) Photographer *photographer;

@end
