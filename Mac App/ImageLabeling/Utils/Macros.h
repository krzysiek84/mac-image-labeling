//
//  Macros.h
//  ImageLabeling
//
//  Created by Krzysztof on 21/04/2017.
//
//  Distributed under the MIT License.
//  See the LICENSE file for more information.
//


#ifndef Macros_h
#define Macros_h


// Useful Mac Macros

#import <AppKit/AppKit.h>
#import <QuartzCore/QuartzCore.h>


@compatibility_alias Color NSColor;
@compatibility_alias Image NSImage;
@compatibility_alias Font  NSFont;


static inline NSString* NSStringFromCGRect(const CGRect rect)
{
    return NSStringFromRect(NSRectFromCGRect(rect));
}

static inline NSString* NSStringFromCGSize(const CGSize size)
{
    return NSStringFromSize(NSSizeFromCGSize(size));
}

static inline NSString* NSStringFromCGPoint(const CGPoint point)
{
    return NSStringFromPoint(NSPointFromCGPoint(point));
}

static inline CGPoint CGPointFromString(NSString *string){
    return NSPointToCGPoint(NSPointFromString(string));
}

static inline NSData* UIImagePNGRepresentation(const NSImage *image)
{
    NSData *imageData = [image TIFFRepresentation];
    NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imageData];
    return [imageRep representationUsingType:NSPNGFileType properties:@{}];
    
}





#define ValueFromPoint(_POINT_)  [NSValue valueWithPoint:NSPointFromCGPoint(_POINT_)]

#define PointFromValue(_POINT_)  NSPointToCGPoint(((NSValue *)_POINT_).pointValue)



// Some helpers for constructing points etc
CG_INLINE CGRect
CGRectMakeIntegral(CGFloat x, CGFloat y, CGFloat width, CGFloat height){
    CGRect rect;
    rect.origin.x = x; rect.origin.y = y;
    rect.size.width = width; rect.size.height = height;
    return CGRectIntegral(rect);
}

CG_INLINE CGSize
CGSizeIntegral(CGSize other) {
    return CGSizeMake(ceilf(other.width), ceilf(other.height));
}

CG_INLINE CGSize
CGSizeIncrease(CGSize size, CGFloat width, CGFloat height) {
    return CGSizeMake(ceilf(size.width + width), ceilf(size.height + height));
}



CG_INLINE CGRect
CGRectInsetRect(CGRect rect, CGFloat top, CGFloat left, CGFloat bottom, CGFloat right) {
    rect.origin.x    += left;
    rect.origin.y    += top;
    rect.size.width  -= (left + right);
    rect.size.height -= (top  + bottom);
    return rect;
}



// Color
#define UIColorFromRGB(rgbValue)                                            \
    [Color colorWithRed: ((float)((rgbValue & 0xFF0000) >> 16)) / 255.0   \
                    green: ((float)((rgbValue & 0xFF00) >> 8)) / 255.0      \
                     blue: ((float)(rgbValue & 0xFF)) / 255.0               \
                    alpha: 1.0]                                             \


// Asserts
#if DEBUG
#define CAssert(expression, ...)                               \
    do { if (!(expression) ) {                                    \
            NSLog(@"%@", [NSString stringWithFormat: @"Assertion failure: %s in %s on line %s:%d. %@", #expression, __PRETTY_FUNCTION__, __FILE__, __LINE__, [NSString stringWithFormat:@"" __VA_ARGS__]]); \
    abort(); }} while(0)

#else
#define CAssert(expression, ...)          \
    do { if(!(expression)) {                        \
        NSLog(@"%@", [NSString stringWithFormat: @"Assertion failure:  %@", [NSString stringWithFormat:@"" __VA_ARGS__]]); \
    }} while(0)
#endif


#endif // EOF file
