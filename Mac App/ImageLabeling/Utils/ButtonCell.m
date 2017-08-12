//
//  ButtonCell.m
//  ImageLabeling
//
//  Created by Krzysztof on 21/04/2017.
//
//  Distributed under the MIT License.
//  See the LICENSE file for more information.
//


#import "ButtonCell.h"


@interface NSColor(ButtonHelpers)
@end

@implementation NSColor(ButtonHelpers)

- (CGColorSpaceModel)colorSpaceModel {
    return CGColorSpaceGetModel(CGColorGetColorSpace(self.CGColor));
}

- (BOOL)canProvideRGBComponents {
    switch (self.colorSpaceModel) {
        case kCGColorSpaceModelRGB:
        case kCGColorSpaceModelMonochrome:
            return YES;
            
        default:
            return NO;
    }
}
- (NSColor *)colorByBlending:(NSColor *)other withAlpha:(float)alpha {
    CGFloat r1, g1, b1, a1;
    
    if (![self canProvideRGBComponents] || ![other canProvideRGBComponents]) {
        return self;
    }
    
    [self getRed:&r1 green:&g1 blue:&b1 alpha:&a1];
    
    CGFloat r2, g2, b2, a2;
    [other getRed:&r2 green:&g2 blue:&b2 alpha:&a2];
    
    CGFloat red   = r1 + (r2 - r1) * alpha;
    CGFloat green = g1 + (g2 - g1) * alpha;
    CGFloat blue  = b1 + (b2 - b1) * alpha;
    
    return  [NSColor colorWithRed:red green:green blue:blue alpha:1.0];
    
    
}



- (NSColor *)colourByAdjustingBrightness:(CGFloat)aBrightness {
    if (aBrightness == 0) return self;
    
    if (![self canProvideRGBComponents]) {
        return self;
    }
    
    // If color is black make sure it's being whiter not darker
    NSColor *color = [self colorUsingColorSpace:[NSColorSpace genericRGBColorSpace]];
    if (color.brightnessComponent + aBrightness < 0) {
        aBrightness = - aBrightness;
    } else if (color.brightnessComponent + aBrightness > 1.0){
        aBrightness = - aBrightness;
    }
    
    return [NSColor colorWithDeviceHue:color.hueComponent
                            saturation:color.saturationComponent
                            brightness:(color.brightnessComponent + aBrightness)
                                 alpha:color.alphaComponent];
}
@end






@implementation ButtonCell



- (void)drawBezelWithFrame:(NSRect)frame inView:(NSView *)controlView {
	NSGraphicsContext *ctx = [NSGraphicsContext currentContext];
	[ctx saveGraphicsState]; {
		NSImage *image = (self.highlightedBackgroundImage != nil && self.isHighlighted)
		    ? self.highlightedBackgroundImage
			: self.backgroundImage;

		if (self.state == NSOnState && self.selectedBackgroundImage != nil) {
			image =  self.selectedBackgroundImage;
		}

		if (self.isEnabled == NO && self.disabledBackgroundImage != nil) {
			image = self.disabledBackgroundImage;
		}
		// Draw button border on the frame that is 1px smaller
		// to get rid of flickering while resizing superview
		//CGRect insetFrame = CGRectInset(frame, 1, 1);
        if (image) {
            [image drawInRect:frame];
        }
	}


	// Do drawing here
	[ctx restoreGraphicsState];
}

- (NSRect)drawCenteredTitle:(NSAttributedString *)title withFrame:(NSRect)frame inView:(NSView *)controlView {
    NSRect rect = frame;
	return [super drawTitle:title withFrame:rect inView:controlView];
}

- (NSRect)drawTitle:(NSAttributedString *)title withFrame:(NSRect)frame inView:(NSView *)controlView {
	NSGraphicsContext *ctx = [NSGraphicsContext currentContext];

	NSRect r;

	if (self.textColor || self.isHighlighted || (self.state == NSOnState && self.selectedTextColor)
	    || (self.isEnabled == NO && self.disabledTextColor)) {
		[ctx saveGraphicsState]; {

			// Custom title settings
			NSMutableAttributedString *attrString = [title mutableCopy];
			[attrString beginEditing];



			NSRange range = NSMakeRange(0, title.length);
            
			[title enumerateAttributesInRange:range
			                          options:0
			                       usingBlock: ^(NSDictionary *attributes, NSRange range, BOOL *stop) {
                                       
			    NSColor *color = [attributes valueForKey:NSForegroundColorAttributeName];

			    if (self.isEnabled == NO) {
			        color = self.disabledTextColor ? self.disabledTextColor : self.textColor;
				}
			    else if (self.state == NSOnState && self.selectedTextColor != nil) {
			        color = self.selectedTextColor;
				}
			    else if (self.isHighlighted) {
			        if (self.highlightedTextColor) {
			            color = self.highlightedTextColor;
					}
			        else if (self.textColor) {
			            color = [self.textColor colourByAdjustingBrightness:-0.3];
					}
			        else {
			            color = [color colourByAdjustingBrightness:-0.3];
					}
				}
			    else if (self.textColor) {
			        color = self.textColor;
				}

			    if (color) {
			        [attrString addAttribute:NSForegroundColorAttributeName
			                                value:color
			                                range:range];
				}
			}

			];

			[attrString endEditing];

			r = [self drawCenteredTitle:attrString withFrame:frame inView:controlView];
		}
		[ctx restoreGraphicsState];
	}
	else {
		r = [self drawCenteredTitle:title withFrame:frame inView:controlView];
	}

	return r;
}


- (void)drawImage:(NSImage *)image withFrame:(NSRect)frame inView:(NSView *)controlView {
    CGSize size = image.size;
    CGRect drawFrame = frame;
    
    
    if (self.imagePosition == NSImageRight) {
        drawFrame = CGRectMake(frame.origin.x + frame.size.width - size.width - self.iconInset, frame.origin.y + (frame.size.height - size.height) / 2.0, size.width, size.height);
    }
    else if (self.imagePosition == NSImageOverlaps) {
        drawFrame = CGRectMake(frame.origin.x + (frame.size.width - size.width) / 2.0, frame.origin.y + (frame.size.height - size.height) / 2.0, size.width, size.height);
    }
    if (self.isHighlighted && self.highlightedImage) {
        image = self.highlightedImage;
    }
    
    [super drawImage:image withFrame:drawFrame inView:controlView];
    
}

// When bordered is set to true, text has some strange insets on left right etc
// Could not get the button working with bordered set to false
// So instead override that method - seams to work ok
- (NSRect)drawingRectForBounds:(NSRect)theRect {
	return theRect;
}

- (void)commonInit; {
	self.textColor = [NSColor blackColor];
	[self setHighlightsBy:NSNoCellMask];
	[self setShowsStateBy:NSNoCellMask];
}


- (id)initImageCell:(NSImage *)image {
	if (!(self = [super initImageCell:image]))
		return nil;

	[self commonInit];

	return self;
}

- (id)initTextCell:(NSString *)string {
	if (!(self = [super initTextCell:string]))
		return nil;

	[self commonInit];

	return self;
}

@end
