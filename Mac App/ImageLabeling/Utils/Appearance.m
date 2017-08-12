//
//  Appearance.m
//  ImageLabeling
//
//  Created by Krzysztof on 21/04/2017.
//
//  Distributed under the MIT License.
//  See the LICENSE file for more information.
//


#import "Appearance.h"
#import "Button.h"

@implementation NSFont (Apperance)

+ (NSFont *)withSize:(CGFloat)size {
	return [NSFont systemFontOfSize:size];
}

+ (NSFont *)boldWithSize:(CGFloat)size {
	return [NSFont boldSystemFontOfSize:size];
}

+ (NSFont *)large {
	return [self withSize:kFontSizeLarge];
}

+ (NSFont *)normal {
	return [self withSize:kFontSizeNormal];
}

+ (NSFont *)boldNormal {
	return [self boldWithSize:kFontSizeNormal];
}


+ (NSFont *)small {
	return [self withSize:kFontSizeSmall];
}

@end



@implementation NSColor (Apperance)

+ (NSColor *)defultTextColor {
	return [NSColor colorWithWhite:0.12 alpha:1.0];
}

+ (NSColor *)backgroundColor {
    return [NSColor colorWithWhite:0.95 alpha:1.0];
}



@end



@implementation TextField

- (instancetype)init
{
	self = [super init];
	if (self) {
		self.font = [NSFont normal];
		self.textColor = [NSColor textColor];
	}
	return self;
}


@end

