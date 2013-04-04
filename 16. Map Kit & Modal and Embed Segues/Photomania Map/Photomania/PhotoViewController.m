//
//  PhotoViewController.m
//  Photomania
//
//  Created by CS193p Instructor.
//  Copyright (c) 2013 Stanford University. All rights reserved.
//

#import "PhotoViewController.h"
#import "MapViewController.h"
#import "Photo+MKAnnotation.h"

@interface PhotoViewController ()
@property (nonatomic, strong) MapViewController *mapvc;  // embedded view controller
@end

@implementation PhotoViewController

// when our Model is set, set our title and our imageURL properties

- (void)setPhoto:(Photo *)photo
{
    _photo = photo;
    self.title = self.photo.title;
    self.imageURL = [NSURL URLWithString:self.photo.imageURL];
}

// after our outlets are all set (and the outlets of all of our Embedded Segue VCs)
//   add self.photo (our Model and an MKAnnotation)
//   as an annotation in our embedded MapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.mapvc.mapView addAnnotation:self.photo];
}

// prepare our embedded MapViewController via the Embed Map of Photo segue
// we don't actually do anything but grab ahold of the MapViewController
// so that we can talk to it after everyone's outlets are set
// it might have been nice for MapViewController to have some public API to set
// its annotations (which it would have then done in its own viewDidLoad)
// but our MapViewController is so simplistic, it just vends its own outlets
//  (which are not set yet at prepareForSegue:sender: time)

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Embed Map of Photo"]) {
        if ([segue.destinationViewController isKindOfClass:[MapViewController class]]) {
            self.mapvc = segue.destinationViewController;
        }
    }
}

@end
