// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MFALine.h instead.

@import CoreData;

extern const struct MFALineAttributes {
	__unsafe_unretained NSString *color;
	__unsafe_unretained NSString *lineId;
	__unsafe_unretained NSString *name;
} MFALineAttributes;

extern const struct MFALineRelationships {
	__unsafe_unretained NSString *city;
	__unsafe_unretained NSString *stations;
} MFALineRelationships;

@class MFACity;
@class MFAStation;

@class NSObject;

@class NSObject;

@interface MFALineID : NSManagedObjectID {}
@end

@interface _MFALine : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) MFALineID* objectID;

@property (nonatomic, strong) id color;

//- (BOOL)validateColor:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* lineId;

@property (atomic) int32_t lineIdValue;
- (int32_t)lineIdValue;
- (void)setLineIdValue:(int32_t)value_;

//- (BOOL)validateLineId:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) id name;

//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) MFACity *city;

//- (BOOL)validateCity:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSSet *stations;

- (NSMutableSet*)stationsSet;

@end

@interface _MFALine (StationsCoreDataGeneratedAccessors)
- (void)addStations:(NSSet*)value_;
- (void)removeStations:(NSSet*)value_;
- (void)addStationsObject:(MFAStation*)value_;
- (void)removeStationsObject:(MFAStation*)value_;

@end

@interface _MFALine (CoreDataGeneratedPrimitiveAccessors)

- (id)primitiveColor;
- (void)setPrimitiveColor:(id)value;

- (NSNumber*)primitiveLineId;
- (void)setPrimitiveLineId:(NSNumber*)value;

- (int32_t)primitiveLineIdValue;
- (void)setPrimitiveLineIdValue:(int32_t)value_;

- (id)primitiveName;
- (void)setPrimitiveName:(id)value;

- (MFACity*)primitiveCity;
- (void)setPrimitiveCity:(MFACity*)value;

- (NSMutableSet*)primitiveStations;
- (void)setPrimitiveStations:(NSMutableSet*)value;

@end
