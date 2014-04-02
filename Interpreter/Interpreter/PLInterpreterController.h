/**
 * \file PLInterpreterController.h
 * \brief Liasis Python IDE interpreter controller
 *
 * \details
 * This file contains the public and interface for a Python
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

#import <Foundation/Foundation.h>
#import <Python/Python.h>
#import <LiasisKit/LiasisKit.h>
#import "PLInterpreterHistory.h"

/**
 * \class PLInterpreterController \headerfile \headerfile
 * \brief The controller for the interpreter view extension.
 *
 * \details This class handles all input into the interpreter and returns the
 *          output of the interpreter.
 *
 *          Input/output of strings is handled through the Python C API. Liasis
 *          initializes a Python interpreter on startup. This class controls
 *          sending commands to that interpreter from the user by translating
 *          NSString objects to PyObject C structs. It supports single-input and
 *          multiline input. Output is handled by redirecting stdout and stderr
 *          from the interpreter to a Python object defined by this class.
 *
 *          This class stores a recallable history of input entries accessible
 *          with the directional arrows. It limits user input to the current
 *          line and prevents deletion of the interpreter prompt.
 *
 * \todo Implement real autocomplete.
 * \todo Fix interfacing with matplotlib (or other graphical packages)
 *
 */
@interface PLInterpreterController : NSObject <NSTextViewDelegate> {
        /**
         * \brief The location of the interpreter prompt. Used to restrict
         *        editing to only after the prompt.
         */
        NSUInteger promptLocation;
        
        /**
         * \brief Store the history of each input to the interpreter.
         */
        PLInterpreterHistory * historyObject;
        
        /**
         * \brief The text view of the interpreter. The output of the
         *        interpreter is displayed to this view.
         */
        IBOutlet NSTextView * interpreterView;
        
        /**
         * \brief The interpreter object. Currently used in a test for
         *        responding to the autocompleteAction selector before
         *        performing an autocompletion.
         */
        IBOutlet id interpreter;
        
        /**
         * \brief A selector used for autocomplete. (more details?)
         */
        SEL autocompleteAction;
        
        /**
         * \brief Redirect the Python stdout and stderr to this object so that
         * it can be retrieved and printed through the NSTextView.
         */
        PyObject * pyOutputCatcher;
        
        /**
         * \brief The __main__ module for the interpreter. Use this to provide
         * the globals dict for each input expression.
        */
        PyObject * pyMainModule;
        
        /**
         * \brief Append to this string to provide support for multiline input.
        */
        NSMutableString * multilineInputString;
}

/**
 * \brief Add the prompt symbol to the end of the interpreter.
 *
 * \details The prompt symbol changes whether the next line of input is a new
 *          statement (>>>) or a line continuation (...).
 */
-(void)setPromptAtEnd;

@end
