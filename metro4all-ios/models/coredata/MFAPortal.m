#import "MFAPortal.h"

@interface MFAPortal ()

// Private interface goes here.

@end

@implementation MFAPortal
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

- (instancetype)propertiesFromArray:(NSArray *)portalProperties
{
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    
    self.potralId = [f numberFromString:portalProperties[0]];
    self.portalNumber = [f numberFromString:portalProperties[1]];
    self.name = portalProperties[2];
    self.stationId = [f numberFromString:portalProperties[3]];
//    self.directionValue =
    self.lat = [f numberFromString:portalProperties[5]];
    self.lon = [f numberFromString:portalProperties[6]];
    
    return self;
}

@end
