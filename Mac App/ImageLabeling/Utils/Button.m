//
//  Button.m
//  ImageLabeling
//
//  Created by Krzysztof on 21/04/2017.
//
//  Distributed under the MIT License.
//  See the LICENSE file for more information.
//


#import "Button.h"
#import "ButtonCell.h"
#import "Appearance.h"



@interface Button()
@property (nonatomic, strong) NSColor *highlightedTextColor;
@property (nonatomic, strong) NSImage *highlightedBackgroundImage;
@end


@implementation Button

+ (Class)cellClass{
    return [ButtonCell class];
}


+ (Button *)createWithFont:(NSFont *)font andColor:(NSColor *)color {
    Button *button = [Button new];
    button.font = font;
    [button setTitleColor:color forState:DTControlStateNormal];
    return button;
}


- (void)sharedSetup {
    [self setButtonType:NSMomentaryPushInButton];
    [self setBezelStyle:NSRegularSquareBezelStyle];
    self.font = [NSFont normal];
    
    [self setTitleColor:[NSColor textColor] forState:DTControlStateNormal];
    self.title = @"";
}

- (instancetype)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self sharedSetup];
    }
    return self;
}

- (id)init {
    if(self = [super init]){
        [self sharedSetup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    [NSException raise:@"Appplication" format:@"Storyboards are evil ;)"];
    return [super initWithCoder:coder];
}


- (void)setOnClick:(void (^)(id))onClick {
    _onClick = [onClick copy];
    
    if(_onClick){
        self.target = self;
        self.action = @selector(didClick:);
    }
}

- (void)didClick:(id)sender {
    if(_onClick){
        _onClick(sender);
    }
}


- (void)setAttributedTitle:(NSAttributedString *)aString {
    ButtonCell *cell = self.cell;
    cell.textColor = nil;
    cell.highlightedTextColor = nil;
    [super setAttributedTitle:aString];
    
}

- (void)setTitleColor:(NSColor *)color forState:(DTControlState)state {
    ButtonCell *cell = self.cell;
    if(state == DTControlStateNormal){
        cell.textColor = color;
    }else if(state == DTControlStateHighlighted){
        self.highlightedTextColor = color;
        cell.highlightedTextColor = color;
    } else if(state == DTControlStateSelected) {
        cell.selectedTextColor = color;
    }else if(state == DTControlStateDisabled){
        cell.disabledTextColor = color;
    }else{
        NSAssert(NO, @"Button: not implemented state %@", @(state));
    }
    [self setNeedsDisplay:YES];
}

- (void)setImage:(NSImage *)image forState:(DTControlState)state {
    ButtonCell *cell = self.cell;
    if(state == DTControlStateNormal){
        self.image = image;
    } else if(state == DTControlStateHighlighted){
        cell.highlightedImage = image;
    }
    else {
        NSAssert(NO, @"Button: not implemented state %@, did you want to use setBackgroundImage ?", @(state));
    }
}




- (void)setBackgroundImage:(NSImage *)image forState:(DTControlState)state {
     ButtonCell *cell = self.cell;
    
    if(state == DTControlStateNormal){
        cell.backgroundImage = image;
    }else if(state == DTControlStateHighlighted){
        self.highlightedBackgroundImage = image;
        cell.highlightedBackgroundImage = image;
    } else if(state == DTControlStateSelected){
        cell.selectedBackgroundImage = image;
    }else if (state == DTControlStateDisabled) {
        cell.disabledBackgroundImage = image;
    }else {
        NSLog(@"Button: not implemented state");
    }
    
    [self setNeedsDisplay:YES];
}




- (void)setSelected:(BOOL)selected {
    [self setState:selected ? NSOnState : NSOffState];
}

- (BOOL)selected {
    return self.state == NSOnState;
}

@end
