#import "_MFALine.h"

@interface MFALine : _MFALine {}

@property (nonatomic, strong) NSDictionary *name;

- (instancetype)propertiesFromArray:(NSArray *)arrayOfLineProperties;

@end
