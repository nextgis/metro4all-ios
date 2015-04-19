// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MFAInterchange.m instead.

#import "_MFAInterchange.h"

const struct MFAInterchangeAttributes MFAInterchangeAttributes = {
	.fromStationId = @"fromStationId",
	.toStationId = @"toStationId",
};

const struct MFAInterchangeRelationships MFAInterchangeRelationships = {
	.fromStation = @"fromStation",
	.toStation = @"toStation",
};

@implementation MFAInterchangeID
@end

@implementation _MFAInterchange

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Interchange" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Interchange";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Interchange" inManagedObjectContext:moc_];
}

- (MFAInterchangeID*)objectID {
	return (MFAInterchangeID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"fromStationIdValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"fromStationId"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"toStationIdValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"toStationId"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic fromStationId;

- (int32_t)fromStationIdValue {
	NSNumber *result = [self fromStationId];
	return [result intValue];
}

- (void)setFromStationIdValue:(int32_t)value_ {
	[self setFromStationId:@(value_)];
}

- (int32_t)primitiveFromStationIdValue {
	NSNumber *result = [self primitiveFromStationId];
	return [result intValue];
}

- (void)setPrimitiveFromStationIdValue:(int32_t)value_ {
	[self setPrimitiveFromStationId:@(value_)];
}

@dynamic toStationId;

- (int32_t)toStationIdValue {
	NSNumber *result = [self toStationId];
	return [result intValue];
}

- (void)setToStationIdValue:(int32_t)value_ {
	[self setToStationId:@(value_)];
}

- (int32_t)primitiveToStationIdValue {
	NSNumber *result = [self primitiveToStationId];
	return [result intValue];
}

- (void)setPrimitiveToStationIdValue:(int32_t)value_ {
	[self setPrimitiveToStationId:@(value_)];
}

@dynamic fromStation;

@dynamic toStation;

@end

