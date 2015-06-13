
#import "AppDelegate.h"
#import "MFACity.h"

@interface MFACity ()

// Private interface goes here.

@end

@implementation MFACity
@dynamic name;

+ (instancetype)cityWithIdentifier:(NSString *)path
{
    return [self MR_findFirstByAttribute:@"path" withValue:path];
}

+ (instancetype)cityWithIdentifier:(NSString *)path inContext:(NSManagedObjectContext *)context
{
    return [self MR_findFirstByAttribute:@"path" withValue:path inContext:context];
}

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

- (MFAInterchange *)interchangeFromStationId:(NSNumber *)fromStationId toStationId:(NSNumber *)toStationId
{
    NSString *format = @"fromStation.stationId == %@ && " \
                       @"toStation.stationId == %@ && " \
                       @"fromStation.city == %@ && " \
                       @"toStation.city == %@ ";
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:format, fromStationId, toStationId, self, self];
    return [MFAInterchange MR_findFirstWithPredicate:pred];
}

- (MFAStation *)stationWithId:(NSNumber *)stationId
{
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"stationId == %@ && city == %@", stationId, self];
    return [MFAStation MR_findFirstWithPredicate:pred];
}

@end
