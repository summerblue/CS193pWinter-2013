//
//  KitchenSinkViewController.m
//  KitchenSink
//
//  Created by CS193p Instructor.
//  Copyright (c) 2013 Stanford University. All rights reserved.
//

#import "KitchenSinkViewController.h"
#import "AskerViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "CMMotionManager+Shared.h"

@interface KitchenSinkViewController() <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverControllerDelegate>
@property (weak, nonatomic) IBOutlet UIView *kitchenSink;           // our main view
@property (weak, nonatomic) NSTimer *drainTimer;                    // keeps drain running
@property (weak, nonatomic) UIActionSheet *sinkControlActionSheet;  // so we won't get multiple popovers
@property (strong, nonatomic) UIPopoverController *imagePickerPopover;
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

#pragma mark - UIImagePickerController

// target/action of a bar button item to add Food from Photos album

- (IBAction)addFoodPhoto:(UIBarButtonItem *)sender
{
    [self presentImagePicker:UIImagePickerControllerSourceTypeSavedPhotosAlbum sender:sender];
}

// target/action of a bar button item to add Food from Camera

- (IBAction)takeFoodPhoto:(UIBarButtonItem *)sender
{
    [self presentImagePicker:UIImagePickerControllerSourceTypeCamera sender:sender];
}

// presents a UIImagePickerController which gets an image from the specified sourceType
// on iPad, if sourceType is not Camera, presents in a popover from the given UIBarButtonItem
//   (else modally)

- (void)presentImagePicker:(UIImagePickerControllerSourceType)sourceType sender:(UIBarButtonItem *)sender
{
    if (!self.imagePickerPopover && [UIImagePickerController isSourceTypeAvailable:sourceType]) {
        NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:sourceType];
        if ([availableMediaTypes containsObject:(NSString *)kUTTypeImage]) {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.sourceType = sourceType;
            picker.mediaTypes = @[(NSString *)kUTTypeImage];
            picker.allowsEditing = YES;
            picker.delegate = self;
            if ((sourceType != UIImagePickerControllerSourceTypeCamera) && (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)) {
                self.imagePickerPopover = [[UIPopoverController alloc] initWithContentViewController:picker];
                [self.imagePickerPopover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
                self.imagePickerPopover.delegate = self;
            } else {
                [self presentViewController:picker animated:YES completion:nil];
            }
        }
    }
}

// popover was canceled so clear out our property that points to the popover

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.imagePickerPopover = nil;
}

// UIImagePickerController was canceled, so dismiss it

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#define MAX_IMAGE_WIDTH 200

// called when the user chooses an image in the UIImagePickerController
// limit any image to MAX_IMAGE_WIDTH
// randomly drops it into the kitchen sink
// dismisses the UIImagePickerController

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = info[UIImagePickerControllerEditedImage];
    if (!image) image = info[UIImagePickerControllerOriginalImage];
    if (image) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        CGRect frame = imageView.frame;
        if (frame.size.width > MAX_IMAGE_WIDTH) {
            frame.size.height = (frame.size.height / frame.size.width) * MAX_IMAGE_WIDTH;
            frame.size.width = MAX_IMAGE_WIDTH;
        }
        imageView.frame = frame;
        [self setRandomLocationForView:imageView];
        [self.kitchenSink addSubview:imageView];
    }
    if (self.imagePickerPopover) {
        [self.imagePickerPopover dismissPopoverAnimated:YES];
        self.imagePickerPopover = nil;
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
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
// and start drifting (having all views in the kitchen sink drift toward the center of the earth)

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self startDrainTimer];
    [self cleanDish];
    [self startDrift];
}

// whenever we disappear, stop draining (cleaning dishes will stop itself)
// and stop drifting (having all views in the kitchen sink drift toward the center of the earth)

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self stopDrainTimer];
    [self stopDrift];
}

#pragma mark - Core Motion

#define DRIFT_HZ 10
#define DRIFT_RATE 10

// asks the shared motion manager to start sending accelerometer updates
// on each update, we move all kitchen sink views by some amount relative to acceleration in a given axis

