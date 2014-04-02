/**
 * \file PLInterpreterController.m
 * \brief Liasis Python IDE interpreter controller
 *
 * \details
 * This file contains the public and private methods and interface for a Python
 * interpreter controller. It passes input from the user to an internal
 * interpreter and returns the output as if running Python from the terminal.
 *
 * \copyright Copyright (C) 2012-2014 Jason Lomnitz and Danny Nicklas.
 *
 * This file is part of the Python Liasis IDE.
 *
 * The Python Liasis IDE is free software: you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * The Python Liasis IDE is distributed in the hope that it will be
 * useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with the Python Liasis IDE. If not, see <http://www.gnu.org/licenses/>.
 *
 * \author Jason Lomnitz.
 * \author Danny Nicklas
 * \date 2012-2014.
 */

#import "PLInterpreterController.h"

#pragma mark Interpreter Prompts

/**
 * \brief The standard prompt string for single line entry.
 */
NSString * const PLInterpreterControllerPromptString = @">>> ";

/**
 * \brief The prompt string for a continuation line.
 */
NSString * const PLInterpreterControllerContinuationPromptString = @"... ";

#pragma mark -

@implementation PLInterpreterController

#pragma mark Initialization and Deallocation

/**
 * \brief Initialize the PLInterpreterController.
 */
-(id)init
{
    self = [super init];
    return self;
}

/**
 * \brief Release the history and multiline instance variables, decrement the
 *        pyOutputCatcher Python object, and finalize the Python interpreter.
 */
-(void)dealloc
{
        Py_DECREF(pyOutputCatcher);
        [historyObject release];
        [multilineInputString release];
        [super dealloc];
}

/**
 * \brief Initialize the prompt and python interpreter.
 *
 * \details Upon initialization, the python interpreter creates an internal
 *          object and sets stdout and stderr to write to that object. This is
 *          done by importing the sys module and creating a class that
 *          implements a method 'write' to append a string to its internal
 *          string instance variable. By setting sys.stdout and sys.stderr, this
 *          object writes all iterpreter output to its instance variable.
 */
-(void)awakeFromNib
{
        promptLocation = 3;
        
        pyMainModule = PyImport_AddModule("__main__");
        PyRun_SimpleString("import sys\n"
                           "class __CatchOutErr:\n"
                           "    def __init__(self):\n"
                           "        self.value = ''\n"
                           "    def write(self, txt):\n"
                           "        self.value += txt\n"
                           "__catchOutErr = __CatchOutErr()\n"
                           "sys.stdout = __catchOutErr\n"
                           "sys.stderr = __catchOutErr\n");
        pyOutputCatcher = PyObject_GetAttrString(pyMainModule, "__catchOutErr");
        historyObject = [[PLInterpreterHistory alloc] initWithHistoryLength:20];
        multilineInputString = [[NSMutableString alloc] initWithString:@""];
}

#pragma mark Interpreter Prompt

/**
 * \brief Add the prompt symbol to the end of the interpreter.
 *
 * \param promptString The prompt string to use (one of >>> or ...) depending
 *                     on the type of input line (new command or continuation).
 */
-(void)setPromptAtEnd:(NSString *)promptString
{
        NSTextStorage * textStorage = [interpreterView textStorage];
        NSAttributedString * prompt;
        prompt = [[NSAttributedString alloc]
                  initWithString:promptString
                  attributes:[NSDictionary dictionaryWithObjectsAndKeys:
                              [interpreterView font], NSFontAttributeName,
                              [interpreterView textColor], NSForegroundColorAttributeName,
                              nil]];
        [textStorage appendAttributedString:prompt];
        promptLocation = [[textStorage string] length];
        [prompt release];
}

-(void)setPromptAtEnd
{
        [self setPromptAtEnd:PLInterpreterControllerPromptString];
}

#pragma mark Process Interpreter Input

/**
 * \brief Execute statement in the python interpreter and return output string.
 *
 * \details This method accepts an NSString as input and passes it to the python
 *          interpreter as a UTF8 string. Using the internally defined and
 *          created pythonobject to catch stdout and stderr, this method
 *          retrieves the python output and returns it as an NSString. If an
 *          executed statement displays no output in the interpreter, this
 *          method returns an empty string. As stdout is appended with each
 *          output, this method only returns the newly added segment.
 *
 * \param inputString The string passed to the interpreter.
 *
 * \return The output from running the command in the interpreter.
 */
