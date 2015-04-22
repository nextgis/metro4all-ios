// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MFAStation.m instead.

#import "_MFAStation.h"

const struct MFAStationAttributes MFAStationAttributes = {
	.lat = @"lat",
	.lineId = @"lineId",
	.lon = @"lon",
	.name = @"name",
	.schemeFilePath = @"schemeFilePath",
	.stationId = @"stationId",
};

const struct MFAStationRelationships MFAStationRelationships = {
	.city = @"city",
	.interchangesFrom = @"interchangesFrom",
	.interchangesTo = @"interchangesTo",
	.line = @"line",
	.node = @"node",
	.portals = @"portals",
};

@implementation MFAStationID
@end

@implementation _MFAStation

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Station" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Station";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Station" inManagedObjectContext:moc_];
}

- (MFAStationID*)objectID {
	return (MFAStationID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"latValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"lat"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"lineIdValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"lineId"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"lonValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"lon"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"stationIdValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"stationId"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic lat;

- (float)latValue {
	NSNumber *result = [self lat];
	return [result floatValue];
}

- (void)setLatValue:(float)value_ {
	[self setLat:@(value_)];
}

- (float)primitiveLatValue {
	NSNumber *result = [self primitiveLat];
	return [result floatValue];
}

- (void)setPrimitiveLatValue:(float)value_ {
	[self setPrimitiveLat:@(value_)];
}

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

@dynamic lon;

- (float)lonValue {
	NSNumber *result = [self lon];
	return [result floatValue];
}

- (void)setLonValue:(float)value_ {
	[self setLon:@(value_)];
}

- (float)primitiveLonValue {
	NSNumber *result = [self primitiveLon];
	return [result floatValue];
}

- (void)setPrimitiveLonValue:(float)value_ {
	[self setPrimitiveLon:@(value_)];
}

@dynamic name;

@dynamic schemeFilePath;

@dynamic stationId;

- (int32_t)stationIdValue {
	NSNumber *result = [self stationId];
	return [result intValue];
}

- (void)setStationIdValue:(int32_t)value_ {
	[self setStationId:@(value_)];
}

- (int32_t)primitiveStationIdValue {
	NSNumber *result = [self primitiveStationId];
	return [result intValue];
}

- (void)setPrimitiveStationIdValue:(int32_t)value_ {
	[self setPrimitiveStationId:@(value_)];
}

@dynamic city;

@dynamic interchangesFrom;

- (NSMutableSet*)interchangesFromSet {
	[self willAccessValueForKey:@"interchangesFrom"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"interchangesFrom"];

	[self didAccessValueForKey:@"interchangesFrom"];
	return result;
}

@dynamic interchangesTo;

- (NSMutableSet*)interchangesToSet {
	[self willAccessValueForKey:@"interchangesTo"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"interchangesTo"];

	[self didAccessValueForKey:@"interchangesTo"];
	return result;
}

@dynamic line;

@dynamic node;

@dynamic portals;

- (NSMutableSet*)portalsSet {
	[self willAccessValueForKey:@"portals"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"portals"];

	[self didAccessValueForKey:@"portals"];
	return result;
}

@end

