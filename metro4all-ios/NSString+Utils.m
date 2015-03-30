//
//  NSString+Utils.m
//  metro4all-ios
//
//  Created by Maxim Smirnov on 30.03.15.
//  Copyright (c) 2015 Maxim Smirnov. All rights reserved.
//

#import "NSString+Utils.h"

@implementation NSString (Utils)

- (BOOL)startsWithString:(NSString *)string
{
    if (self.length < string.length) {
        return NO;
    }
    
    if ([[self substringToIndex:string.length] isEqualToString:string]) {
        return YES;
    }
    
    return NO;
}

@end
