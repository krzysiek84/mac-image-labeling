//
//  NSImage+NSData.m
//  ImageLabeling
//
//  Created by Krzysztof on 21/04/2017.
//
//  Distributed under the MIT License.
//  See the LICENSE file for more information.
//

#import "NSImage+NSData.h"


@implementation NSImage (NSData)

//http://stackoverflow.com/questions/3038820/how-to-save-a-nsimage-as-a-new-file
- (void) writeToFile:(NSString*) fileName
{
    // Cache the reduced image
    NSData *imageData = [self TIFFRepresentation];
    NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imageData];
    NSDictionary *imageProps = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:1.0] forKey:NSImageCompressionFactor];
    imageData = [imageRep representationUsingType:NSPNGFileType properties:imageProps];
    if ([imageData writeToFile:[fileName stringByExpandingTildeInPath] atomically:NO] == NO){
        NSLog(@"Could not write to file %@", fileName);
    }
}



@end

