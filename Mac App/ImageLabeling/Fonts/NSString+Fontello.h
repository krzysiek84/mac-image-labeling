

//
//  NSString+Fontello.h
//
//  Font generated from http://fontello.com/ fonts generator.
//
//  Distributed under the MIT License.
//  See the LICENSE file for more information.
//


#import <AppKit/AppKit.h>


/**
 * Icons used in this font 
 */
typedef NS_ENUM (NSInteger, FOIcon) {
	FOIconLeft_Big,
	FOIconRight_Big,
	FOIconTrash_Empty
};




/**
 *  Returns string for given icon. This string can be used in labels etc.
 */
@interface NSString (Fontello)
+ (NSString *)fontelloIconStringForEnum:(FOIcon)value;
@end


/**
 * Font helper
 */
@interface NSFont (Fontello)
+ (NSFont *)fontelloWithSize:(CGFloat)size;
@end
