#import "MFALine.h"

@interface MFALine ()

// Private interface goes here.

@end

@implementation MFALine

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
