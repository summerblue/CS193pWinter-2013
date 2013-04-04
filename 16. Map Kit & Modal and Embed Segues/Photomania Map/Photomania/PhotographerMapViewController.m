//
//  PhotographerMapViewController.m
//  Photomania
//
//  Created by CS193p Instructor.
//  Copyright (c) 2013 Stanford University. All rights reserved.
//

#import "PhotographerMapViewController.h"
#import "Photographer+MKAnnotation.h"

@implementation PhotographerMapViewController

// if we are visible and our Model is (re)set, refetch from Core Data

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    if (self.view.window) [self reload];
}

// always fetch from Core Data after our outlets (mapView) are set

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self reload];
}

// fetches Photographers who have taken more than 2 photos
// then just loads them up as the MKMapView's annotations
// this works because Photographer objects have been made to conform to MKAnnotation
//   (via the Photographer+MKAnnotation category)

- (void)reload
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photographer"];
    request.predicate = [NSPredicate predicateWithFormat:@"photos.@count > 2"];
    NSArray *photographers = [self.managedObjectContext executeFetchRequest:request error:NULL];
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView addAnnotations:photographers];
}

// sent to the mapView's delegate (us) when any {left,right}CalloutAccessoryView
//   that is a UIControl is tapped on
// in this case, we manually segue using the setPhotographer: segue

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    [self performSegueWithIdentifier:@"setPhotographer:" sender:view];
}

// prepares a view controller segued to via the setPhotographer: segue
//   by calling setPhotographer: with the photographer associated with sender
//   (sender must be an MKAnnotationView whose annotation is a Photographer)

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"setPhotographer:"]) {
        if ([sender isKindOfClass:[MKAnnotationView class]]) {
            MKAnnotationView *aView = sender;
            if ([aView.annotation isKindOfClass:[Photographer class]]) {
                Photographer *photographer = aView.annotation;
                if ([segue.destinationViewController respondsToSelector:@selector(setPhotographer:)]) {
                    [segue.destinationViewController performSelector:@selector(setPhotographer:) withObject:photographer];
                }
            }
        }
    }
}

@end
