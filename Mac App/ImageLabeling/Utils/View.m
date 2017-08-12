//
//  View.m
//  ImageLabeling
//
//  Created by Krzysztof on 21/04/2017.
//
//  Distributed under the MIT License.
//  See the LICENSE file for more information.
//


#import "View.h"
#import "NSView+Layout.h"

@implementation NSView (Utils)


- (BOOL)visible {
    return !self.hidden;
}

- (void)setVisible:(BOOL)visible {
    self.hidden = ! visible;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p>{ frame = %@, layer = <%@: %p> }", self.class, self,
            NSStringFromRect(self.frame), self.layer.class, self.layer];
}

@end




@interface View () {
    NSInteger _tag;
    
	BOOL _flipped;
    BOOL _mouseDownCanMoveWindow;
    BOOL _canBecomeKeyView;
    BOOL _acceptsFirstResponder;
    BOOL _opaque;
}

@end

@interface View()
@property (nonatomic, assign) CGPoint clickLocation;
@end

@implementation View


+ (void)setFrame:(NSRect)rect view:(NSView *)view {
	if (!view.superview.isFlipped) {
		rect.origin.y = view.superview.frame.size.height - NSMaxY(rect);
	}
	view.frame = rect;
}

- (void)sharedSetup {
    _flipped = YES;
    _opaque = YES;
    _userInteractionEnabled = YES;
    _backgroundColor = [NSColor whiteColor];
}



- (id)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        [self sharedSetup];
        
        // This has to be called when the flipped is known otherwise it f* the matrixes
        self.wantsLayer = YES;
    }
	return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self sharedSetup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder] ){
        
        [self sharedSetup];
        _flipped = NO;
        // This has to be called when the flipped is known otherwise it f* the matrixes
        self.wantsLayer = YES;
        
    }
    
    return self;
}


- (BOOL)isOpaque {
	return _opaque;
}

- (void)setOpaque:(BOOL)opaque {
    _opaque = opaque;
}



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Touches

- (void)mouseDown:(NSEvent *)theEvent {

    BOOL handled = NO;
    if (self.notifyOnMouseDown) {
        if (self.onMouseClicked){
            NSPoint location = [self convertPoint:[theEvent locationInWindow] fromView:nil];
            if (CGRectContainsPoint(self.bounds, location)) {
                self.clickLocation = location;
                self.onMouseClicked(self);
                handled = YES;
            }
        }
    }
    
    if (self.userInteractionEnabled && !handled) {
        [super mouseDown:theEvent];
    }
}

- (void)mouseMoved:(NSEvent *)theEvent {
	if (self.userInteractionEnabled) {
		[super mouseMoved:theEvent];
	}
}

- (void)mouseUp:(NSEvent *)theEvent {
	if (self.userInteractionEnabled) {

        if (self.onMouseClicked && !self.notifyOnMouseDown){
            NSPoint location = [self convertPoint:[theEvent locationInWindow] fromView:nil];
            if (CGRectContainsPoint(self.bounds, location)) {
                self.clickLocation = location;
                self.onMouseClicked(self);
            }
        } else {
            // Send event only if not handled already
            [super mouseUp:theEvent];
        }
	}
}

