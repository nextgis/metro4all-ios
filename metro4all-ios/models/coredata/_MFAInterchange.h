// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MFAInterchange.h instead.

@import CoreData;

extern const struct MFAInterchangeAttributes {
	__unsafe_unretained NSString *fromStationId;
	__unsafe_unretained NSString *toStationId;
} MFAInterchangeAttributes;

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

@property (nonatomic, strong) NSNumber* fromStationId;

@property (atomic) int32_t fromStationIdValue;
- (int32_t)fromStationIdValue;
- (void)setFromStationIdValue:(int32_t)value_;

//- (BOOL)validateFromStationId:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* toStationId;

@property (atomic) int32_t toStationIdValue;
- (int32_t)toStationIdValue;
- (void)setToStationIdValue:(int32_t)value_;

//- (BOOL)validateToStationId:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) MFAStation *fromStation;

//- (BOOL)validateFromStation:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) MFAStation *toStation;

//- (BOOL)validateToStation:(id*)value_ error:(NSError**)error_;

@end

@interface _MFAInterchange (CoreDataGeneratedPrimitiveAccessors)

- (NSNumber*)primitiveFromStationId;
- (void)setPrimitiveFromStationId:(NSNumber*)value;

- (int32_t)primitiveFromStationIdValue;
- (void)setPrimitiveFromStationIdValue:(int32_t)value_;

- (NSNumber*)primitiveToStationId;
- (void)setPrimitiveToStationId:(NSNumber*)value;

- (int32_t)primitiveToStationIdValue;
- (void)setPrimitiveToStationIdValue:(int32_t)value_;

- (MFAStation*)primitiveFromStation;
- (void)setPrimitiveFromStation:(MFAStation*)value;

- (MFAStation*)primitiveToStation;
- (void)setPrimitiveToStation:(MFAStation*)value;

@end
