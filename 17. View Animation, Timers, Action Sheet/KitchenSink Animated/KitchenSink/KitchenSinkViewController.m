//
//  KitchenSinkViewController.m
//  KitchenSink
//
//  Created by CS193p Instructor.
//  Copyright (c) 2013 Stanford University. All rights reserved.
//

#import "KitchenSinkViewController.h"
#import "AskerViewController.h"

@interface KitchenSinkViewController() <UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UIView *kitchenSink;           // our main view
@property (weak, nonatomic) NSTimer *drainTimer;                    // keeps drain running
@property (weak, nonatomic) UIActionSheet *sinkControlActionSheet;  // so we won't get multiple popovers
@end

@implementation KitchenSinkViewController

#pragma mark - performSelector:withObject:afterDelay:

#define DISH_CLEANING_INTERVAL 2.0

// drops a random food into the sink
// then reschedules itself by calling performSelector:withObject:afterDelay: with itself
// stops adding food (or rescheduling itself) if off screen

- (void)cleanDish
{
    if (self.kitchenSink.window) {
        [self addFood:nil];
        [self performSelector:@selector(cleanDish) withObject:nil afterDelay:DISH_CLEANING_INTERVAL];
    }
}

#pragma mark - NSTimer

#define DRAIN_DURATION 3.0
#define DRAIN_DELAY 1.0

// starts a timer to call the drain method (via the drain: method)

- (void)startDrainTimer
{
    self.drainTimer = [NSTimer scheduledTimerWithTimeInterval:DRAIN_DURATION/3
                                                       target:self
                                                     selector:@selector(drain:)
                                                     userInfo:nil
                                                      repeats:YES];
}

// all NSTimer methods must take an NSTimer as an argument
// we just call the drain method that has no arguments

- (void)drain:(NSTimer *)timer
{
    [self drain];
}

// stops the drain timer

- (void)stopDrainTimer
{
    [self.drainTimer invalidate];
    self.drainTimer = nil;
}

// just after we appear, start draining and cleaning dishes

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self startDrainTimer];
    [self cleanDish];
}

// whenever we disappear, stop draining (cleaning dishes will stop itself)

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self stopDrainTimer];
}

#pragma mark - View Animation

// animate food swirling down the drain
// goes 1/3 of the way around the circles with each subsequent animation
// does rotation (and shrinking) by modifying each view's transform property

- (void)drain
{
    for (UIView *view in self.kitchenSink.subviews) {
        CGAffineTransform transform = view.transform;
        if (CGAffineTransformIsIdentity(transform)) {
            [UIView animateWithDuration:DRAIN_DURATION/3 delay:DRAIN_DELAY options:UIViewAnimationOptionCurveLinear animations:^{
                view.transform = CGAffineTransformRotate(CGAffineTransformScale(transform, 0.7, 0.7), 2*M_PI/3);
            } completion:^(BOOL finished) {
                if (finished) [UIView animateWithDuration:DRAIN_DURATION/3 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                    view.transform = CGAffineTransformRotate(CGAffineTransformScale(transform, 0.4, 0.4), -2*M_PI/3);
                } completion:^(BOOL finished) {
                    if (finished) [UIView animateWithDuration:DRAIN_DURATION/3 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                        view.transform = CGAffineTransformScale(transform, 0.1, 0.1);
                    } completion:^(BOOL finished) {
                        if (finished) [view removeFromSuperview];
                    }];
                }];
            }];
        }
    }
}

#define MOVE_DURATION 3.0

// tapping on a food makes it move to a new location
// it also "saves" the food from going down the drain
//   by starting a new transform animation that supercedes the one from the drain method
//   (because UIViewAnimationOptionBeginFromCurrentState is used)

- (IBAction)tap:(UITapGestureRecognizer *)sender
{
    CGPoint tapLocation = [sender locationInView:self.kitchenSink];
    for (UIView *view in self.kitchenSink.subviews) {
        if (CGRectContainsPoint(view.frame, tapLocation)) {
            [UIView animateWithDuration:MOVE_DURATION delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                [self setRandomLocationForView:view];
                view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.99, 0.99);
            } completion:^(BOOL finished) {
                if (finished) view.transform = CGAffineTransformIdentity;
            }];
        }
    }
}

#pragma mark - Add Food

