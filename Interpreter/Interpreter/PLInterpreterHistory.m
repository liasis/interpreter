/**
 * \file PLInterpreterHistory.m
 * \brief Liasis Python IDE interpreter history
 *
 * \details This file contains the implementation for a Python interpreter
 *          history object. It controls storing and retreiving previously
 *          entered input to the interpreter.
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

#import "PLInterpreterHistory.h"

#pragma mark -

@implementation PLInterpreterHistory

@synthesize historyLength;

#pragma mark Initialization and Deallocation

/**
 * \brief Initialize the PLInterpreterHistory object.
 *
 * \return An initialized PLInterpreterHistory object.
 */
-(id)init
{
    self = [super init];
    if (self) {
            
    }
    return self;
}

-(id)initWithHistoryLength:(NSUInteger)length
{
        self = [super init];
        if (self) {
                historyLength = length + 1;
                history = [[NSMutableArray alloc] initWithCapacity:historyLength];
                activeIndex = 0;
                displayed = 0;
        }
        return self;
}

/**
 * \brief Deallocate the PLInterpreterHistory object
 *
 * \details Release the history array.
 */
-(void)dealloc
{
        [history release];
        [super dealloc];
}

#pragma mark History Processing

-(NSString *)nextHistory
{
        NSString * historyItem = nil;
        NSUInteger i;
        NSString * partialString = nil;
        if ([history count] == 0)
                goto exit;
        if (displayed == activeIndex) {
                goto exit;
        }
        partialString = [history objectAtIndex:activeIndex];
        if ([partialString length] == 0) {
                i = (displayed+1) % historyLength;
                if (i < [history count]) {
                        displayed = i;
                        historyItem = [history objectAtIndex:i];
                }
                goto exit;
        }
        for (i = (displayed+1) % historyLength; i != activeIndex; i = (i + 1) % historyLength) {
                if (i >= [history count])
                        break;
                historyItem = [history objectAtIndex:i];
                if ([historyItem rangeOfString:partialString].location != NSNotFound) {
                        displayed = i;
                        break;
                } else {
                        historyItem = nil;
                }
        }
        if (i == activeIndex) {
                historyItem = [history objectAtIndex:activeIndex];
        }
exit:
        return historyItem;
}

-(NSString *)previousHistory
{
        NSString * historyItem = nil;
        NSInteger i;
        NSString * partialString = nil;
        if ([history count] == 0) {
                goto exit;
        }
        partialString = [history objectAtIndex:activeIndex];
        if (displayed == (activeIndex+1) % historyLength) {
                goto exit;
        }
        if ([partialString length] == 0) {
                i = displayed-1;
                if (i < 0)
                        i = historyLength+i;
                i %= historyLength;
                if (i < [history count]) {
                        displayed = i;
                        historyItem = [history objectAtIndex:i];
                }
                goto exit;
        }
        for (i = (displayed-1) % historyLength; i != (activeIndex+1) % historyLength; i = (i - 1) % historyLength) {
                if (i >= [history count])
                        break;
                historyItem = [history objectAtIndex:i];
                if ([historyItem rangeOfString:partialString].location != NSNotFound) {
                        displayed = i;
                        break;
                } else {
                        historyItem = nil;
                }
        }
exit:
        return historyItem;
}

-(void)addEntry:(NSString *)aString
{
        [history insertObject:[NSString stringWithString:aString] atIndex:activeIndex];
        activeIndex = (activeIndex + 1) % historyLength;
        [self setCurrentString:@""];
}

-(void)setCurrentString:(NSString *)aString
{
        if (activeIndex < [history count])
                [history removeObjectAtIndex:activeIndex];
        [history insertObject:[NSString stringWithString:aString] atIndex:activeIndex];
        displayed = activeIndex;
}

@end
