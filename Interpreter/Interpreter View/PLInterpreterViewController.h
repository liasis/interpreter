/**
 * \file PLInterpreterViewController.h
 * \brief Liasis Python IDE interpreter view controller interface file.
 *
 * \details
 * This file contains the public and private methods and interface for an
 * interpreter view controller subclass. This class controls a set of views that
 * make up the interpreter capabilities of the python IDE.
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
 * \author Danny Nicklas.
 * \date 2012-2014.
 */

#import <Cocoa/Cocoa.h>
#import <LiasisKit/LiasisKit.h>
#import "PLInterpreterController.h"

/**
 * \class PLInterpreterViewController \headerfile \headerfile
 * \brief The view controller for the interpreter view extension.
 *
 * \details This class controls the text view and scroll view for the
 *          interpreter, accepting and displaying results in the text view
 *          by interacting with the PLInterpreterController. It defines the 
 *          interpreter view extension properties for the tab manager and
 *          handles all opening and saving operations. In addition, the
 *          PLInterpreterViewController provides the theme for interpreter.
 *
 *          Currently, saving and opening interpreter sessions is not supported.
 *
 * \see PLInterpreterController
 */
@interface PLInterpreterViewController : NSViewController <PLAddOnExtension>
{
        /**
         * \brief NSTextView representing the document text view.
         */
        IBOutlet NSTextView * textView;
        
        /**
         * \brief NSScrollView representing the document scroll view.
         */
        IBOutlet NSScrollView * scrollView;
        
        /**
         * \brief The interpreter controller, handling input and output to the
         *        interpreter.
         */
        IBOutlet PLInterpreterController * interpreterController;
}

#pragma mark - Plug-In View Controller Methods

/**
 * \brief Return the type of addon.
 *
 * \details This method provides the PLAddOnType of the interpreter.
 *
 * \return A PLAddOnType for the interpreter.
 */
+(PLAddOnType)type;

/**
 * \brief Return the name of the tab subview.
 *
 * \details This method provides the name of the interpreter for the tab
 *          subview.
 *
 * \return An NSString as the name of the tab subview.
 */
+(NSString *)tabSubviewName;

/**
 * \brief Initialize the interpreter view controller with a theme manager in
 *        a bundle.
 *
 * \details This method allocates and initializes the interpreter view
 *          controller in an NSBundle and sets its instance variable for the
 *          PLThemeManager.
 *
 * \return A newly initialized interpreter view controller.
 */
+(id)viewController;

#pragma mark - PLThemeable

/**
 * \brief Update the theme manager.
 *
 * \details Update the background and text color of the interpreter and the
 *          background of the scroll view.
 *
 */
-(void)updateThemeManager;

#pragma mark - PLTabSubviewController

/**
 * \brief Method called by tab view controller to change the name of the tab.
 *
 * \details This method is called by the tab view controller to get the
 *          title of the tab. The tab viw checks if the tab view title needs
 *          updating frequently, and therefore the title may change as different
 *          actions are performed by the tab view.
 *
 * \return An NSString * object containing the title of the tab subview controlled
 *         by the subview controller.
 */
-(NSString *)title;

/**
 * \brief Method called by tab view controller prior to removing a tab view item.
 *
 * \details This method is called by the tab view controller prior to removing a
 *          tab subview. The receiver, the subviw controller, may then perform
 *          actions prior to closing the tab. If the subview should not close,
 *          the receiver must return NO.
 *
 * \param id sender The object that sent the close message.
 *
 * \return A BOOL value indicating whether or not the tab subview should close.
 *         If YES, the tab view controller removes the tab subview. If NO, the
 *         tab subview is not removed and nothing is done.
 */
-(BOOL)tabSubviewShouldClose:(id)sender;

/**
 * \brief Method called by tab view controller when a file should be opened.
 *
 * \details This method is called by the tab view controller when an open event
 *          is intercepted, either by key equivalents or (TO DO) through the
 *          menu bar. The receiver, the subviw controller, may
 *          choose to take action, or ignore the command.
 *
 * \param id sender The object that sent the open message.
 */
-(IBAction)openFile:(id)sender;

/**
 * \brief Method called by tab view controller when a file should be saved.
 *
 * \details This method is called by the tab view controller when a save event
 *          is intercepted, either by key equivalents or (TO DO) through the
 *          menu bar. The receiver, the subviw controller, may
 *          choose to take action, or ignore the command.
 *
 * \param id sender The object that sent the open message.
 */
-(IBAction)saveFile:(id)sender;

/**
 * \brief Method called by tab view controller when a file should be saved as a
 *        new file.
 *
 * \details This method is called by the tab view controller when a save as event
 *          is intercepted, either by key equivalents or (TO DO) through the
 *          menu bar. The receiver, the subviw controller, may
 *          choose to take action, or ignore the command.
 *
 * \param id sender The object that sent the open message.
 */
-(IBAction)saveFileAs:(id)sender;

@end
