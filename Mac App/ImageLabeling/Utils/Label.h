//
//  Label.h
//  ImageLabeling
//
//  Created by Krzysztof on 21/04/2017.
//
//  Distributed under the MIT License.
//  See the LICENSE file for more information.
//


#import <Cocoa/Cocoa.h>


// Nicer name for stringValue..
@interface NSTextField (Utils)
@property (nonatomic, strong) NSString *text;
@end



/**
 * Label
 */
@interface Label : NSTextField

// Use block for simple actions
@property (nonatomic, copy) void (^onClick)(id sender);


@end
