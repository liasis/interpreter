/**
 * \file PLInterpreterHistory.h
 * \brief Liasis Python IDE interpreter history
 *
 * \details This file contains the interface for a Python interpreter history
 *          object. It controls storing and retreiving previously entered input
 *          to the interpreter.
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

#import <Foundation/Foundation.h>

/**
 * \class PLInterpreterHistory \headerfile \headerfile
 * \brief Manage storing and displaying the history of input into the
 *        interpreter.
 *
 * \details The PLInterpreterHistory provides an interface for adding items to
 *          the history and recalling them sequentially. Recalling items will
 *          match the currently input text in the interpreter, such that if the
 *          user has input 'x = ', recalling the history will only include items
 *          that begin with that string.
 */
@interface PLInterpreterHistory : NSObject {
        /**
         * \brief The array of history items, storing a string for each input
         *        into the interpreter.
         *
         * \details The array is used to implement a ring-like structure. An
         *          active index is chosen, which stores the current input string
         *          and search backward in history is implemented as a search by 
         *          decreasing the index in the array from the active index such
         *          that the previous ith command is the active index minus i, until 
         *          the previous index is again the active index. If the history
         *          index goes below zero, it returns to the end of the array.
         *          For next history elements, instead of searching backward,
         *          it searches forward until the next index is the active index.
         */
        NSMutableArray * history;
        /**
         * \brief The index that indicates the active index in the 
         *        array that holds a copy of the current input string.
         */
        NSUInteger activeIndex;
        /**
         * \brief The index of the history array element that is currently being
         *        displayed in the interpreter.
         *
         * \details Editing the interpreter only affects the array element at 
         *          the active index as determined by the activeIndex internal 
         *          variable.
         */
        NSUInteger displayed;
        /**
         * \brief The internal variable that indicates the maximum number of the
         *        history elements that can stored.
         */
        NSUInteger historyLength;
}

#pragma mark Properties

@property(readonly) NSUInteger historyLength;

#pragma mark Initialization

/**
 * \brief Initialize the PLInterpreterHistory object with a length.
 *
 * \details Allocate the history array, set the historyLength instance variable
 *          to the input length parameter, and initialize the activeIndex and displayed
 *          to 0.
 *
 * \param length The history length.
 *
 * \return An initialized PLInterpreterHistory object.
 *
 */
-(id)initWithHistoryLength:(NSUInteger)length;

#pragma mark History Processing

/**
 * \brief Method to get a newer history element.
 *
 * \details This method moves forward in the ring-structure by increasing the index
 *          of the displayed entry in the history ring by one. Once the displayed index
 *          reaches the history length, it cycles back to the zero index by using
 *          the modulus operator. The next history is retrieved until the displayed
 *          index is the same as the activeIndex, meaning the history is at
 *          the active element in the history ring/array. 
 *
 * \return The NSString that is stored at the new displayed index.
 */
-(NSString *)nextHistory;

/**
 * \brief Method to get an older history element.
 *
 * \details This method moves backward in the ring-structure by decreasing the index
 *          of the displayed entry in the history ring by one. Once the displayed index
 *          reaches zero, it cycles forward to the history length index by using
 *          the modulus operator. The previous history element is retrieved until
 *          the displayed index is the same as the activeIndex plus one,
 *          indicating it has reached the last element in the history ring.
 *
 * \return The NSString that is stored at the new displayed index.
 */
-(NSString *)previousHistory;

/**
 * \brief Adds a new string value at the activeIndex of the history array.
 *
 * \details This method sets the string value at the active index of the NSArray,
 *          and increases the value of the activeIndex by one. Once the active
 *          index has reached the maximum permissible index defined by historyLength,
 *          it cycles back to zero thus creating a ring-like structure.
 *
 * \param aString The new NSString object to be set at the activeIndex of the
 *                history array.
 */
-(void)addEntry:(NSString *)aString;

/**
 * \brief Method to set the string value at the activeIndex in the history array,
 *        representing the active element in the ring structure.
 *
 * \details This method only saves the string value that is being edited at the
 *          to allow for cycling back and forward to the original input command.
 *          All edits at the prompt should update the current string.
 *
 * \param aString An NSString object that contains the same string that is 
 *                existing at the prompt of the interpreter.
 */
-(void)setCurrentString:(NSString *)aString;


@end
