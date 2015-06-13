
#define MR_SHORTHAND
#import <MagicalRecord/CoreData+MagicalRecord.h>

#import "_MFACity.h"

#import "MFAInterchange.h"
#import "MFAStation.h"

@interface MFACity : _MFACity {}

@property (nonatomic, strong) NSDictionary *name;
@property (nonatomic, strong, readonly) NSString *nameString;
@property (nonatomic, strong, readonly) NSURL *dataDirectory;

+ (instancetype)cityWithIdentifier:(NSString *)path;
+ (instancetype)cityWithIdentifier:(NSString *)path inContext:(NSManagedObjectContext *)context;

- (MFAStation *)stationWithId:(NSNumber *)stationId;
- (MFAInterchange *)interchangeFromStationId:(NSNumber *)fromStationId
                                 toStationId:(NSNumber *)toStationId;

@end
