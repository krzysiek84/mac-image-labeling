//
//  NSView+Layout.h
//  ImageLabeling
//
//  Created by Krzysztof on 21/04/2017.
//
//  Distributed under the MIT License.
//  See the LICENSE file for more information.
//


#import <Cocoa/Cocoa.h>

@interface NSView (Layout)

@property (nonatomic, assign) CGFloat l_left;
@property (nonatomic, assign) CGFloat l_right;
@property (nonatomic, assign) CGFloat l_top;
@property (nonatomic, assign) CGFloat l_bottom;
@property (nonatomic, assign) CGFloat l_width;
@property (nonatomic, assign) CGFloat l_height;
@property (nonatomic, assign) CGFloat l_centerX;
@property (nonatomic, assign) CGFloat l_centerY;
@property (nonatomic, assign) CGPoint l_position;
@property (nonatomic, assign) CGPoint l_center;

@property (nonatomic, assign) CGRect  l_frame;
@property (nonatomic, assign) CGSize  l_size;

@end
