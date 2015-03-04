#import "MFAStation.h"

@interface MFAStation ()

// Private interface goes here.

@end

@implementation MFAStation

- (instancetype)propertiesFromArray:(NSArray *)arrayOfStantionProperties
{
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    
    self.stationId = [f numberFromString:arrayOfStantionProperties[0]];
    self.lineId = [f numberFromString:arrayOfStantionProperties[1]];
    self.name = arrayOfStantionProperties[3];
    self.lat = [f numberFromString:arrayOfStantionProperties[4]];
    self.lon = [f numberFromString:arrayOfStantionProperties[5]];
    
    return self;
}

@end
