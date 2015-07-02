
#import "MFAStation.h"

#import <MagicalRecord/MagicalRecord.h>

@interface MFAStation ()

// Private interface goes here.

@end

@implementation MFAStation
@dynamic name;

- (NSString *)nameString
{
    NSString *name = nil;
    
    for (NSString *lang in [NSLocale preferredLanguages]) {
        if (self.name[lang]) {
            name = self.name[lang];
            break;
        }
    }
    
    if (name == nil) {
        name = self.name[@"en"];
    }
    
    return name;
}

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

- (NSString *)description
{
    return self.name[@"en"];
}

@end
