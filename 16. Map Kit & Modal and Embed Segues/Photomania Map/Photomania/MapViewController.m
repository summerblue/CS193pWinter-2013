//
//  MapViewController.m
//  Photomania
//
//  Created by CS193p Instructor.
//  Copyright (c) 2013 Stanford University. All rights reserved.
//

#import "MapViewController.h"

@interface MapViewController ()
@property (nonatomic) BOOL needUpdateRegion;  // delay zooming in on annotations
@end

@implementation MapViewController

// sets up self as the MKMapView's delegate
// notes (one time only) that we should zoom in on our annotations

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.mapView.delegate = self;
    self.needUpdateRegion = YES;
}

// when someone touches on a pin, this gets called
// all it does is set the thumbnail (if the annotation has one)
//   in the leftCalloutAccessoryView (if that is a UIImageView)

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    if ([view.leftCalloutAccessoryView isKindOfClass:[UIImageView class]]) {
        UIImageView *imageView = (UIImageView *)(view.leftCalloutAccessoryView);
        if ([view.annotation respondsToSelector:@selector(thumbnail)]) {
            // this should be done in a different thread!
            imageView.image = [view.annotation performSelector:@selector(thumbnail)];
        }
    }
}

// the MKMapView calls this to get the MKAnnotationView for a given id <MKAnnotation>
// our implementation returns a standard MKPinAnnotation
//   which has callouts enabled
//   and which has a leftCalloutAccessory of a UIImageView
//   and a rightCalloutAccessory of a detail disclosure button
//     (but only if delegate responds to mapView:annotationView:calloutAccessoryControlTapped:)

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    static NSString *reuseId = @"MapViewController";
    MKAnnotationView *view = [mapView dequeueReusableAnnotationViewWithIdentifier:reuseId];
    if (!view) {
        view = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseId];
        view.canShowCallout = YES;
        if ([mapView.delegate respondsToSelector:@selector(mapView:annotationView:calloutAccessoryControlTapped:)]) {
            view.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        }
        view.leftCalloutAccessoryView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,30,30)];
    }
    
    if ([view.leftCalloutAccessoryView isKindOfClass:[UIImageView class]]) {
        UIImageView *imageView = (UIImageView *)(view.leftCalloutAccessoryView);
        imageView.image = nil;
    }
    
    return view;
}

// after we have appeared, zoom in on the annotations (but only do that once)

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.needUpdateRegion) [self updateRegion];
}

// zooms to a region that encloses the annotations
// kind of a crude version
// (using CGRect for latitude/longitude regions is sorta weird, but CGRectUnion is nice to have!)

- (void)updateRegion
{
    self.needUpdateRegion = NO;
    CGRect boundingRect;
    BOOL started = NO;
    for (id <MKAnnotation> annotation in self.mapView.annotations) {
        CGRect annotationRect = CGRectMake(annotation.coordinate.latitude, annotation.coordinate.longitude, 0, 0);
        if (!started) {
            started = YES;
            boundingRect = annotationRect;
        } else {
            boundingRect = CGRectUnion(boundingRect, annotationRect);
        }
    }
    if (started) {
        boundingRect = CGRectInset(boundingRect, -0.2, -0.2);
        if ((boundingRect.size.width < 20) && (boundingRect.size.height < 20)) {
            MKCoordinateRegion region;
            region.center.latitude = boundingRect.origin.x + boundingRect.size.width / 2;
            region.center.longitude = boundingRect.origin.y + boundingRect.size.height / 2;
            region.span.latitudeDelta = boundingRect.size.width;
            region.span.longitudeDelta = boundingRect.size.height;
            [self.mapView setRegion:region animated:YES];
        }
    }
}

@end
