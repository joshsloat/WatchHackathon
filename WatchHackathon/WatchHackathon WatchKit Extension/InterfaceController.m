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
#import "ListRowController.h"
#import "TextSizeInterfaceController.h"
#import "CommandsInterfaceController.h"

@interface InterfaceController() <OEEventsObserverDelegate>

@property (weak, nonatomic) IBOutlet WKInterfaceTable *listTable;

@property (strong, nonatomic) OEEventsObserver *openEarsEventsObserver;

@property (nonatomic, strong) NSDictionary *wordReplacements;

@property (nonatomic) NSInteger rowIndex;

@property (nonatomic) NSInteger fontSize;

@property (nonatomic) BOOL isFontSizeChangePending;

@property (nonatomic, strong) NSMutableArray *listItems;

@end

#warning - TODO
/*
 mic permission in extension??
 if wrist put down, does extension go out of memory or stick around?
 undo/redo with NSUndoManager
 needs logic to not assert on certain commands since there is no replacement - (clean/undo/redo)
 could use paging for multiple lists
 ANGLES - 45 DEGREES RIGHT, LEFT, ETC
 cubic dimensions - x by y by z
 ability to switch vocabularies - needed to support other types of lists
 twenty one would currently translate to 201
 issue with framework always being forgotten
 prsent text input with controller
 commands interface controller
*/

@implementation InterfaceController

static NSString * const kClearCommand = @"CLEAR LIST";

#pragma mark - Init / Dealloc

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        _rowIndex = 0;
        _fontSize = 12;
        _isFontSizeChangePending = NO;
        _listItems = [NSMutableArray new];
        [self initializeWordReplacements];
    }
    
    return self;
}

- (void)initializeWordReplacements
{
    self.wordReplacements = @{ @"ONE" : @"1",
                               @"TWO" : @"2",
                               @"THREE" : @"3",
                               @"FOUR" : @"4",
                               @"FIVE" : @"5",
                               @"SIX" : @"6",
                               @"SEVEN" : @"7",
                               @"EIGHT" : @"8",
                               @"NINE" : @"9",
                               @"TEN" : @"10",
                               @"ELEVEN" : @"11",
                               @"TWELVE" : @"12",
                               @"THIRTEEN" : @"13",
                               @"FOURTEEN" : @"14",
                               @"FIFTEEN" : @"15",
                               @"SIXTEEN" : @"16",
                               @"SEVENTEEN" : @"17",
                               @"EIGHTEEN" : @"18",
                               @"NINETEEN" : @"19",
                               @"TWENTY" : @"20",
                               @"THIRTY" : @"30",
                               @"FORTY" : @"40",
                               @"FIFTY" : @"50",
                               @"SIXTY" : @"60",
                               @"SEVENTY" : @"70",
                               @"EIGHTY" : @"80",
                               @"NINETY" : @"90",
                               @"AND" : @" ",
                               @"A" : @"1",
                               @"INCHES" : @"\"",
                               @"INCH" : @"\"",
                               @"FEET" : @"'",
                               @"FOOT" : @"'",
                               @"BY" : @" x ",
                               @"QUARTER" : @"/4",
                               @"QUARTERS" : @"/4",
                               @"FOURTH" : @"/4",
                               @"FOURTHS" : @"/4",
                               @"EIGHTH" : @"/8",
                               @"EIGHTHS" : @"/8",
                               @"HALF" : @"/2",
                               @"SIXTEENTH" : @"/16",
                               @"SIXTEENTHS" : @"/16" };
}

- (void)awakeWithContext:(id)context
{
    [super awakeWithContext:context];
    
    [self configureFirstTableRow];
    [self configureOpenEars];
    
    [self configureFontSizeNotification];
    
    //[self pocketsphinxDidReceiveHypothesis:@"FIVE FEET ONE AND A QUARTER INCHES BY FOUR AND THREE EIGHTHS INCHES" recognitionScore:@"0" utteranceID:@"12"];
}

#pragma mark - Interface Lifecycle

- (void)willActivate
{
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    
    if (self.isFontSizeChangePending)
    {        
        for (int index = 0; index < self.listItems.count + 1; index++)
        {
            ListRowController *row = [self.listTable rowControllerAtIndex:index];
            [row formatWithFontSize:self.fontSize];
        }
        
        self.isFontSizeChangePending = NO;
    }
}

- (void)didDeactivate
{
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

#pragma mark - Private Methods

- (void)configureFirstTableRow
{
    self.rowIndex = 0;
    [self.listTable setNumberOfRows:1 withRowType:[ListRowController identifier]];
    
    ListRowController *row = [self.listTable rowControllerAtIndex:0];
    [row formatForStartListening];
}

- (void)configureFontSizeNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveFontSizeChangeNotification:)
                                                 name:kFontSizeChangeNotification
                                               object:nil];
}

