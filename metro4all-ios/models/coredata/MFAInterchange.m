
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
    return [self findFirstWithPredicate:[NSPredicate predicateWithFormat:@"fromStationId == %@ && toStationId == %@", fromStationId, toStationId]];
}

@end
