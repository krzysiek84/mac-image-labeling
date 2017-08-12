//
//  NSImage+NSData.h
//  ImageLabeling
//
//  Created by Krzysztof on 21/04/2017.
//
//  Distributed under the MIT License.
//  See the LICENSE file for more information.
//


#import <Cocoa/Cocoa.h>

/**
 * Helper categories foo NSImage
 */
@interface NSImage (NSData)

// writes the png representation of image to given file 
- (void) writeToFile:(NSString*) fileName;

@end
