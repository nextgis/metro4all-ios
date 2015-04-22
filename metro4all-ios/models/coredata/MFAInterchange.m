
#import "MFAInterchange.h"

#define MR_SHORTHAND
#import <MagicalRecord/CoreData+MagicalRecord.h>

@interface MFAInterchange ()

// Private interface goes here.

@end

@implementation MFAInterchange

- (NSString *)description
{
    return [NSString stringWithFormat:@"Change %@ -> %@", self.fromStation, self.toStation];
}

@end
