//
//  NSStringUtilsTests.m
//  metro4all-ios
//
//  Created by Maxim Smirnov on 30.03.15.
//  Copyright (c) 2015 Maxim Smirnov. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSString+Utils.h"

@interface NSStringUtilsTests : XCTestCase

@end

@implementation NSStringUtilsTests

- (void)testPositive {
    XCTAssert([@"Hello World" startsWithString:@"Hello"], @"Pass");
}

- (void)testNegative {
    XCTAssertFalse([@"Hello World" startsWithString:@"World"], @"Pass");
}

- (void)testLength {
    XCTAssertFalse([@"Hello" startsWithString:@"Hello World"], @"Pass");
}

@end
