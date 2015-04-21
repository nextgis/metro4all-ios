// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MFAInterchange.m instead.

#import "_MFAInterchange.h"

const struct MFAInterchangeAttributes MFAInterchangeAttributes = {
	.elevator = @"elevator",
	.elevatorMinusSteps = @"elevatorMinusSteps",
	.escalator = @"escalator",
	.fromStationId = @"fromStationId",
	.maxAngle = @"maxAngle",
	.maxRailWidth = @"maxRailWidth",
	.maxWidth = @"maxWidth",
	.minRailWidth = @"minRailWidth",
	.minStep = @"minStep",
	.minStepRamp = @"minStepRamp",
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

	if ([key isEqualToString:@"elevatorValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"elevator"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"elevatorMinusStepsValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"elevatorMinusSteps"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"escalatorValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"escalator"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"fromStationIdValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"fromStationId"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"maxAngleValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"maxAngle"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"maxRailWidthValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"maxRailWidth"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"maxWidthValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"maxWidth"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"minRailWidthValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"minRailWidth"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"minStepValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"minStep"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"minStepRampValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"minStepRamp"];
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

@dynamic elevator;

- (BOOL)elevatorValue {
	NSNumber *result = [self elevator];
	return [result boolValue];
}

- (void)setElevatorValue:(BOOL)value_ {
	[self setElevator:@(value_)];
}

- (BOOL)primitiveElevatorValue {
	NSNumber *result = [self primitiveElevator];
	return [result boolValue];
}

- (void)setPrimitiveElevatorValue:(BOOL)value_ {
	[self setPrimitiveElevator:@(value_)];
}

@dynamic elevatorMinusSteps;

- (int32_t)elevatorMinusStepsValue {
	NSNumber *result = [self elevatorMinusSteps];
	return [result intValue];
}

- (void)setElevatorMinusStepsValue:(int32_t)value_ {
	[self setElevatorMinusSteps:@(value_)];
}

- (int32_t)primitiveElevatorMinusStepsValue {
	NSNumber *result = [self primitiveElevatorMinusSteps];
	return [result intValue];
}

- (void)setPrimitiveElevatorMinusStepsValue:(int32_t)value_ {
	[self setPrimitiveElevatorMinusSteps:@(value_)];
}

@dynamic escalator;

- (BOOL)escalatorValue {
	NSNumber *result = [self escalator];
	return [result boolValue];
}

- (void)setEscalatorValue:(BOOL)value_ {
	[self setEscalator:@(value_)];
}

- (BOOL)primitiveEscalatorValue {
	NSNumber *result = [self primitiveEscalator];
	return [result boolValue];
}

- (void)setPrimitiveEscalatorValue:(BOOL)value_ {
	[self setPrimitiveEscalator:@(value_)];
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

@dynamic maxAngle;

- (float)maxAngleValue {
	NSNumber *result = [self maxAngle];
	return [result floatValue];
}

- (void)setMaxAngleValue:(float)value_ {
	[self setMaxAngle:@(value_)];
}

- (float)primitiveMaxAngleValue {
	NSNumber *result = [self primitiveMaxAngle];
	return [result floatValue];
}

- (void)setPrimitiveMaxAngleValue:(float)value_ {
	[self setPrimitiveMaxAngle:@(value_)];
}

@dynamic maxRailWidth;

- (int32_t)maxRailWidthValue {
	NSNumber *result = [self maxRailWidth];
	return [result intValue];
}

- (void)setMaxRailWidthValue:(int32_t)value_ {
	[self setMaxRailWidth:@(value_)];
}

- (int32_t)primitiveMaxRailWidthValue {
	NSNumber *result = [self primitiveMaxRailWidth];
	return [result intValue];
}

- (void)setPrimitiveMaxRailWidthValue:(int32_t)value_ {
	[self setPrimitiveMaxRailWidth:@(value_)];
}

@dynamic maxWidth;

- (int32_t)maxWidthValue {
	NSNumber *result = [self maxWidth];
	return [result intValue];
}

- (void)setMaxWidthValue:(int32_t)value_ {
	[self setMaxWidth:@(value_)];
}

- (int32_t)primitiveMaxWidthValue {
	NSNumber *result = [self primitiveMaxWidth];
	return [result intValue];
}

- (void)setPrimitiveMaxWidthValue:(int32_t)value_ {
	[self setPrimitiveMaxWidth:@(value_)];
}

@dynamic minRailWidth;

- (int32_t)minRailWidthValue {
	NSNumber *result = [self minRailWidth];
	return [result intValue];
}

- (void)setMinRailWidthValue:(int32_t)value_ {
	[self setMinRailWidth:@(value_)];
}

- (int32_t)primitiveMinRailWidthValue {
	NSNumber *result = [self primitiveMinRailWidth];
	return [result intValue];
}

- (void)setPrimitiveMinRailWidthValue:(int32_t)value_ {
	[self setPrimitiveMinRailWidth:@(value_)];
}

@dynamic minStep;

- (int32_t)minStepValue {
	NSNumber *result = [self minStep];
	return [result intValue];
}

- (void)setMinStepValue:(int32_t)value_ {
	[self setMinStep:@(value_)];
}

- (int32_t)primitiveMinStepValue {
	NSNumber *result = [self primitiveMinStep];
	return [result intValue];
}

- (void)setPrimitiveMinStepValue:(int32_t)value_ {
	[self setPrimitiveMinStep:@(value_)];
}

@dynamic minStepRamp;

- (int32_t)minStepRampValue {
	NSNumber *result = [self minStepRamp];
	return [result intValue];
}

- (void)setMinStepRampValue:(int32_t)value_ {
	[self setMinStepRamp:@(value_)];
}

- (int32_t)primitiveMinStepRampValue {
	NSNumber *result = [self primitiveMinStepRamp];
	return [result intValue];
}

- (void)setPrimitiveMinStepRampValue:(int32_t)value_ {
	[self setPrimitiveMinStepRamp:@(value_)];
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

