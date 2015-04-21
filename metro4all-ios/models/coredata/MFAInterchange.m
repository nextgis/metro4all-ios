
#import "MFAInterchange.h"

#define MR_SHORTHAND
#import <MagicalRecord/CoreData+MagicalRecord.h>

@interface MFAInterchange ()

// Private interface goes here.

@end

@implementation MFAInterchange

+ (instancetype)fromStationId:(NSNumber *)fromStationId
                  toStationId:(NSNumber *)toStationId
{
    return [self MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fromStation.stationId == %@ && toStation.stationId == %@", fromStationId, toStationId]];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"Change %@ -> %@", self.fromStation, self.toStation];
}
@end
