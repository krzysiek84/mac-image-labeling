//
//  View.h
//  ImageLabeling
//
//  Created by Krzysztof on 21/04/2017.
//
//  Distributed under the MIT License.
//  See the LICENSE file for more information.
//

#import <Cocoa/Cocoa.h>


/**
 * NSView Utils
 */
@interface NSView (Utils)

@property (nonatomic, assign) BOOL visible;

@end



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - View 


typedef void (^MouseTrackingBlock)(BOOL);

// NSView Replacement - allows custom background (yeah WOW) and other usefull stuff.

@interface View : NSView

// Allows setting user object
@property (nonatomic, strong) id userObject;
@property (nonatomic, strong) NSString *name;

@property (atomic, assign) NSInteger tag;


@property (nonatomic, copy) void (^mouseTrackingBlock)(BOOL);
@property (nonatomic, strong) NSTrackingArea *trackingArea;

@property (nonatomic, assign) BOOL userInteractionEnabled;

// On Mouse Click
@property (nonatomic, copy) void (^onMouseClicked)(View *view);
// When in table view, onMouseUp is never called, so use the on mouse down instead
@property (nonatomic, assign) BOOL notifyOnMouseDown;

@property (nonatomic, readonly) CGPoint clickLocation;
@property (assign) BOOL mouseDownCanMoveWindow;


// On Draw
@property (nonatomic, copy) void (^onDraw)(View *view, CGContextRef context);



// Visuals
@property (nonatomic, strong) NSColor *backgroundColor;
@property (nonatomic, strong) NSColor *borderColor;
@property (nonatomic, assign) CGFloat cornerRadius;



@property (atomic, assign, getter=isFlipped) BOOL flipped;
@property (atomic, assign) BOOL acceptsFirstResponder;
@property (atomic, assign) BOOL canBecomeKeyView;
@property (atomic, assign, getter=isOpaque) BOOL opaque;

@property (nonatomic, weak) NSObject<NSDraggingDestination> *dragAndDropDelegate;

// helper which makes the y flipped if necessary (based on view.superview.isFlipped)
+ (void)setFrame:(NSRect)rect view:(NSView *)view;

// When Set to true, on next setFrame layoutSubviews will be called.
@property (nonatomic, assign) BOOL requiresLayout;


// Called when frame is changed and one of the following was done before:
// Size of the view changes
// Subviews change
// User manually set requiresLayout before the frame is set.

@property (nonatomic, copy) void (^onLayout)(NSView *view);

- (void)layoutSubviews;


@end