#define BLUE_FOOD @"Jello"
#define GREEN_FOOD @"Broccoli"
#define ORANGE_FOOD @"Carrot"
#define RED_FOOD @"Beet"
#define PURPLE_FOOD @"Eggplant"
#define BROWN_FOOD @"Potato Peels"

// creates a UILabel to display the given food
// if food is nil, then it adds a random, colored food

- (void)addFood:(NSString *)food
{
    UILabel *foodLabel = [[UILabel alloc] init];
    
    static NSDictionary *foods = nil;
    if (!foods) foods =  @{ BLUE_FOOD : [UIColor blueColor],
                            GREEN_FOOD : [UIColor greenColor],
                            ORANGE_FOOD : [UIColor orangeColor],
                            RED_FOOD : [UIColor redColor],
                            PURPLE_FOOD : [UIColor purpleColor],
                            BROWN_FOOD : [UIColor brownColor] };
    if (![food length]) {
        food = [[foods allKeys] objectAtIndex:arc4random()%[foods count]];
        foodLabel.textColor = [foods objectForKey:food];
    }
    
    foodLabel.text = food;
    foodLabel.font = [UIFont systemFontOfSize:46];
    foodLabel.backgroundColor = [UIColor clearColor];
    [self setRandomLocationForView:foodLabel];
    [self.kitchenSink addSubview:foodLabel];
}

// moves the given view to a random location in the kitchen sink's bounds
// also sizes it to fit

- (void)setRandomLocationForView:(UIView *)view
{
    [view sizeToFit];
    CGRect sinkBounds = CGRectInset(self.kitchenSink.bounds, view.frame.size.width/2, view.frame.size.height/2);
    CGFloat x = arc4random() % (int)sinkBounds.size.width + view.frame.size.width/2;
    CGFloat y = arc4random() % (int)sinkBounds.size.height + view.frame.size.height/2;
    view.center = CGPointMake(x, y);
}

#pragma mark - Action Sheet

#define SINK_CONTROL @"Sink Controls"
#define SINK_CONTROL_STOP_DRAIN @"Stopper Drain"
#define SINK_CONTROL_UNSTOP_DRAIN @"Unstopper Drain"
#define SINK_CONTROL_CANCEL @"Cancel"
#define SINK_CONTROL_EMPTY @"Empty Sink"

// put up an action sheet to control the drain or empty the sink

- (IBAction)controlSink:(UIBarButtonItem *)sender
{
    if (!self.sinkControlActionSheet) {
        NSString *drainButton = self.drainTimer ? SINK_CONTROL_STOP_DRAIN : SINK_CONTROL_UNSTOP_DRAIN;
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:SINK_CONTROL
                                                                 delegate:self
                                                        cancelButtonTitle:SINK_CONTROL_CANCEL
                                                   destructiveButtonTitle:SINK_CONTROL_EMPTY
                                                        otherButtonTitles:drainButton, nil];
        [actionSheet showFromBarButtonItem:sender animated:YES];
        self.sinkControlActionSheet = actionSheet;  // sinkControlActionSheet is weak, but showing gives the popover a strong pointer to it
    }
}

// UIActionSheet delegate method called when the user chooses something

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.destructiveButtonIndex) {
        [self.kitchenSink.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    } else {
        NSString *choice = [actionSheet buttonTitleAtIndex:buttonIndex];
        if ([choice isEqualToString:SINK_CONTROL_STOP_DRAIN]) {
            [self stopDrainTimer];
        } else if ([choice isEqualToString:SINK_CONTROL_UNSTOP_DRAIN]) {
            [self startDrainTimer];
        }
    }
}

#pragma mark - Modal View Controller

// The "Ask" (Modal) segue goes from this VC to the AskerViewController
// Here we just prepare it by setting the question we want to ask.

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Ask"]) {
        AskerViewController *asker = segue.destinationViewController;
        asker.question = @"What food do you want in the sink?";
    }
}

// This unwinding method is wired up in the AskerViewController scene
//   to the Cancel button.

- (IBAction)cancelAsking:(UIStoryboardSegue *)segue
{
}

// This unwinding method is wired up in the AskerViewController scene
//   to the Done button.
// It should add food to the Kitchen Sink using the given answer.

- (IBAction)doneAsking:(UIStoryboardSegue *)segue
{
    AskerViewController *asker = segue.sourceViewController;
    [self addFood:asker.answer];
}

@end
