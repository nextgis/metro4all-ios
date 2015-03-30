#import "MFACity.h"

@interface MFACity ()

// Private interface goes here.

@end

@implementation MFACity
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
        name = self.name[@"ru"];
    }
    
    return name;
}

@end
