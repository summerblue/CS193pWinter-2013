//
//  PhotosByPhotographerMapViewController.m
//  Photomania
//
//  Created by CS193p Instructor.
//  Copyright (c) 2013 Stanford University. All rights reserved.
//

#import "PhotosByPhotographerMapViewController.h"
#import "Photo+MKAnnotation.h"

@implementation PhotosByPhotographerMapViewController

// when our Model is set, we set our title and, if we're visible, reload the map

- (void)setPhotographer:(Photographer *)photographer
{
    _photographer = photographer;
    self.title = photographer.name;
    if (self.view.window) [self reload];
}

// always fetch from Core Data after our outlets (mapView) are set

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self reload];
}

// fetches Photos whose whoTook relationship is self.photographer
// then just loads them up as the MKMapView's annotations
// this works because Photo objects have been made to conform to MKAnnotation
//   (via the Photo+MKAnnotation category)

- (void)reload
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.predicate = [NSPredicate predicateWithFormat:@"whoTook = %@", self.photographer];
    NSArray *photos = [self.photographer.managedObjectContext executeFetchRequest:request error:NULL];
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView addAnnotations:photos];
    Photo *photo = [photos lastObject];
    if (photo) self.mapView.centerCoordinate = photo.coordinate;
}

// sent to the mapView's delegate (us) when any {left,right}CalloutAccessoryView
//   that is a UIControl is tapped on
// in this case, we manually segue using the setPhoto: segue

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    [self performSegueWithIdentifier:@"setPhoto:" sender:view];
}

// prepares a view controller segued to via the setPhoto: segue
//   by calling setPhoto: with the photo associated with sender
//   (sender must be an MKAnnotationView whose annotation is a Photo)

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"setPhoto:"]) {
        if ([sender isKindOfClass:[MKAnnotationView class]]) {
            MKAnnotationView *aView = sender;
            if ([aView.annotation isKindOfClass:[Photo class]]) {
                Photo *photo = aView.annotation;
                if ([segue.destinationViewController respondsToSelector:@selector(setPhoto:)]) {
                    [segue.destinationViewController performSelector:@selector(setPhoto:) withObject:photo];
                }
            }
        }
    }
}

@end
