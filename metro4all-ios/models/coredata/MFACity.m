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
        name = self.name[@"en"];
    }
    
    return name;
}

- (NSURL *)dataDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    
    NSAssert(basePath, @"Cannot get path to Documents directory");
    
    NSURL *pathURL = [NSURL fileURLWithPath:basePath];
    pathURL = [NSURL URLWithString:[NSString stringWithFormat:@"data/%@_%@/", self.path, self.version]
                     relativeToURL:pathURL];
    
    return pathURL;
}

@end