-(NSString *)runPythonCommand:(NSString *)inputString
{
        if ([inputString isEqualToString:@""])
                return @"";
        NSUInteger beforeLength = [[NSString stringWithUTF8String:PyString_AsString(PyObject_GetAttrString(pyOutputCatcher, "value"))] length];
        PyObject * dict = PyModule_GetDict(pyMainModule);
        PyRun_String([inputString UTF8String], Py_single_input, dict, dict);
        PyErr_Print();
        PyObject * pyOutput = PyObject_GetAttrString(pyOutputCatcher, "value");  // get the stdout and stderr from catchOutErr object
        NSString * output = [NSString stringWithUTF8String:PyString_AsString(pyOutput)];
        Py_DECREF(pyOutput);
        if ([output length] == beforeLength)
                return @"";
        else
                return [output substringWithRange:NSMakeRange(beforeLength, [output length] - beforeLength)];
}

/**
 * \brief Evaluate the string input into the interperter.
 *
 * \details This method passes the string input into the interpreter that is
 *          received after a newline is entered by the user. If the string
 *          includes a line continuation feature (semicolon or backlash, the
 *          statement is stored to the multilineInputString instance variable.
 *          This multiline string is evaluated after the user enters a blank
 *          string. Add user input to the history of the interpreter.
 */
-(void)processNewline
{
        NSAttributedString * attrString;
        NSString * promptString = PLInterpreterControllerPromptString;
        NSString * inputString = [[interpreterView string] substringFromIndex:promptLocation];
        NSMutableString * outputString = [[NSMutableString alloc] initWithString:@"\n"];
        if ([inputString isEqualToString:@""]) {
                if ([multilineInputString isEqualToString:@""] == NO) {
                        [outputString appendString:[self runPythonCommand:multilineInputString]];
                        [multilineInputString setString:@""];
                }
                goto exit;
        }
        
        const char lastInputCharacter = [inputString characterAtIndex:[inputString length] - 1];
        if (lastInputCharacter == ':' || lastInputCharacter == '\\' || [multilineInputString isEqualToString:@""] == NO) {
                [multilineInputString appendString:[NSString stringWithFormat:@"%@\n", inputString]];
                promptString = PLInterpreterControllerContinuationPromptString;
                [historyObject addEntry:inputString];
        }
        else {
                //        if ([interpreter respondsToSelector:inputAction]) {
                //                [outputString appendString:[interpreter performSelector:inputAction withObject:inputString]];
                //        } else {
                //                NSLog(@"Warning: Interpreter is unresponsive: \"%@\" not sent", inputString);
                //        }
                [outputString appendString:[self runPythonCommand:inputString]];
                [historyObject addEntry:inputString];
        }
        
exit:
        attrString = [[NSAttributedString alloc] initWithString:outputString
                                                     attributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                 [interpreterView font], NSFontAttributeName,
                                                                 [interpreterView textColor], NSForegroundColorAttributeName,
                                                                 nil]];
        [[interpreterView textStorage] appendAttributedString:attrString];
        [attrString release];
        [self setPromptAtEnd:promptString];
        [interpreterView setSelectedRange:NSMakeRange(promptLocation, 0)];
        [interpreterView scrollToEndOfDocument:self];
        [outputString release];
}

/**
 * \brief Process a user insertion input into the interpreter.
 *
 * \details This method checks if the insertion occurred within a prompt string
 *          and rejects it if so. Next it checks if the insertion was a newline
 *          or tab character, in which it calls processNewline: or processTab:
 *          methods, respectively. Otherwise, it inputs the text as entered.
 *
 * \param insertion The string inserted in the interperter.
 *
 * \param location The location where the insertion is desired.
 *
 * \return A boolean specifying if the insertion should be inserted directly.
 */
-(BOOL)shouldProcessInsertion:(NSString *)insertion atLocation:(NSUInteger)location
{
        char singleCharacter;
        BOOL shouldEdit = YES;
        if ([insertion length] == 0) {
                shouldEdit = NO;
                goto exit;
        }
        singleCharacter = [insertion characterAtIndex:0];
        NSRange endOfTextView;
        if (location < promptLocation) {
                shouldEdit = NO;
                endOfTextView = NSMakeRange([[interpreterView string] length], 0);
                [interpreterView insertText:insertion
                           replacementRange:endOfTextView];
                endOfTextView.location += 1;
                [interpreterView setSelectedRange:endOfTextView];
                goto exit;
        }
        if ([insertion length] == 1) {
                switch (singleCharacter) {
                        case '\n':
                                shouldEdit = NO;
                                [self processNewline];
                                break;
                        case '\t':
                                shouldEdit = NO;
                                [self processTab];
                                break;
                        default:
                                shouldEdit = YES;
                                break;
                }                        
        }
exit:
        return shouldEdit;
}

/**
 * \brief Process a user deletion event in the interpreter.
 *
 * \details This method rejects any deletion of the interpreter prompt or above
 *          the current line.
 *
 * \param aRange The range of the deletion.
 *
 * \return A boolean specifying if the deletion should be performed.
 */
