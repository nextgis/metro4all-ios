// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MFANode.m instead.

#import "_MFANode.h"

const struct MFANodeAttributes MFANodeAttributes = {
	.nodeId = @"nodeId",
};

const struct MFANodeRelationships MFANodeRelationships = {
	.stations = @"stations",
};

@implementation MFANodeID
@end

@implementation _MFANode

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Node" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Node";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Node" inManagedObjectContext:moc_];
}

- (MFANodeID*)objectID {
	return (MFANodeID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"nodeIdValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"nodeId"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic nodeId;

- (int32_t)nodeIdValue {
	NSNumber *result = [self nodeId];
	return [result intValue];
}

- (void)setNodeIdValue:(int32_t)value_ {
	[self setNodeId:@(value_)];
}

- (int32_t)primitiveNodeIdValue {
	NSNumber *result = [self primitiveNodeId];
	return [result intValue];
}

- (void)setPrimitiveNodeIdValue:(int32_t)value_ {
	[self setPrimitiveNodeId:@(value_)];
}

@dynamic stations;

- (NSMutableSet*)stationsSet {
	[self willAccessValueForKey:@"stations"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"stations"];

	[self didAccessValueForKey:@"stations"];
	return result;
}

@end

