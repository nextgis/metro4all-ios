// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MFAPortal.m instead.

#import "_MFAPortal.h"

const struct MFAPortalAttributes MFAPortalAttributes = {
	.direction = @"direction",
	.lat = @"lat",
	.lon = @"lon",
	.name = @"name",
	.portalNumber = @"portalNumber",
	.potralId = @"potralId",
	.stationId = @"stationId",
};

const struct MFAPortalRelationships MFAPortalRelationships = {
	.station = @"station",
};

@implementation MFAPortalID
@end

@implementation _MFAPortal

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Portal" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Portal";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Portal" inManagedObjectContext:moc_];
}

- (MFAPortalID*)objectID {
	return (MFAPortalID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"directionValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"direction"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"latValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"lat"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"lonValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"lon"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"portalNumberValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"portalNumber"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"potralIdValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"potralId"];
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

@dynamic direction;

- (int16_t)directionValue {
	NSNumber *result = [self direction];
	return [result shortValue];
}

- (void)setDirectionValue:(int16_t)value_ {
	[self setDirection:@(value_)];
}

- (int16_t)primitiveDirectionValue {
	NSNumber *result = [self primitiveDirection];
	return [result shortValue];
}

- (void)setPrimitiveDirectionValue:(int16_t)value_ {
	[self setPrimitiveDirection:@(value_)];
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

@dynamic portalNumber;

- (int16_t)portalNumberValue {
	NSNumber *result = [self portalNumber];
	return [result shortValue];
}

- (void)setPortalNumberValue:(int16_t)value_ {
	[self setPortalNumber:@(value_)];
}

- (int16_t)primitivePortalNumberValue {
	NSNumber *result = [self primitivePortalNumber];
	return [result shortValue];
}

- (void)setPrimitivePortalNumberValue:(int16_t)value_ {
	[self setPrimitivePortalNumber:@(value_)];
}

@dynamic potralId;

- (int32_t)potralIdValue {
	NSNumber *result = [self potralId];
	return [result intValue];
}

- (void)setPotralIdValue:(int32_t)value_ {
	[self setPotralId:@(value_)];
}

- (int32_t)primitivePotralIdValue {
	NSNumber *result = [self primitivePotralId];
	return [result intValue];
}

- (void)setPrimitivePotralIdValue:(int32_t)value_ {
	[self setPrimitivePotralId:@(value_)];
}

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

@dynamic station;

@end

