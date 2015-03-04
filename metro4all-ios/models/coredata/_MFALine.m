// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MFALine.m instead.

#import "_MFALine.h"

const struct MFALineAttributes MFALineAttributes = {
	.color = @"color",
	.lineId = @"lineId",
	.name = @"name",
};

const struct MFALineRelationships MFALineRelationships = {
	.city = @"city",
	.stations = @"stations",
};

@implementation MFALineID
@end

@implementation _MFALine

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Line" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Line";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Line" inManagedObjectContext:moc_];
}

- (MFALineID*)objectID {
	return (MFALineID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"lineIdValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"lineId"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic color;

@dynamic lineId;

- (int32_t)lineIdValue {
	NSNumber *result = [self lineId];
	return [result intValue];
}

- (void)setLineIdValue:(int32_t)value_ {
	[self setLineId:@(value_)];
}

- (int32_t)primitiveLineIdValue {
	NSNumber *result = [self primitiveLineId];
	return [result intValue];
}

- (void)setPrimitiveLineIdValue:(int32_t)value_ {
	[self setPrimitiveLineId:@(value_)];
}

@dynamic name;

@dynamic city;

@dynamic stations;

- (NSMutableSet*)stationsSet {
	[self willAccessValueForKey:@"stations"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"stations"];

	[self didAccessValueForKey:@"stations"];
	return result;
}

@end

