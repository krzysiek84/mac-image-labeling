//
//  Button.h
//  ImageLabeling
//
//  Created by Krzysztof on 21/04/2017.
//
//  Distributed under the MIT License.
//  See the LICENSE file for more information.
//


#import <Cocoa/Cocoa.h>


typedef NS_ENUM (NSUInteger, DTControlState) {
	DTControlStateNormal       = 0,
	DTControlStateHighlighted  = 1 << 0,
    DTControlStateDisabled     = 1 << 1,
    DTControlStateSelected     = 1 << 2
};

/**
 * Better NSButton
 */
@interface Button : NSButton


// Can be used to store additional info such as user id.
@property (nonatomic, strong) NSObject *userObject;

// Use block for simple actions
@property (nonatomic, copy) void (^onClick)(id sender);

// Selected
@property (nonatomic, assign) BOOL selected;



// Sets tiltle color
- (void)setTitleColor:(NSColor *)color forState:(DTControlState)state;

- (void)setImage:(NSImage *)image forState:(DTControlState)state;

- (void)setBackgroundImage:(NSImage *)image forState:(DTControlState)state;



@end
