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
@property (nonatomic, copy) NSString *listItemString;

@end

@implementation ListRowController

#pragma mark - Public Methods

+ (NSString *)identifier
{
    return @"ListRowIdentifier";
}

- (void)formatForStartListening
{
    self.listItemString = @"";
    [self.itemLabel setText:@""];
    [self startAnimating];
}

- (void)formatWithListItem:(NSString *)listItem withFontSize:(NSInteger)fontSize
{
    if (listItem.length > 0)
    {
        [self stopAnimating];
    }
    
    self.listItemString = listItem;
    
    [self formatWithFontSize:fontSize];
}

- (void)formatWithFontSize:(NSInteger)fontSize
{
    UIFont *font = [UIFont systemFontOfSize:fontSize];
    
    NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObject:font
                                                                     forKey:NSFontAttributeName];
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:self.listItemString attributes:attributesDictionary];
    
    [self.itemLabel setAttributedText:attributedString];
}

#pragma mark - Private Methods

- (void)startAnimating
{
    [self.animatedBullet setHidden:NO];
    [self.nonAnimatedBullet setHidden:YES];
    [self.animatedBullet setImageNamed:@"Mic-"];
    [self.animatedBullet startAnimatingWithImagesInRange:NSMakeRange(0, 6) duration:2.0 repeatCount:0];
}

- (void)stopAnimating
{
    [self.animatedBullet stopAnimating];
    [self.animatedBullet setHidden:YES];
    [self.nonAnimatedBullet setHidden:NO];
}

@end
