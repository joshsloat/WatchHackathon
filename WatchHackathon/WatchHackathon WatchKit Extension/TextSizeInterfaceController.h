//
//  TextSizeInterfaceController.h
//  WatchHackathon
//
//  Created by Josh Sloat on 1/31/15.
//  Copyright (c) 2015 Nimble Guerilla. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

static NSString * const kFontSizeKey = @"FontSize";
static NSString * const kFontSizeChangeNotification = @"FontSizeChangeNotification";

@interface TextSizeInterfaceController : WKInterfaceController

+ (NSString *)identifier;

@end