-(BOOL)shouldProcessDeletionInRange:(NSRange)aRange
{
        BOOL shouldEdit = YES;
        NSAttributedString *emptyString = [[NSAttributedString alloc] initWithString:@""];
        if (aRange.location < promptLocation) {
                shouldEdit = NO;
                aRange.length -= promptLocation-aRange.location;
                aRange.location = promptLocation;
                [[interpreterView textStorage] replaceCharactersInRange:aRange
                                                   withAttributedString:emptyString];
        }
        [emptyString release];
        return shouldEdit;
}

/**
 * \brief Process a user replacement of text in the interpreter.
 *
 * \details This method rejects any replacement of the interpreter prompt or
 *          text above the current line.
 *
 * \param aRange The range of the replacement.
 *
 * \param replacement The replacement string.
 *
 * \return A boolean specifying if the replacement should be performed.
 */
-(BOOL)shouldProcessReplacementInRange:(NSRange)aRange withReplacementString:(NSString *)replacement
{
        BOOL shouldEdit = YES;
        if (aRange.location < promptLocation) {
                shouldEdit = NO;
                aRange.length -= promptLocation-aRange.location;
                aRange.location = promptLocation;
                [interpreterView insertText:replacement replacementRange:aRange];
        }
        return shouldEdit;
}

/**
 * \brief Process all text input in the interpreter.
 *
 * \details This method determines if the text change is an insertion, deletion,
 *          or replacement. It then calls the appropriate method
 *          (shouldProcessInsertion:atLocation, shouldProcessDeletionInRange:,
 *          or shouldProcessReplacementInRange:withReplacementString) to
 *          determine whether or not the insertion is accepted as is. If so,
 *          the text is added to the historyObject instance variable.
 *
 * \param textView The text view where text is changed.
 *
 * \param affectedCharRange The range of characters to be changed.
 *
 * \param replacementString The input string to replace in the character range.
 *
 * \return A boolean specifying if the text change should be performed.
 */
