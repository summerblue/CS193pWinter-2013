//
//  LatestFlickrPhotosTVC.m
//  Shutterbug
//
//  Created by CS193p Instructor.
//  Copyright (c) 2013 Stanford University. All rights reserved.
//

#import "LatestFlickrPhotosTVC.h"
#import "FlickrFetcher.h"

@implementation LatestFlickrPhotosTVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadLatestPhotosFromFlickr];  // banish to a thread
    // add target/action manually (ctrl-drag from UIRefreshControl broken in Xcode)
    [self.refreshControl addTarget:self
                            action:@selector(loadLatestPhotosFromFlickr)
                  forControlEvents:UIControlEventValueChanged];
}

// As asked about in class, this mechanism could conceivably be abstract in superclass.
// It would then want to call something like "fetchPhotos" which subclasses could override
//  (and which this class would implement with "return [FlickrFetcher latestGeoreferencedPhotos]")
// and in that case this method would not want to call itself "loadLatestPhotosFromFlickr"
//  (probaby something like "loadPhotos").
// We're doing it here (instead of superclass) just to make the queueing more obvious.

- (IBAction)loadLatestPhotosFromFlickr
{
    // start the animation if it's not already going
    [self.refreshControl beginRefreshing];
    // fork off the Flickr fetch into another thread
    dispatch_queue_t loaderQ = dispatch_queue_create("flickr latest loader", NULL);
    dispatch_async(loaderQ, ^{
        // call Flickr
        NSArray *latestPhotos = [FlickrFetcher latestGeoreferencedPhotos];
        // when we have the results, use main queue to display them
        dispatch_async(dispatch_get_main_queue(), ^{
            self.photos = latestPhotos; // makes UIKit calls, so must be main thread
            [self.refreshControl endRefreshing];  // stop the animation
        });
    });
}

@end
