//
//  NSView+Layout.m
//  ImageLabeling
//
//  Created by Krzysztof on 21/04/2017.
//
//  Distributed under the MIT License.
//  See the LICENSE file for more information.
//


#import "NSView+Layout.h"


// CGRectIntegral modifies the width, height when x is not integral, this makes animations in pop look ugly
static
CGRect MakeIntegral(CGRect frame) {
    CGRect result = CGRectZero;
    result.origin.x = floorf(frame.origin.x);
    result.origin.y = floorf(frame.origin.y);
    result.size.width = ceilf(frame.size.width);
    result.size.height = ceilf(frame.size.height);
    return result;
}

@implementation NSView (Layout)

- (CGFloat)l_left {
    return self.frame.origin.x;
}

- (void)setL_left:(CGFloat)left {
    CGRect frame = self.frame;
    frame.origin.x = left;
    self.frame = MakeIntegral(frame);
}

- (CGFloat)l_right {
    return CGRectGetMaxX(self.frame);
}

- (void)setL_right:(CGFloat)right {
    CGRect frame = self.frame;
    frame.origin.x = right - frame.size.width;
    self.frame = MakeIntegral(frame);
}

- (CGFloat)l_top {
    return self.frame.origin.y;
}

- (void)setL_top:(CGFloat)top {
    CGRect frame = self.frame;
    frame.origin.y = top;
    self.frame = MakeIntegral(frame);
}

- (CGFloat)l_bottom {
    return CGRectGetMaxY(self.frame);
}

- (void)setL_bottom:(CGFloat)bottom {
    CGRect frame = self.frame;
    frame.origin.y = bottom - frame.size.height;
    self.frame = MakeIntegral(frame);
}

- (CGFloat)l_width {
    return self.bounds.size.width;
}

- (void)setL_width:(CGFloat)width {
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = MakeIntegral(frame);
}

- (CGFloat)l_height {
    return self.bounds.size.height;
}

- (void)setL_height:(CGFloat)height {
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = MakeIntegral(frame);
}

- (CGPoint)l_position {
    return self.frame.origin;
}

- (void)setL_position:(CGPoint)position {
    CGRect frame = self.frame;
    frame.origin = position;
    
    self.frame = MakeIntegral(frame);
}

- (CGSize)l_size {
    return self.frame.size;
}

- (void)setL_size:(CGSize)size {
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = MakeIntegral(frame);
}


- (CGFloat)l_centerX {
    return floorf(self.l_center.x);
}

- (CGFloat)l_centerY {
    return floorf(self.l_center.y);
}


- (void)setL_centerX:(CGFloat)centerX {
    CGRect frame = self.frame;
    frame.origin.x = floorf(centerX - frame.size.width/2.0);
    self.frame = MakeIntegral(frame);
}

- (void)setL_centerY:(CGFloat)centerY {
    CGRect frame = self.frame;
    frame.origin.y = floorf(centerY - frame.size.height/2.0);
    
    self.frame = MakeIntegral(frame);
}

- (CGRect)l_frame {
    return self.frame;
}

- (void)setL_frame:(CGRect)l_frame {
    self.frame = MakeIntegral(l_frame);
}

- (CGPoint)l_center {
    CGRect frame = self.frame;
    return CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame));
}

- (void)setL_center:(CGPoint)center {
    CGRect frame = self.frame;
    frame.origin.x = center.x - frame.size.width/2.0;
    frame.origin.y = center.y - frame.size.height/2.0;
    self.frame = MakeIntegral(frame);
}


@end
