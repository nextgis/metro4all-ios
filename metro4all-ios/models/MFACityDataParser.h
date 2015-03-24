//
//  MFACityDataParser.h
//  metro4all-ios
//
//  Created by Maxim Smirnov on 03.03.15.
//  Copyright (c) 2015 Maxim Smirnov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MFACityDataParser, MFACity;

@protocol MFACityDataParserDelegate <NSObject>

@required
- (void)cityDataParser:(MFACityDataParser *)parser didFinishParsingCity:(MFACity *)city;
- (void)cityDataParserDidFail:(MFACityDataParser *)parser;

@optional
- (void)cityDataParser:(MFACityDataParser *)parser didProcessFiles:(NSUInteger)precessedFiles ofTotalFiles:(NSUInteger)totalFiles;

@end

@interface MFACityDataParser : NSObject

- (instancetype)initWithCityMeta:(NSDictionary *)city pathToCSV:(NSString *)path
            managedObjectContext:(NSManagedObjectContext *)moc delegate:(id<MFACityDataParserDelegate>)delegate;

@property (nonatomic, weak) id<MFACityDataParserDelegate> delegate;
@property (nonatomic, copy, readonly) NSDictionary *cityMetadata;

- (void)start;

@end