- (void)configureOpenEars
{
    NSArray *words = [NSArray arrayWithObjects:@"ONE", @"TWO", @"THREE", @"FOUR", @"FIVE", @"SIX", @"SEVEN", @"EIGHT", @"NINE", @"TEN",
                      @"ELEVEN", @"TWELVE", @"THIRTEEN", @"FOURTEEN", @"FIFTEEN", @"SIXTEEN", @"SEVENTEEN", @"EIGHTEEN", @"NINETEEN",
                      @"TWENTY", @"THIRTY", @"FORTY", @"FIFTY", @"SIXTY", @"SEVENTY", @"EIGHTY", @"NINETY", @"ONE HUNDRED",
                      @"AND", @"A", @"INCHES", @"INCH", @"FEET", @"FOOT", @"BY"
                      @"QUARTER", @"QUARTERS", @"FOURTH", @"FOURTHS", @"EIGHTH", @"EIGHTHS", @"HALF", @"SIXTEENTH", @"SIXTEENTHS",
                      kClearCommand, nil];
    
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
    
    //Across-the-board noise reduction can be achieved by increasing the value of vadThreshold.
    [[OEPocketsphinxController sharedInstance] setVadThreshold:3.5];
}

- (void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex
{
    [self pocketsphinxDidReceiveHypothesis:kClearCommand recognitionScore:@"0" utteranceID:@"12"];
    //[self pocketsphinxDidReceiveHypothesis:@"FIVE FEET ONE AND A QUARTER INCHES BY FOUR AND THREE EIGHTHS INCHES" recognitionScore:@"0" utteranceID:@"12"];
}

#pragma mark - Menu Actions

- (IBAction)didSelectMenuItemCommands
{
    [self presentControllerWithName:[CommandsInterfaceController identifier] context:nil];
}

- (IBAction)didSelectMenuItemTextSize
{
    [self presentControllerWithName:[TextSizeInterfaceController identifier] context:[NSNumber numberWithFloat:self.fontSize]];
}

#pragma mark - Notifications

- (void)didReceiveFontSizeChangeNotification:(NSNotification *)notification
{
    self.isFontSizeChangePending = YES;
    
    NSDictionary *fontSizeDictionary = notification.userInfo;
    NSNumber *fontSizeNumber = fontSizeDictionary[kFontSizeKey];
    self.fontSize = fontSizeNumber.intValue;
}

#pragma mark - OEEventsObserverDelegate

- (void)pocketsphinxDidReceiveHypothesis:(NSString *)hypothesis recognitionScore:(NSString *)recognitionScore utteranceID:(NSString *)utteranceID
{    
    NSLog(@"The received hypothesis is %@ with a score of %@ and an ID of %@", hypothesis, recognitionScore, utteranceID);
    
    if ([hypothesis isEqualToString:kClearCommand])
    {
        NSIndexSet *indexesToRemove = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.listTable.numberOfRows)];
        [self.listTable removeRowsAtIndexes:indexesToRemove];
        [self configureFirstTableRow];
        [self.listItems removeAllObjects];
        return;
    }
    
    NSArray *words = [hypothesis componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
#warning - do I need to use a set of rules here dynamic grammar generation - http://www.politepix.com/2014/04/10/openears-1-7-introducing-dynamic-grammar-generation/
    
    NSMutableString *displayString = [NSMutableString new];
    for (NSString *word in words)
    {
        NSString *transformedWord = self.wordReplacements[word];
        
        if (!transformedWord)
        {
            //NSAssert(NO, @"Didn't find matching word!");
            NSLog(@"Didn't find matching word %@", transformedWord);
            return;
        }
        
        if ([displayString hasSuffix:@"'"] && ![transformedWord hasPrefix:@" "])
        {
            [displayString appendString:@" "];
        }
        
        [displayString appendString:transformedWord];
    }
    
    if ([displayString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0)
    {
        return;
    }
    
    [self.listItems addObject:displayString];
    
    ListRowController *row = [self.listTable rowControllerAtIndex:self.rowIndex];
    [row formatWithListItem:displayString withFontSize:self.fontSize];
    
    NSIndexSet *newIndexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(++self.rowIndex, 1)];
    [self.listTable insertRowsAtIndexes:newIndexes withRowType:[ListRowController identifier]];
    row = [self.listTable rowControllerAtIndex:self.rowIndex];
    [row formatForStartListening];
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



