//
//  NSArray+Utils.m
//  ImageLabeling
//
//  Created by Krzysztof on 08/07/2017.
//
//  Distributed under the MIT License.
//  See the LICENSE file for more information.
//


#import "NSArray+Utils.h"



@implementation NSArray (Utils)

- (id)sample {
    if (self.count == 0) return nil;
    
    NSUInteger index = arc4random_uniform((u_int32_t)self.count);
    return self[index];
}

@end
