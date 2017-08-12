//
//  Appearance.h
//  ImageLabeling
//
//  Created by Krzysztof on 21/04/2017.
//
//  Distributed under the MIT License.
//  See the LICENSE file for more information.
//

#import <Foundation/Foundation.h>
#import "Macros.h"
#import "Button.h"
#import "Label.h"
#import "View.h"
#import "NSView+Layout.h"
#import "NSImage+CGImage.h"
#import "NSImage+NSData.h"
#import "NSView+Layout.h"
#import "NSString+Fontello.h"

#define kFontSizeLarge  16
#define kFontSizeNormal 14
#define kFontSizeSmall  13

@interface NSFont(Apperance)

+ (NSFont *)withSize:(CGFloat)size;
+ (NSFont *)boldWithSize:(CGFloat)size;

+ (NSFont *)large;
+ (NSFont *)normal;
+ (NSFont *)boldNormal;
+ (NSFont *)small;
    
@end


@interface Color(Apperance)

+ (Color *)defultTextColor;

+ (Color *)backgroundColor;

@end


@interface TextField : NSTextField
@end

