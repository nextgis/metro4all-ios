// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MFAInterchange.m instead.

#import "_MFAInterchange.h"

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

	return keyPaths;
}

@dynamic fromStation;

@dynamic toStation;

@end