- (void)startDrift
{
    CMMotionManager *motionManager = [CMMotionManager sharedMotionManager];
    if ([motionManager isAccelerometerAvailable]) {
        [motionManager setAccelerometerUpdateInterval:1/DRIFT_HZ];
        [motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMAccelerometerData *data, NSError *error) {
            for (UIView *view in self.kitchenSink.subviews) {
                CGPoint center = view.center;
                center.x += data.acceleration.x * DRIFT_RATE;
                center.y -= data.acceleration.y * DRIFT_RATE;
                view.center = center;
                if (!CGRectContainsRect(self.kitchenSink.bounds, view.frame) && !CGRectIntersectsRect(self.kitchenSink.bounds, view.frame)) {
                    [view removeFromSuperview];
                }
            }
        }];
    }
}

// asks the shared motion manager to stop sending accelerometer updates

- (void)stopDrift
{
    [[CMMotionManager sharedMotionManager] stopAccelerometerUpdates];
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

// Names of foods need to be localizable too.

#define BLUE_FOOD NSLocalizedStringFromTable(@"Jello", @"foods", @"Blue food.")
#define GREEN_FOOD NSLocalizedStringFromTable(@"Broccoli", @"foods", @"Green food.")
#define ORANGE_FOOD NSLocalizedStringFromTable(@"Carrot", @"foods", @"Orange food.")
#define RED_FOOD NSLocalizedStringFromTable(@"Beet", @"foods", @"Red food.")
#define PURPLE_FOOD NSLocalizedStringFromTable(@"Eggplant", @"foods", @"Purple food.")
#define BROWN_FOOD NSLocalizedStringFromTable(@"Potato Peels", @"foods", @"Brown food.")

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
    [foodLabel sizeToFit];
    [self setRandomLocationForView:foodLabel];
    [self.kitchenSink addSubview:foodLabel];
}

// moves the given view to a random location in the kitchen sink's bounds
// also sizes it to fit

- (void)setRandomLocationForView:(UIView *)view
{
    CGRect sinkBounds = CGRectInset(self.kitchenSink.bounds, view.frame.size.width/2, view.frame.size.height/2);
    CGFloat x = arc4random() % (int)sinkBounds.size.width + view.frame.size.width/2;
    CGFloat y = arc4random() % (int)sinkBounds.size.height + view.frame.size.height/2;
    view.center = CGPointMake(x, y);
}

#pragma mark - Action Sheet

// Make the Sink Control Action Sheet localizable.

#define SINK_CONTROL_STOP_DRAIN NSLocalizedStringFromTable(@"Stopper Drain", @"KitchenSinkVC", @"Action Sheet choice to stop things from going down the drain")
#define SINK_CONTROL_UNSTOP_DRAIN NSLocalizedStringFromTable(@"Unstopper Drain", @"KitchenSinkVC", @"Action Sheet choice to allow things to go down the drain")

#define SINK_CONTROL NSLocalizedStringFromTable(@"Sink Controls", @"KitchenSinkVC", @"Sink Control Action Sheet title")
#define SINK_CONTROL_CANCEL NSLocalizedStringFromTable(@"Cancel", @"KitchenSinkVC", @"Sink Control Action Sheet cancel button")
#define SINK_CONTROL_EMPTY NSLocalizedStringFromTable(@"Empty Sink", @"KitchenSinkVC", @"Action Sheet choice to remove everything from the sink")

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

// Make the question we ask in the AskerVC localizable

#define ASKER_LABEL_CREATE NSLocalizedStringFromTable(@"What food do you want to add to the sink?", @"KitchenSinkVC", @"Question in AskerVC to prompt user to enter text for food they are trying to create")

// The "Ask" (Modal) segue goes from this VC to the AskerViewController
// Here we just prepare it by setting the question we want to ask.

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Ask"]) {
        AskerViewController *asker = (AskerViewController *)segue.destinationViewController;
        asker.question = ASKER_LABEL_CREATE;
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
