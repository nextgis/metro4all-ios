//
//  MFACityDataParser.h
//  metro4all-ios
//
//  Created by Maxim Smirnov on 03.03.15.
//  Copyright (c) 2015 Maxim Smirnov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "NSDictionary+CityMeta.h"

@class MFACityDataParser, MFACity;

@protocol MFACityDataParserDelegate <NSObject>

@required
- (void)cityDataParser:(MFACityDataParser *)parser didFinishParsingCityWithIdentifier:(NSString *)city;
- (void)cityDataParserDidFail:(MFACityDataParser *)parser;

@optional
- (void)cityDataParser:(MFACityDataParser *)parser didProcessFiles:(NSUInteger)precessedFiles ofTotalFiles:(NSUInteger)totalFiles;

@end

@interface MFACityDataParser : NSObject

- (instancetype)initWithCityMeta:(NSDictionary *)city delegate:(id<MFACityDataParserDelegate>)delegate;

@property (nonatomic, weak) id<MFACityDataParserDelegate> delegate;
@property (nonatomic, copy, readonly) MFACityMeta *cityMetadata;

- (void)start;
- (MFACity *)parseSync;

@end
