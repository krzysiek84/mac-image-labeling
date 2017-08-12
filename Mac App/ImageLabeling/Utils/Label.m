//
//  Label.m
//  ImageLabeling
//
//  Created by Krzysztof on 21/04/2017.
//
//  Distributed under the MIT License.
//  See the LICENSE file for more information.
//

#import "Label.h"
#import "Appearance.h"

@implementation NSTextField (Utils)

- (NSString *)text {
    return self.stringValue;
}

- (void)setText:(NSString *)text {
    self.stringValue = text ? text : @"";
}


@end



@implementation Label

- (void)initialize {
    self.textColor = [NSColor textColor];
    self.font = [NSFont normal];
    [self setBezeled:NO];
    [self setDrawsBackground:NO];
    [self setEditable:NO];
    [self setSelectable:NO];

}

+ (Label *)createWithFont:(NSFont *)font andColor:(NSColor *)color {
    Label *label = [Label new];
    label.font = font;
    label.textColor = color;
    return label;
}

- (id)init {
    self = [super init];
    [self initialize];
    return self;
}



- (id)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        [self initialize];
    }
    return self;
}



-(void)mouseDown:(NSEvent *)theEvent {
    [super mouseDown:theEvent];
    
    if(_onClick){
       _onClick(self);
    }
}


@end