-(BOOL)textView:(NSTextView *)textView shouldChangeTextInRange:(NSRange)affectedCharRange replacementString:(NSString *)replacementString
{
        NSMutableString * currentString = nil;
        NSRange lineRange;
        NSArray * linesToInsert = nil;
        BOOL shouldChange = YES;
        char typeOfEdit  = 0;
        const char INSERTION = 1;
        const char DELETION = 2;
        const char REPLACEMENT = 4;
        if (affectedCharRange.length == 0) {
                typeOfEdit = INSERTION;
        } else if ([replacementString length] == 0) {
                typeOfEdit = DELETION;
        } else {
                typeOfEdit = REPLACEMENT;
        }
        lineRange = [replacementString lineRangeForRange:NSMakeRange(0, 0)];
        switch (typeOfEdit) {
                case INSERTION:
                        if ([replacementString length] == lineRange.length) {
                                shouldChange = [self shouldProcessInsertion:replacementString
                                                                 atLocation:affectedCharRange.location];
                        } else {
                                linesToInsert = [replacementString componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
                                shouldChange = NO;
                                for (NSString * i in linesToInsert) {
                                        [textView insertText:i];
                                        [textView insertText:@"\n"];
                                }
                        }
                        break;
                case DELETION:
                        shouldChange = [self shouldProcessDeletionInRange:affectedCharRange];
                        break;
                case REPLACEMENT:
                        shouldChange = [self shouldProcessReplacementInRange:affectedCharRange
                                                       withReplacementString:replacementString];
                default:
                        break;
        }
        if (shouldChange) {
                currentString = [[NSMutableString alloc] initWithString:[[interpreterView string] substringFromIndex:promptLocation]];
                affectedCharRange.location -= promptLocation;
                [currentString replaceCharactersInRange:affectedCharRange withString:replacementString];
                [historyObject setCurrentString:currentString];
                [currentString release];
        }
exit:
        return shouldChange;
}

#pragma mark Autocomplete

/**
 * \brief Delegate method to provide an array of autocomplete options.
 *
 * \details Retrieve all keys in the module dict (with PyModule_GetDict) and
 *          filter them to those starting with the currently input string.
 *
 * \param words The proposed array of completions (from the Cocoa API docs).
 *
 * \param charRange The range of characters beginning the autocompletion.
 *
 * \param index The index within the array of autocompletion to select first.
 *
 * \return An array of autocompletions options. This is currently a statically
 *         defined array of strings until future implementation.
 */
-(NSArray *)textView:(NSTextView *)textView completions:(NSArray *)words forPartialWordRange:(NSRange)charRange indexOfSelectedItem:(NSInteger *)index
{
        NSString * inputString = nil;
        NSArray * variables = nil;
        NSError * error = nil;
        PyObject * pyDict = NULL;
        PyObject * pyVariables = NULL;
        __block NSString * variablesErrorMessage = nil;

        inputString = [[interpreterView string] substringWithRange:charRange];
        pyDict = PyModule_GetDict(pyMainModule);
        pyVariables = PyDict_Keys(pyDict);

        variables = [NSArray arrayByEnumeratingPythonSequence:pyVariables error:&error withBlock:^id(PyObject *obj, NSUInteger idx) {
                char * variable = PyString_AsString(obj);
                if (variable == NULL) {
                        variablesErrorMessage = [NSString stringWithFormat:@"Could not get item %lu from variable list", idx];
                        PyErr_Clear();
                        return nil;
                }
                return [NSString stringWithUTF8String:variable];
        }];
        if (variables == nil) {
                if (variablesErrorMessage)
                        [[error userInfo] setValue:variablesErrorMessage forKey:NSLocalizedFailureReasonErrorKey];

                /* TODO: need to have PLInterpreterViewController presentError: this error */
                NSLog(@"%@", error);
        }

        NSMutableArray * array = [NSMutableArray array];
        for (NSString * word in variables) {
                if ([word length] >= charRange.length) {
                        NSString * comparisonWord = [word substringToIndex:charRange.length];
                        if ([comparisonWord compare:inputString options:NSCaseInsensitiveSearch] == NSOrderedSame)
                                [array addObject:word];
                }
        }
        
        if ([interpreter respondsToSelector:autocompleteAction])
                array = [interpreter performSelector:autocompleteAction withObject:inputString];
        return [array sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}

/**
 * \brief Pressing tab issues autocomplete.
 *
 * \details Calls the complete: method of the interpreterView instance variable.
 */
-(void)processTab
{
        [interpreterView complete:self];
}

#pragma mark Interpreter History

/**
 * \brief Process an upwards (previous entry) query of interpreter history.
 *
 * \details Insert the previous entry in the historyObject instance variable
 *          into the current line of the interpreter.
 */
-(void)processHistoryUp
{
        NSAttributedString * newString;
        NSString *history;
        NSRange range;
        history = [historyObject previousHistory];
        if (history == nil)
                goto exit;
        range = NSMakeRange(promptLocation, [[interpreterView string] length]-promptLocation);
        newString = [[NSAttributedString alloc] initWithString:history
                                                    attributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                [interpreterView font], NSFontAttributeName,
                                                                [interpreterView textColor], NSForegroundColorAttributeName,
                                                                nil ]];

        [[interpreterView textStorage] replaceCharactersInRange:range
                                           withAttributedString:newString];
        [newString release];
exit:
        return;
}

/**
 * \brief Process a downwards (next entry) query of interpreter history.
 *
 * \details Insert the next entry in the historyObject instance variable
 *          into the current line of the interpreter.
 */
-(void)processHistoryDown
{
        NSAttributedString * newString;
        NSString *history;
        NSRange range;
        history = [historyObject nextHistory];
        if (history == nil)
                goto exit;
        range = NSMakeRange(promptLocation, [[interpreterView string] length]-promptLocation);
        newString = [[NSAttributedString alloc] initWithString:history
                                                    attributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                [interpreterView font], NSFontAttributeName,
                                                                [interpreterView textColor], NSForegroundColorAttributeName,
                                                                nil ]];
        
        [[interpreterView textStorage] replaceCharactersInRange:range
                                           withAttributedString:newString];
        [newString release];
exit:
        return;
}

#pragma mark Directional Input

/**
 * \brief Allow for directional navigation of the interpreter and access to the
 *        interpreter history.
 *
 * \details Replace input of the up and down directional arrows with a query
 *          to the previous and next history item, respectively. Page up and
 *          page down are replaced with moveUp: and moveDown: selectors,
 *          respectively. moveToBeginningOfParagraph: returns the cursor to
 *          the beginning of the interpreter session.
 *
 * \param commandSelector The input selector (up arrow, etc.)
 *
 * \return A boolean specifying if the command was performed for the given
 *         selector.
 */
-(BOOL)textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector
{
        NSString *aSelector;
        BOOL didCommand = NO;
        aSelector = [NSStringFromSelector(commandSelector) retain];
        if ([textView selectedRange].location < promptLocation) {
                goto exit;
        }
        if ([aSelector isEqualToString:@"moveUp:"]) {
                [self processHistoryUp];
                didCommand = YES;
        } else if ([aSelector isEqualToString:@"moveDown:"]) {
                [self processHistoryDown];
                didCommand = YES;
        } else if ([aSelector isEqualToString:@"scrollPageUp:"]) {
                [textView moveUp:self];
                didCommand = YES;
        } else if ([aSelector isEqualToString:@"scrollPageDown:"]) {
                [textView moveDown:self];
                didCommand = YES;
        } else if ([aSelector isEqualToString:@"moveToBeginningOfParagraph:"]) {
                [textView setSelectedRange:NSMakeRange(promptLocation, 0)];
                didCommand = YES;
        } 
exit:
        [aSelector release];
        return didCommand;
}

@end