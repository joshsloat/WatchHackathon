//
//  ListRowController.h
//  WatchHackathon
//
//  Created by Josh Sloat on 1/31/15.
//  Copyright (c) 2015 Nimble Guerilla. All rights reserved.
//

#import <Foundation/Foundation.h>

@import WatchKit;

@interface ListRowController : NSObject

+ (NSString *)identifier;

//- (void)startAnimating;
//- (void)stopAnimating;
- (void)formatForStartListening;
- (void)formatWithListItem:(NSString *)listItem;

@end
