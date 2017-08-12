//
//  ButtonCell.h
//  ImageLabeling
//
//  Created by Krzysztof on 21/04/2017.
//
//  Distributed under the MIT License.
//  See the LICENSE file for more information.
//


#import <Cocoa/Cocoa.h>

/**
 * Custom cell for NSButton
 */
@interface ButtonCell : NSButtonCell

@property (nonatomic, strong) NSColor *textColor;
@property (nonatomic, strong) NSColor *selectedTextColor;
@property (nonatomic, strong) NSColor *highlightedTextColor;
@property (nonatomic, strong) NSColor *disabledTextColor;

@property (nonatomic, strong) NSImage *highlightedImage;

@property (nonatomic, strong) NSImage *backgroundImage;
@property (nonatomic, strong) NSImage *selectedBackgroundImage;
@property (nonatomic, strong) NSImage *highlightedBackgroundImage;
@property (nonatomic, strong) NSImage *disabledBackgroundImage;

// Inset for icon from edge of the button
@property (nonatomic, assign) CGFloat iconInset;


@end
