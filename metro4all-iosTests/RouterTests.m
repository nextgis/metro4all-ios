//
//  RouterTests.m
//  metro4all-ios
//
//  Created by Maxim Smirnov on 15/04/15.
//  Copyright (c) 2015 Maxim Smirnov. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MFARouter.h"

@interface RouterTests : XCTestCase
@property (nonatomic, strong) NSArray *stations;
@property (nonatomic, strong) NSArray *edges;

@end

@implementation RouterTests

- (void)setUp {
    [super setUp];
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSURL *fileURL = [bundle URLForResource:@"stations" withExtension:@"json"];
    NSData *data = [NSData dataWithContentsOfURL:fileURL];
    
    self.stations = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    fileURL = [bundle URLForResource:@"edges" withExtension:@"json"];
    data = [NSData dataWithContentsOfURL:fileURL];
    
    self.edges = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    MFARouter *router = [[MFARouter alloc] initWithStations:self.stations edges:self.edges];
    [router routeFromStation:@1 toStation:@12];
}

@end
