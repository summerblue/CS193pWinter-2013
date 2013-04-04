//
//  MapViewController.h
//  Photomania
//
//  Created by CS193p Instructor.
//  Copyright (c) 2013 Stanford University. All rights reserved.
//
//  Will display a thumbnail in leftCalloutAccessoryView if the
//   annotation implements the method "thumbnail" (return UIImage)

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface MapViewController : UIViewController <MKMapViewDelegate>

// a more powerful MapViewController might make mapView private
// and instead make some methods public to add/remove annotations
// (so that it might get involved when annotations are added/removed)
// this is a simple MapViewController though

@property (nonatomic, strong) IBOutlet MKMapView *mapView;

@end
