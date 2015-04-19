
#define MR_SHORTHAND
#import <MagicalRecord/CoreData+MagicalRecord.h>

#import "_MFACity.h"

@interface MFACity : _MFACity {}

@property (nonatomic, strong) NSDictionary *name;
@property (nonatomic, strong, readonly) NSString *nameString;
@property (nonatomic, strong, readonly) NSURL *dataDirectory;

+ (instancetype)cityWithIdentifier:(NSString *)path;

@end
