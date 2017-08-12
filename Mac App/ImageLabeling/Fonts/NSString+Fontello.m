

//
//  NSString+Fontello.m
//

#import "NSString+Fontello.h"

@implementation NSString (Fontello)

+ (NSArray *)fontelloIcons {
	static NSArray *fontelloIcons = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        fontelloIcons = @[
        	@"", @"", @""             
        ];


#if defined(__has_feature) && !__has_feature(objc_arc)
		[fontelloIcons retain];
#endif
    });
	return fontelloIcons;
}

+ (NSString *)fontelloIconStringForEnum:(FOIcon)value {
    return [self fontelloIcons][value];
}

@end


@implementation NSFont(Fontello)

+ (NSFont *)fontelloWithSize:(CGFloat)size {
    return [NSFont fontWithName:@"fontello" size:size];
}

@end

