//
//  Photo+Flickr.h
//  Photomania
//
//  Created by CS193p Instructor.
//  Copyright (c) 2013 Stanford University. All rights reserved.
//

#import "Photo.h"

@interface Photo (Flickr)

// Creates a Photo in the database for the given Flickr photo (if necessary).

+ (Photo *)photoWithFlickrInfo:(NSDictionary *)photoDictionary
        inManagedObjectContext:(NSManagedObjectContext *)context;

@end
