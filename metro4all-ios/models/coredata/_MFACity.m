// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MFACity.m instead.

#import "_MFACity.h"

const struct MFACityAttributes MFACityAttributes = {
	.name = @"name",
	.path = @"path",
	.version = @"version",
};

const struct MFACityRelationships MFACityRelationships = {
	.lines = @"lines",
};

@implementation MFACityID
@end

@implementation _MFACity

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"City" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"City";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"City" inManagedObjectContext:moc_];
}

- (MFACityID*)objectID {
	return (MFACityID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"versionValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"version"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic name;

@dynamic path;

@dynamic version;

- (int32_t)versionValue {
	NSNumber *result = [self version];
	return [result intValue];
}

- (void)setVersionValue:(int32_t)value_ {
	[self setVersion:@(value_)];
}

- (int32_t)primitiveVersionValue {
	NSNumber *result = [self primitiveVersion];
	return [result intValue];
}

- (void)setPrimitiveVersionValue:(int32_t)value_ {
	[self setPrimitiveVersion:@(value_)];
}

@dynamic lines;

- (NSMutableSet*)linesSet {
	[self willAccessValueForKey:@"lines"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"lines"];

	[self didAccessValueForKey:@"lines"];
	return result;
}

@end

