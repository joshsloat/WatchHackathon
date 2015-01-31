//
//  ListRowController.m
//  WatchHackathon
//
//  Created by Josh Sloat on 1/31/15.
//  Copyright (c) 2015 Nimble Guerilla. All rights reserved.
//

#import "ListRowController.h"

@interface ListRowController ()

@property (weak, nonatomic) IBOutlet WKInterfaceLabel *itemLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceImage *animatedBullet;
@property (weak, nonatomic) IBOutlet WKInterfaceImage *nonAnimatedBullet;

@end

@implementation ListRowController

#pragma mark - Public Methods

+ (NSString *)identifier
{
    return @"ListRowIdentifier";
}

- (void)startAnimating
{
    [self.animatedBullet setImageNamed:@"Mic-"];
    [self.animatedBullet startAnimatingWithImagesInRange:NSMakeRange(0, 6) duration:2.0 repeatCount:0];
}

- (void)stopAnimating
{
    [self.animatedBullet stopAnimating];
    [self.animatedBullet setHidden:YES];
    [self.nonAnimatedBullet setHidden:NO];
}

- (void)formatForStartListening
{
    [self.itemLabel setText:@""];
    [self startAnimating];
}

- (void)formatWithListItem:(NSString *)listItem
{
    [self.itemLabel setText:listItem];
    
    if (listItem.length > 0)
    {
        [self stopAnimating];
    }
}

@end
