//
//  CardGameViewController.h
//  Matchismo
//
//  Created by CS193p Instructor.
//  Copyright (c) 2013 Stanford University.
//  All rights reserved.
//
//  This class is abstract.  See subclasser instructions below.

#import <UIKit/UIKit.h>
#import "Deck.h"

@interface CardGameViewController : UIViewController

// all of the following methods must be overriden by concrete subclasses
- (Deck *)createDeck; // abstract
@property (readonly, nonatomic) NSUInteger startingCardCount; // abstract
- (void)updateCell:(UICollectionViewCell *)cell usingCard:(Card *)card; // abstract

@end
