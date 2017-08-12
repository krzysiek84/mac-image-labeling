//
//  FrameEditorView.m
//  ImageLabeling
//
//  Created by Krzysztof on 09/08/2017.
//
//  Distributed under the MIT License.
//  See the LICENSE file for more information.
//


#import "FrameEditorView.h"
#import "Appearance.h"

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private Interface

@interface FrameEditorView() <NSGestureRecognizerDelegate>

@property (nonatomic, weak) NSObject<FrameEditorViewDelegage> *delegate;


@property (nonatomic, assign) BOOL areasConfirmed;
@property (nonatomic, strong) NSImage *image;
@property (nonatomic, assign) CGFloat scale;

@property (nonatomic, assign) CGRect initialArea;
@property (nonatomic, assign) BOOL resizing;

@end



@implementation FrameEditorView


- (instancetype)initWithDelegate:(NSObject<FrameEditorViewDelegage> *)delegate {
    self = [super init];
    if (self) {
        
        self.delegate = delegate;
        self.selectedArea = CGRectNull;
        self.wantsLayer = YES;
        self.displayPreview = YES;
        
        // Dragging frames
        NSPanGestureRecognizer *recognizer = [[NSPanGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(dragAction:)];
        [self addGestureRecognizer:recognizer];
        
        
        // Adding / removing
        NSClickGestureRecognizer *clickRecognizer = [[NSClickGestureRecognizer alloc] initWithTarget:self
                                                                                              action:@selector(doubleClickAction:)];
        clickRecognizer.delegate = self;
        clickRecognizer.numberOfClicksRequired = 2;
        
        [self addGestureRecognizer:clickRecognizer];
    }
    return self;
}

- (BOOL)isFlipped {
    return YES;
}

// Util return frame at given position (checks intersection)
- (NSDictionary *)frameAtPosition:(CGPoint)position {
    
    for (NSDictionary *jsonFrame in self.selectedAreas) {
        CGRect frame = frameFromJSON(jsonFrame);
        
        if (CGRectContainsPoint(CGRectInset(frame, -4 / self.scale, -10 / self.scale), position)) {
            return jsonFrame;
        }
    }
    return nil;
}


- (BOOL)gestureRecognizerShouldBegin:(NSGestureRecognizer *)gestureRecognizer {
    CGPoint position = [gestureRecognizer locationInView:self];
    if ([self hitTest:position] != self) {
        return NO;
    }
    return YES;
}

// Adds removes selection frame
- (void)doubleClickAction:(NSClickGestureRecognizer *)recognizer {
    CGPoint position = [recognizer locationInView:self];
    position.x /= self.scale;
    position.y /= self.scale;
    
    
    NSDictionary *jsonFrame = [self frameAtPosition:position];
    if (jsonFrame) {
        // Remove existing one but only if there is at least one left
        if (self.selectedAreas.count > 1) {
            [self.selectedAreas removeObject:jsonFrame];
        }
        self.selectedArea = frameFromJSON([self.selectedAreas firstObject]);
        
        // Update text field
        [self.delegate frameChanged];
    } else {
        
        // Add new one
        CGRect frame = CGRectMake(position.x, position.y, 100, 100);
        [self.selectedAreas addObject:jsonFromFrame(frame)];
    }
    
    [self setNeedsDisplay:YES];
}


- (void)dragAction:(NSPanGestureRecognizer *)recognizer {
    
    if (recognizer.state == NSGestureRecognizerStateBegan) {
        
        CGPoint position = [recognizer locationInView:self];
        position.x /= self.scale;
        position.y /= self.scale;
        
        NSDictionary *jsonFrame = [self frameAtPosition:position];
        
        if (jsonFrame) {
            CGRect frame = frameFromJSON(jsonFrame);
            
            self.initialArea = frame;
            self.selectedArea = frame;
            
            CGPoint bottomRight = CGPointMake(CGRectGetMaxX(frame), CGRectGetMaxY(frame));
            CGFloat radius = 5.0 / self.scale;
            CGRect handleFrame = CGRectMake(bottomRight.x - radius, bottomRight.y - radius, 2*radius, 2*radius);
            
            if (CGRectContainsPoint(handleFrame, position)) {
                self.resizing = YES;
            }
            
            // Make sure the frame is the last object - it will be removed and readded as it's immutable
            [self.selectedAreas removeObject:jsonFrame];
            [self.selectedAreas addObject:jsonFrame];
            
            
            
            
            // Notify that the possibly selected frame changed
            [self.delegate frameChanged];
        }
        
        
        
        
        
    } else if (recognizer.state == NSGestureRecognizerStateChanged){
        if (CGRectIsEmpty(self.initialArea)) { return; }
        
        CGPoint translate = [recognizer translationInView:self];
        
        CGFloat dx = translate.x / self.scale;
        CGFloat dy = translate.y / self.scale;
        
        if (self.resizing) {
            CGRect f0 = CGRectMake(self.initialArea.origin.x, self.initialArea.origin.y, 0, 0);
            CGPoint bottomRight = CGPointMake(CGRectGetMaxX(self.initialArea), CGRectGetMaxY(self.initialArea));
            
            CGRect frame = CGRectUnion(f0, CGRectMake(bottomRight.x + dx, bottomRight.y + dy, 0, 0));
            frame.size.width = ceilf(frame.size.width);
            frame.size.height = ceilf(frame.size.height);
            
            self.selectedArea = frame;
            
            
            
        } else {
            
            
            CGRect frame = CGRectOffset(self.initialArea, dx, dy);
            frame.origin.x = ceilf(frame.origin.x);
            frame.origin.y = ceilf(frame.origin.y);
            
            
            frame.origin.x = fmaxf(frame.origin.x, 0);
            frame.origin.y = fmaxf(frame.origin.y, 0);
            frame.origin.x = fminf(self.image.size.width - frame.size.width, frame.origin.x);
            frame.origin.y = fminf(self.image.size.height - frame.size.height, frame.origin.y);
            
            frame = CGRectIntegral(frame);
            self.selectedArea = frame;
        }
        
        [self.selectedAreas removeLastObject];
        [self.selectedAreas addObject:jsonFromFrame(self.selectedArea)];
        
        [self.delegate frameChanged];
        
        [self setNeedsDisplay:YES];
        
    } else if (recognizer.state == NSGestureRecognizerStateEnded || recognizer.state == NSGestureRecognizerStateFailed) {
        self.initialArea = CGRectZero;
        self.resizing = NO;
    }
}



- (void)setFrame:(NSRect)frame {
    [super setFrame:frame];
    
    
    CGSize size = self.image.size;
    self.scale = fmin(frame.size.width/size.width, frame.size.height/size.height);
    
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)rect {
    [super drawRect:rect];
    
    CGContextRef context = NSGraphicsContext.currentContext.graphicsPort;
    
    // Fill
    CGContextSetFillColorWithColor(context, [[NSColor whiteColor] CGColor]);
    CGContextFillRect(context, self.bounds);

    
    NSImage *image = self.image;
    
    if (!image) { return; }
    
    CGImageRef imageRef = [image CGImage];
    
    
    CGContextSaveGState(context); {
        
        
        
        CGContextScaleCTM(context, self.scale, self.scale);
        
        ///
        // Draw image
        CGContextSaveGState(context);{
            
            CGSize size = self.image.size;
            CGRect imageFrame = CGRectMake(0, 0, size.width, size.height);
            CGContextTranslateCTM(context, 0, size.height);
            CGContextScaleCTM(context, 1.0, -1.0);
            CGContextDrawImage(context, imageFrame, imageRef);
            
            
        } CGContextRestoreGState(context);
        
        ///
        // Draw the frames
        NSColor *framesColor = self.areasConfirmed ? [NSColor greenColor] : [NSColor colorWithRed:1.0 green:0.0 blue:1.0 alpha:1];
        CGContextSetStrokeColorWithColor(context, framesColor.CGColor);
        CGContextSetFillColorWithColor(context, framesColor.CGColor);
        
        
        for (NSDictionary *jsonFrame in self.selectedAreas) {
            CGRect frame = frameFromJSON(jsonFrame);
            
            CGContextAddRect(context, frame);
            CGContextSetLineWidth(context, 2.0 / self.scale);
            CGContextStrokePath(context);
            
            
            // Draw resize handle in bottom right
            CGPoint bottomRight = CGPointMake(CGRectGetMaxX(frame), CGRectGetMaxY(frame));
            CGFloat radius = 5.0 / self.scale;
            CGRect handleFrame = CGRectMake(bottomRight.x - radius, bottomRight.y - radius, 2*radius, 2*radius);
            
            CGContextAddEllipseInRect(context, handleFrame);
            CGContextFillPath(context);
        }
        
        
    } CGContextRestoreGState(context);
    
    
    
    // Draw selected preview
    if (self.displayPreview) {
        
        if (!CGRectIsNull(self.selectedArea)) {
            CGRect frame = self.selectedArea;
            
            CGSize maxPreviewSize = CGSizeMake(self.l_width/4.0, self.l_height/4.0);
            CGFloat s = fmin(maxPreviewSize.width / frame.size.width, maxPreviewSize.height / frame.size.height);
            if (s > 1.5) {
                CGRect previewFrame = CGRectMake(0, 0, frame.size.width * s, frame.size.height * s);

                
                CGContextSaveGState(context);{
                    CGContextTranslateCTM(context, self.l_width - previewFrame.size.width -2,
                                                   self.l_height - previewFrame.size.height -2);
                    
                    CGContextSetFillColorWithColor(context, [[[Color orangeColor] colorWithAlphaComponent:1.0] CGColor]);
                    CGContextFillRect(context, CGRectInset(previewFrame, -2, -2));
                    
                    
                    // Get preview part from the image
                    CGImageRef preview = CGImageCreateWithImageInRect(imageRef, frame);
                    
                    
                    CGContextTranslateCTM(context, 0, CGRectGetMaxY(previewFrame));
                    CGContextScaleCTM(context, 1.0, -1.0);
                    
                    CGContextDrawImage(context, previewFrame, preview);
                    
                    
                    
                } CGContextRestoreGState(context);
            }
        }
        
    }
    
}


// Public api - update whats drawn
- (void)updateWithImage:(NSImage *)imageIn
                 frames:(NSArray *)frames
        framesConfirmed:(BOOL)confirmed {
    
    NSAssert(frames.count > 0, @"must be at least one frame for the image");

    
    // Use pixels not dpi image size
    NSImage *image = [imageIn copy];
    NSImageRep *rep = [[image representations] objectAtIndex:0];
    [image setSize: NSMakeSize([rep pixelsWide], [rep pixelsHigh])];
    
    self.image = image;
    self.selectedAreas = [frames mutableCopy];
    self.areasConfirmed = confirmed;
    
    self.selectedArea = frameFromJSON([frames firstObject]);
    
    
    CGSize size = [self.image size];
    self.scale = fmin(self.frame.size.width/size.width, self.frame.size.height/size.height);
    
    
    [self setNeedsDisplay:YES];
}


@end
