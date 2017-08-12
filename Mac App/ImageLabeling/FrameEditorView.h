//
//  FrameEditorView.h
//  ImageLabeling
//
//  Created by Krzysztof on 09/08/2017.
//
//  Distributed under the MIT License.
//  See the LICENSE file for more information.
//


#import <Cocoa/Cocoa.h>


// JSON - CGRect conversiomn
static inline NSDictionary* jsonFromFrame(const CGRect frame) {
    return @{
             @"x" : @(frame.origin.x),
             @"y" : @(frame.origin.y),
             @"width" : @(frame.size.width),
             @"height" : @(frame.size.height)
             };
}


static inline CGRect frameFromJSON(const NSDictionary *json) {
    return CGRectMake([json[@"x"] floatValue], [json[@"y"] floatValue],
                      [json[@"width"] floatValue], [json[@"height"] floatValue]);
}




/**
 * Delegate for view - notified about frame changes (size and position)
 */
@protocol FrameEditorViewDelegage <NSObject>
- (void)frameChanged;
@end





/**
 * Allows editing frames on displayed image
 */
@interface FrameEditorView : NSView

@property (nonatomic, strong) NSMutableArray *selectedAreas;
@property (nonatomic, assign) CGRect selectedArea;
@property (nonatomic, assign) BOOL displayPreview;


- (instancetype)initWithDelegate:(NSObject<FrameEditorViewDelegage> *)delegate;

- (void)updateWithImage:(NSImage *)image
                 frames:(NSArray *)frames
        framesConfirmed:(BOOL)confirmed;

@end
