/**
 * \file PLInterpreterViewController.m
 * \brief Liasis Python IDE interpreter view controller implementation file.
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

#import "PLInterpreterViewController.h"

@implementation PLInterpreterViewController

#pragma mark - Plug-In View Controller Methods

+(PLAddOnType)type
{
        return PLAddOnExtension;
}

+(NSString *)tabSubviewName
{
        return @"Python Interpreter";
}

+(id)viewController
{
        PLInterpreterViewController * viewController;
        viewController = [[self alloc] initWithNibName:@"PLInterpreterViewController" bundle:[NSBundle bundleForClass:self]];
        return [viewController autorelease];
}

+(id)viewControllerWithDocument:(id)document
{
        return [self viewController];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
        self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
        [self loadView];
        if (self) {
                [interpreterController setPromptAtEnd];
                [scrollView setVerticalScroller:[[PLScroller new] autorelease]];
                [(PLScroller *)[scrollView verticalScroller] setDocumentView:textView];
                [self updateThemeManager];
                [self updateFont:[[NSFontManager sharedFontManager] selectedFont]];
        }
        return self;
}

#pragma mark - PLThemeable

-(void)updateThemeManager
{
        [textView setBackgroundColor:[[PLThemeManager defaultThemeManager] getThemeProperty:PLThemeManagerBackground
                                                                                  fromGroup:PLThemeManagerSettings]];
        [textView setTextColor:[[PLThemeManager defaultThemeManager] getThemeProperty:PLThemeManagerForeground
                                                                            fromGroup:PLThemeManagerSettings]];
        [textView setSelectedTextAttributes:@{NSBackgroundColorAttributeName:[[PLThemeManager defaultThemeManager] getThemeProperty:PLThemeManagerSelection
                                                                                                                          fromGroup:PLThemeManagerSettings]}];
        [scrollView setBackgroundColor:[[PLThemeManager defaultThemeManager] getThemeProperty:PLThemeManagerBackground
                                                                                    fromGroup:PLThemeManagerSettings]];
}

-(void)updateFont:(NSFont *)font
{
        [textView setFont:font];
}

#pragma mark - PLTabSubviewController

-(NSString *)title
{
        return @"Python-shell";
}

-(BOOL)tabSubviewShouldClose:(id)sender
{
        BOOL shouldClose = YES;
exit:
        return shouldClose;
}


-(IBAction)openFile:(id)sender
{
        return;
}

-(IBAction)saveFile:(id)sender
{
        return;
}

-(IBAction)saveFileAs:(id)sender
{
        return;
}

-(id)document
{
        return nil;
}

#pragma mark - Responder Chain

/**
 * \brief NSResponder method prior to accepting first responder status.
 *
 * \details Set the window's first responder to the textView.
 *
 * \return Always return YES, indicating that the view controller accepted
 *         first responder status.
 */
-(BOOL)becomeFirstResponder
{
        [[[self view] window] makeFirstResponder:textView];
        return YES;
}

@end
