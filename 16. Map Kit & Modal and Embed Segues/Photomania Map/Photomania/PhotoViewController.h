//
//  PhotoViewController.h
//  Photomania
//
//  Created by CS193p Instructor.
//  Copyright (c) 2013 Stanford University. All rights reserved.
//

#import "ImageViewController.h"
#import "Photo.h"

@interface PhotoViewController : ImageViewController

// a simple subclass of ImageViewController whose Model is a Photo
//  (instead of just an NSURL for the photo's image data)

@property (nonatomic, strong) Photo *photo;

@end
