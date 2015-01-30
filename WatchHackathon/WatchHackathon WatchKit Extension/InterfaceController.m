//
//  InterfaceController.m
//  WatchHackathon WatchKit Extension
//
//  Created by Josh Sloat on 1/30/15.
//  Copyright (c) 2015 Nimble Guerilla. All rights reserved.
//

#import "InterfaceController.h"
#import <OpenEars/OELanguageModelGenerator.h>
#import <OpenEars/OEPocketsphinxController.h>
#import <OpenEars/OEAcousticModel.h>
#import <OpenEars/OEEventsObserver.h>

@interface InterfaceController() <OEEventsObserverDelegate>

@property (weak, nonatomic) IBOutlet WKInterfaceLabel *label;

@property (strong, nonatomic) OEEventsObserver *openEarsEventsObserver;

@property (nonatomic, strong) NSMutableAttributedString *attributedString;

@end


@implementation InterfaceController

#pragma mark - Init / Dealloc

- (void)awakeWithContext:(id)context
{
    [super awakeWithContext:context];
    
    self.attributedString = [NSMutableAttributedString new];
    
    [self.label setText:@"Hello watch!"];
    
    [self configureOpenEars];
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


#pragma mark - Private Methods

- (void)configureOpenEars
{
    NSArray *words = [NSArray arrayWithObjects:@"WORD", @"STATEMENT", @"OTHER WORD", @"A PHRASE", nil];
    NSString *languagModelFileName = @"NameIWantForMyLanguageModelFiles";
    NSString *accousticModel = @"AcousticModelEnglish";
    
    // Configure the language model generator
    OELanguageModelGenerator *languageModelGenerator = [[OELanguageModelGenerator alloc] init];
    NSError *error = [languageModelGenerator generateLanguageModelFromArray:words
                                                             withFilesNamed:languagModelFileName
                                                     forAcousticModelAtPath:[OEAcousticModel pathToModel:accousticModel]];
    
    if (error)
    {
        NSLog(@"Error: %@",[error localizedDescription]);
        return;
    }
    
    // setup language observation
    self.openEarsEventsObserver = [[OEEventsObserver alloc] init];
    [self.openEarsEventsObserver setDelegate:self];
    
    // configure the controller and start listening
    NSString *languageModelPath = [languageModelGenerator pathToSuccessfullyGeneratedLanguageModelWithRequestedName:languagModelFileName];
    NSString *dictionaryPath = [languageModelGenerator pathToSuccessfullyGeneratedDictionaryWithRequestedName:languagModelFileName];
    
    [[OEPocketsphinxController sharedInstance] setActive:TRUE error:nil];
    [[OEPocketsphinxController sharedInstance] startListeningWithLanguageModelAtPath:languageModelPath
                                                                    dictionaryAtPath:dictionaryPath
                                                                 acousticModelAtPath:[OEAcousticModel pathToModel:accousticModel]
                                                                 languageModelIsJSGF:NO];
}

- (void)appendText:(NSString*)text
{
    NSMutableAttributedString *originalText = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedString];
    NSAttributedString *appendText = [[NSAttributedString alloc] initWithString:text
                                                                     attributes:nil];
    
    [originalText appendAttributedString:appendText];
    [self.label setAttributedText:originalText];
    
    self.attributedString = originalText;
}

#pragma mark - OEEventsObserverDelegate

- (void) pocketsphinxDidReceiveHypothesis:(NSString *)hypothesis recognitionScore:(NSString *)recognitionScore utteranceID:(NSString *)utteranceID
{
    NSLog(@"The received hypothesis is %@ with a score of %@ and an ID of %@", hypothesis, recognitionScore, utteranceID);
    
    [self.label setText:hypothesis];
}

- (void) pocketsphinxDidStartListening
{
    NSLog(@"Pocketsphinx is now listening.");
}

- (void) pocketsphinxDidDetectSpeech
{
    NSLog(@"Pocketsphinx has detected speech.");
}

- (void) pocketsphinxDidDetectFinishedSpeech
{
    NSLog(@"Pocketsphinx has detected a period of silence, concluding an utterance.");
}

- (void) pocketsphinxDidStopListening
{
    NSLog(@"Pocketsphinx has stopped listening.");
}

- (void) pocketsphinxDidSuspendRecognition
{
    NSLog(@"Pocketsphinx has suspended recognition.");
}

- (void) pocketsphinxDidResumeRecognition
{
    NSLog(@"Pocketsphinx has resumed recognition.");
}

- (void) pocketsphinxDidChangeLanguageModelToFile:(NSString *)newLanguageModelPathAsString andDictionary:(NSString *)newDictionaryPathAsString
{
    NSLog(@"Pocketsphinx is now using the following language model: \n%@ and the following dictionary: %@",newLanguageModelPathAsString,newDictionaryPathAsString);
}

- (void) pocketSphinxContinuousSetupDidFailWithReason:(NSString *)reasonForFailure
{
    NSLog(@"Listening setup wasn't successful and returned the failure reason: %@", reasonForFailure);
}

- (void) pocketSphinxContinuousTeardownDidFailWithReason:(NSString *)reasonForFailure
{
    NSLog(@"Listening teardown wasn't successful and returned the failure reason: %@", reasonForFailure);
}

- (void) testRecognitionCompleted
{
    NSLog(@"A test file that was submitted for recognition is now complete.");
}

@end



