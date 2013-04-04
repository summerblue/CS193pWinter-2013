//
//  CMMotionManager+Shared.m
//  KitchenSink
//
//  Created by CS193p Instructor.
//  Copyright (c) 2013 Stanford University. All rights reserved.
//

#import "CMMotionManager+Shared.h"

@implementation CMMotionManager (Shared)

// uses dispatch_once to be "thread safe"
//  but really we're just showing a dispatch_once example here
//   (in reality, you probably wouldn't be calling this from multiple threads!)

+ (CMMotionManager *)sharedMotionManager
{
    static CMMotionManager *shared = nil;
    if (!shared) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{                 // all threads will block here until the block executes
            shared = [[CMMotionManager alloc] init]; // this line of code can only ever happen once
        });
    }
    return shared;
}

@end
