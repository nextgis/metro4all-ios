#import "_MFAStation.h"

@interface MFAStation : _MFAStation {}

@property (nonatomic, strong) NSDictionary *name;
@property (nonatomic, strong, readonly) NSString *nameString;

- (instancetype)propertiesFromArray:(NSArray *)arrayOfStantionProperties;
+ (instancetype)withId:(NSNumber *)stationId;

@end