- (void)mouseDragged:(NSEvent *)theEvent {
	if (self.userInteractionEnabled) {
		[super mouseDragged:theEvent];
    } else {
        // FIXME: not sure if it should be called
        [self.nextResponder mouseDragged:theEvent];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Visuals


- (BOOL)isFlipped {
	return _flipped;
}


- (void)setFlipped:(BOOL)flipped {
	_flipped = flipped;
}

- (void)setTag:(NSInteger)tag {
    _tag = tag;
}

- (NSInteger)tag {
    return _tag;
}

- (void)setBackgroundColor:(NSColor *)backgroundColor {
    if (backgroundColor.alphaComponent < 1.0) {
        _opaque = NO;
    }
	_backgroundColor = backgroundColor;
	[self setNeedsDisplay:YES];
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    if (cornerRadius > 0) {
        _opaque = NO;
    }
	_cornerRadius = cornerRadius;
	[self setNeedsDisplay:YES];
}

- (void)setBorderColor:(NSColor *)borderColor {
	_borderColor = borderColor;
	[self setNeedsDisplay:YES];
}


// https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/CoreAnimation_guide/SettingUpLayerObjects/SettingUpLayerObjects.html#//apple_ref/doc/uid/TP40004514-CH13-SW2
- (void)drawRect:(NSRect)rect {
    
    CGContextRef context = NSGraphicsContext.currentContext.graphicsPort;
    CGContextSaveGState(context);
    

	if (self.cornerRadius > 0.0) {
		NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:CGRectInset(self.bounds, 0.5, 0.5) xRadius:self.cornerRadius yRadius:self.cornerRadius];

		if (self.backgroundColor) {
			[self.backgroundColor setFill];
			[path fill];
		}

		if (self.borderColor) {
			[self.borderColor setStroke];
			[path stroke];
		}
	}
	else {
		if (self.backgroundColor) {
            NSBezierPath *path = [NSBezierPath bezierPathWithRect:rect];
            [self.backgroundColor setFill];
            [path fill];
		}

		if (self.borderColor) {
			NSBezierPath *path = [NSBezierPath bezierPathWithRect:CGRectInset(self.bounds, 0.5, 0.5)];
			[self.borderColor setStroke];
			[path stroke];
		}
	}



    if (self.onDraw) {
        self.onDraw(self, context);
    }
    
	CGContextRestoreGState(context);
}



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Mouse Tracking

- (void)mouseEntered:(NSEvent *)theEvent {
	if (self.mouseTrackingBlock) {
		self.mouseTrackingBlock(YES);
	}
}

- (void)mouseExited:(NSEvent *)theEvent {
	if (self.mouseTrackingBlock) {
		self.mouseTrackingBlock(NO);
	}
}

- (void)checkMouseState {
	NSPoint globalLocation = [NSEvent mouseLocation];
	NSPoint windowLocation = [[self window] convertRectFromScreen:NSMakeRect(globalLocation.x, globalLocation.y, 0, 0)].origin;
	NSPoint viewLocation = [self convertPoint:windowLocation fromView:nil];
	BOOL inside =  NSPointInRect(viewLocation, [self bounds]);


	if (self.mouseTrackingBlock) {
		self.mouseTrackingBlock(inside);
	}
}

- (void)updateTrackingAreas {
	if (self.trackingArea != nil) {
		[self removeTrackingArea:self.trackingArea];
	}

	if (self.mouseTrackingBlock) {
		int opts = (NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways);
		self.trackingArea = [[NSTrackingArea alloc] initWithRect:[self bounds]
		                                                 options:opts
		                                                   owner:self
		                                                userInfo:nil];
		[self addTrackingArea:self.trackingArea];
        

        [self checkMouseState];
        
	}
}


- (void)setMouseDownCanMoveWindow:(BOOL)mouseDownCanMoveWindow {
    _mouseDownCanMoveWindow = true;
}
- (BOOL)mouseDownCanMoveWindow {
    return _mouseDownCanMoveWindow;
}

- (BOOL)canBecomeKeyView {
    return _canBecomeKeyView;
}

- (void)setCanBecomeKeyView:(BOOL)canBecomeKeyView {
    _canBecomeKeyView = canBecomeKeyView;
}

- (BOOL)acceptsFirstResponder {
    return _acceptsFirstResponder;
}

- (void)setAcceptsFirstResponder:(BOOL)acceptsFirstResponder {
    _acceptsFirstResponder = acceptsFirstResponder;
}

- (NSString *)description {
    if (self.name) {
        return [NSString stringWithFormat:@"<%@: %p>{ frame = %@, name = %@ }", self.class, self,
                NSStringFromRect(self.frame), self.name];
    }
	return [NSString stringWithFormat:@"<%@: %p>{ frame = %@, layer = <%@: %p> }", self.class, self,
	        NSStringFromRect(self.frame), self.layer.class, self.layer];
}


- (NSDragOperation)draggingEntered:(id <NSDraggingInfo> )sender {
    return self.dragAndDropDelegate ? [self.dragAndDropDelegate draggingEntered:sender] : NSDragOperationNone;
}

- (BOOL)prepareForDragOperation:(id <NSDraggingInfo> )sender {
    return [self.dragAndDropDelegate prepareForDragOperation:sender];
}


- (BOOL)performDragOperation:(id <NSDraggingInfo> )sender {
    return [self.dragAndDropDelegate performDragOperation:sender];
}



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Layout


// Called only if frame changes
- (void)resizeSubviewsWithOldSize:(NSSize)oldSize {
    [super resizeSubviewsWithOldSize:oldSize];
}


- (void)layoutSubviews {
    if (self.onLayout) {
        self.onLayout(self);
    }
}

- (void)priv_layoutSubviews {
    if (self.requiresLayout == NO) {
        return;
    }
    
    self.requiresLayout = NO;
    [self layoutSubviews];
}

- (void)setFrameSize:(NSSize)newSize {
    BOOL resized = !CGSizeEqualToSize(self.frame.size, newSize);
    self.requiresLayout = self.requiresLayout || resized;
    [super setFrameSize:newSize];
    
    
    [self priv_layoutSubviews];
}

- (void)setFrame:(NSRect)frame {
    BOOL resized = !CGSizeEqualToSize(self.frame.size, frame.size);
    self.requiresLayout = self.requiresLayout || resized;

    
    [super setFrame:frame];
        
    [self priv_layoutSubviews];
}


- (void)addSubview:(NSView *)aView {
    [super addSubview:aView];
    self.requiresLayout = YES;
}

- (void)removeFromSuperview {
    if ([self.superview isKindOfClass:[View class]]) {
        
        View *superview = (View *)self.superview;
        superview.needsLayout = YES;
    }
    
    [super removeFromSuperview];
    

}


@end
