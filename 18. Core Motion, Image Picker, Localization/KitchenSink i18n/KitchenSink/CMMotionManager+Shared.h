//
//  CMMotionManager+Shared.h
//  KitchenSink
//
//  Created by CS193p Instructor.
//  Copyright (c) 2013 Stanford University. All rights reserved.
//

#import <CoreMotion/CoreMotion.h>

@interface CMMotionManager (Shared)

// adds a method to CMMotionManager to hand out a shared instance

+ (CMMotionManager *)sharedMotionManager;

@end
