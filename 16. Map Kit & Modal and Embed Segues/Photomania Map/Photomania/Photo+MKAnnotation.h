//
//  Photo+MKAnnotation.h
//  Photomania
//
//  Created by CS193p Instructor.
//  Copyright (c) 2013 Stanford University. All rights reserved.
//

#import "Photo.h"
#import <MapKit/MapKit.h>

@interface Photo (MKAnnotation) <MKAnnotation>

// this is not part of the MKAnnotation protocol
// but we implement it at the urging of MapViewController's header file

- (UIImage *)thumbnail;  // blocks!

@end
