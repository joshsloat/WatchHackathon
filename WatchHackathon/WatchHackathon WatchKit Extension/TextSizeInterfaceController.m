//
//  TextSizeInterfaceController.m
//  WatchHackathon
//
//  Created by Josh Sloat on 1/31/15.
//  Copyright (c) 2015 Nimble Guerilla. All rights reserved.
//

#import "TextSizeInterfaceController.h"

@interface TextSizeInterfaceController()

@property (nonatomic) NSInteger defaultFontSize;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *textSizeLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceSlider *sizeSlider;

@property (nonatomic, strong) NSArray *fontMap;

@end

@implementation TextSizeInterfaceController

#pragma mark - Init / Dealloc

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        _defaultFontSize = 12;
        [self initializedFontMap];
    }
    
    return self;
}

- (void)awakeWithContext:(id)context
{
    [super awakeWithContext:context];
    
    NSNumber *fontSizeNumber = context;
    int fontSize = fontSizeNumber.intValue;
    
    // Configure interface objects here.
    [self updateLabelWithFontSize:fontSize];
    
    [self updateSliderWithFontSize:fontSize];
}

- (void)initializedFontMap
{
    NSInteger increment = 2;
    
    self.fontMap = @[ [NSNumber numberWithInteger:self.defaultFontSize - (increment * 2)],
                      [NSNumber numberWithInteger:self.defaultFontSize],
                      [NSNumber numberWithInteger:self.defaultFontSize + increment * 2],
                      [NSNumber numberWithInteger:self.defaultFontSize + increment * 4] ];
}

#pragma mark - Interface Lifecycle

- (void)willActivate
{
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate
{
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

#pragma mark - Public Methods

+ (NSString *)identifier
{
    return @"TextSizeInterfaceIdentifier";
}

#pragma mark - Actions

- (IBAction)slideDidChange:(float)value
{    
    int index = value;
    
    NSNumber *fontSizeNumber = self.fontMap[index];
    
    NSDictionary *fontSizeDictionary = @ { kFontSizeKey : fontSizeNumber };
        
    [[NSNotificationCenter defaultCenter] postNotificationName:kFontSizeChangeNotification object:self userInfo:fontSizeDictionary];
}

#pragma mark - Private Methods

- (void)updateLabelWithFontSize:(NSInteger)fontSize
{
    UIFont *font = [UIFont systemFontOfSize:fontSize];
    
    NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObject:font
                                                                     forKey:NSFontAttributeName];
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:@"Aa" attributes:attributesDictionary];
    
    [self.textSizeLabel setAttributedText:attributedString];
}

- (void)updateSliderWithFontSize:(NSInteger)fontSize
{
    float value = [self.fontMap indexOfObject:[NSNumber numberWithInteger:fontSize]];
    
    [self.sizeSlider setValue:value];
}

@end



