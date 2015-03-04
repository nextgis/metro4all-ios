// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MFAInterchange.h instead.

@import CoreData;

extern const struct MFAInterchangeRelationships {
	__unsafe_unretained NSString *fromStation;
	__unsafe_unretained NSString *toStation;
} MFAInterchangeRelationships;

@class MFAStation;
@class MFAStation;

@interface MFAInterchangeID : NSManagedObjectID {}
@end

@interface _MFAInterchange : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) MFAInterchangeID* objectID;

@property (nonatomic, strong) MFAStation *fromStation;

//- (BOOL)validateFromStation:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) MFAStation *toStation;

//- (BOOL)validateToStation:(id*)value_ error:(NSError**)error_;

@end

@interface _MFAInterchange (CoreDataGeneratedPrimitiveAccessors)

- (MFAStation*)primitiveFromStation;
- (void)setPrimitiveFromStation:(MFAStation*)value;

- (MFAStation*)primitiveToStation;
- (void)setPrimitiveToStation:(MFAStation*)value;

@end
