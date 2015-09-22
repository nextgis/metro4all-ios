#import "MFALine.h"

@interface MFALine ()

// Private interface goes here.

@end

@implementation MFALine
@dynamic name;

- (NSString *)nameString
{
    NSString *name = nil;
    
    for (NSString *lang in [NSLocale preferredLanguages]) {
        NSString *aLang = [lang substringToIndex:2];
        if (self.name[aLang]) {
            name = self.name[aLang];
            break;
        }
    }
    
    if (name == nil) {
        name = self.name[@"en"];
    }
    
    return name;
}

- (instancetype)propertiesFromArray:(NSArray *)arrayOfLineProperties
{
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;

    self.lineId = [f numberFromString:arrayOfLineProperties[0]];
    self.name = arrayOfLineProperties[1];
    self.color = arrayOfLineProperties[2];
    
    return self;
}

@end
