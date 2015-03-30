#import "_MFAPortal.h"

@interface MFAPortal : _MFAPortal {}

@property (nonatomic, strong) NSDictionary *name;
@property (nonatomic, strong, readonly) NSString *nameString;

- (instancetype)propertiesFromArray:(NSArray *)portalProperties;

@end
