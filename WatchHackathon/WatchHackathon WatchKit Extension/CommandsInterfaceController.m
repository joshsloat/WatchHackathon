//
//  CommandsInterfaceController.m
//  WatchHackathon
//
//  Created by Josh Sloat on 1/31/15.
//  Copyright (c) 2015 Nimble Guerilla. All rights reserved.
//

#import "CommandsInterfaceController.h"
#import <AVFoundation/AVFoundation.h>

#define SPEECH_RATE 0.1000

@interface CommandsInterfaceController() <AVSpeechSynthesizerDelegate>

@property (strong, nonatomic) AVSpeechSynthesizer *synthesizer;
@property (nonatomic, strong) AVSpeechUtterance *introUtterance;
@property (nonatomic, strong) AVSpeechUtterance *firstExampleUtterance;
@property (nonatomic, strong) AVSpeechUtterance *secondExampleUtterance;
@property (nonatomic, strong) AVSpeechUtterance *thirdExampleUtterance;
@property (nonatomic, strong) AVSpeechUtterance *fourthExampleUtterance;

@property (nonatomic, copy) NSString *example1Text;
@property (nonatomic, copy) NSString *example2Text;
@property (nonatomic, copy) NSString *example3Text;
@property (nonatomic, copy) NSString *example4Text;

@property (weak, nonatomic) IBOutlet WKInterfaceLabel *example1Label;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *example2Label;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *example3Label;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *example4Label;

@property (weak, nonatomic) IBOutlet WKInterfaceGroup *group1;
@property (weak, nonatomic) IBOutlet WKInterfaceGroup *group2;
@property (weak, nonatomic) IBOutlet WKInterfaceGroup *group3;
@property (weak, nonatomic) IBOutlet WKInterfaceGroup *group4;

@property (weak, nonatomic) IBOutlet WKInterfaceSeparator *separator1;
@property (weak, nonatomic) IBOutlet WKInterfaceSeparator *separator2;
@property (weak, nonatomic) IBOutlet WKInterfaceSeparator *separator3;

@end

@implementation CommandsInterfaceController

#pragma mark - Init / Dealloc

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        _synthesizer = [[AVSpeechSynthesizer alloc] init];
        _synthesizer.delegate = self;
        
        _example1Text = @"\"three sixteenths\"";
        _example2Text = @"\"five feet one and a quarter inches by one and three eighths inches.\"";
        // TODO: make actual command objects for things like this where text needs to be shared - methods for caps, display, etc
        _example3Text = @"\"Clear List\"";
        _example4Text = @"\"Undo / Redo\"";
    }
    
    return self;
}

- (void)awakeWithContext:(id)context
{
    [super awakeWithContext:context];
    
    // Configure interface objects here.
}

#pragma mark - Interface Lifecycle

- (void)willActivate
{
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    
    self.introUtterance = [[AVSpeechUtterance alloc] initWithString:@"You can speak measurements just like you would normally say them out loud. For instance, you can specify a single dimension like"];
    self.introUtterance.rate = SPEECH_RATE;
    [self.synthesizer speakUtterance:self.introUtterance];
    
    [self.group1 setHidden:NO];
    [self.example1Label setHidden:NO];
    [self.example1Label setText:self.example1Text];
}

- (void)didDeactivate
{
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

#pragma mark - Public Methods

+ (NSString *)identifier
{
    return @"CommandsInterfaceIdentifier";
}

#pragma mark - AVSpeechSynthesizerDelegate

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didStartSpeechUtterance:(AVSpeechUtterance *)utterance
{
    
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance *)utterance
{
    if (utterance == self.introUtterance)
    {
        self.firstExampleUtterance = [[AVSpeechUtterance alloc] initWithString:self.example1Text];
        self.firstExampleUtterance.rate = SPEECH_RATE;
        [self.synthesizer speakUtterance:self.firstExampleUtterance];
    }
    else if (utterance == self.firstExampleUtterance)
    {
        [self.separator1 setHidden:NO];
        [self.group2 setHidden:NO];
        self.secondExampleUtterance = [[AVSpeechUtterance alloc] initWithString:[NSString stringWithFormat:@"Or to specify multiple dimensions, you can say things like %@", self.example2Text]];
        self.secondExampleUtterance.rate = SPEECH_RATE;
        [self.synthesizer speakUtterance:self.secondExampleUtterance];
        [self.example2Label setHidden:NO];
        [self.example2Label setText:self.example2Text];
    }
    else if (utterance == self.secondExampleUtterance)
    {
        [self.separator2 setHidden:NO];
        [self.group3 setHidden:NO];
        self.thirdExampleUtterance = [[AVSpeechUtterance alloc] initWithString:[NSString stringWithFormat:@"To clear the list and start over, you can say %@", self.example3Text]];
        self.thirdExampleUtterance.rate = SPEECH_RATE;
        [self.synthesizer speakUtterance:self.thirdExampleUtterance];
        [self.example3Label setHidden:NO];
        [self.example3Label setText:self.example3Text];
    }
    else if (utterance == self.thirdExampleUtterance)
    {
        [self.separator3 setHidden:NO];
        [self.group4 setHidden:NO];
        self.fourthExampleUtterance = [[AVSpeechUtterance alloc] initWithString:[NSString stringWithFormat:@"To undo or redo the previous entry, simply say Undo or Redo"]];
        self.fourthExampleUtterance.rate = SPEECH_RATE;
        [self.synthesizer speakUtterance:self.fourthExampleUtterance];
        [self.example4Label setHidden:NO];
        [self.example4Label setText:self.example4Text];
    }
}

@end



