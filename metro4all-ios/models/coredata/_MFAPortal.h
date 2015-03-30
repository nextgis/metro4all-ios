// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MFAPortal.h instead.

@import CoreData;

extern const struct MFAPortalAttributes {
	__unsafe_unretained NSString *direction;
	__unsafe_unretained NSString *lat;
	__unsafe_unretained NSString *lon;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *portalNumber;
	__unsafe_unretained NSString *potralId;
	__unsafe_unretained NSString *stationId;
} MFAPortalAttributes;

extern const struct MFAPortalRelationships {
	__unsafe_unretained NSString *station;
} MFAPortalRelationships;

@class MFAStation;

@class NSObject;

@interface MFAPortalID : NSManagedObjectID {}
@end

@interface _MFAPortal : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) MFAPortalID* objectID;

@property (nonatomic, strong) NSNumber* direction;

@property (atomic) int16_t directionValue;
- (int16_t)directionValue;
- (void)setDirectionValue:(int16_t)value_;

//- (BOOL)validateDirection:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* lat;

@property (atomic) float latValue;
- (float)latValue;
- (void)setLatValue:(float)value_;

//- (BOOL)validateLat:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* lon;

@property (atomic) float lonValue;
- (float)lonValue;
- (void)setLonValue:(float)value_;

//- (BOOL)validateLon:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) id name;

//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* portalNumber;

@property (atomic) int16_t portalNumberValue;
- (int16_t)portalNumberValue;
- (void)setPortalNumberValue:(int16_t)value_;

//- (BOOL)validatePortalNumber:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* potralId;

@property (atomic) int32_t potralIdValue;
- (int32_t)potralIdValue;
- (void)setPotralIdValue:(int32_t)value_;

//- (BOOL)validatePotralId:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* stationId;

@property (atomic) int32_t stationIdValue;
- (int32_t)stationIdValue;
- (void)setStationIdValue:(int32_t)value_;

//- (BOOL)validateStationId:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) MFAStation *station;

//- (BOOL)validateStation:(id*)value_ error:(NSError**)error_;

@end

@interface _MFAPortal (CoreDataGeneratedPrimitiveAccessors)

- (NSNumber*)primitiveDirection;
- (void)setPrimitiveDirection:(NSNumber*)value;

- (int16_t)primitiveDirectionValue;
- (void)setPrimitiveDirectionValue:(int16_t)value_;

- (NSNumber*)primitiveLat;
- (void)setPrimitiveLat:(NSNumber*)value;

- (float)primitiveLatValue;
- (void)setPrimitiveLatValue:(float)value_;

- (NSNumber*)primitiveLon;
- (void)setPrimitiveLon:(NSNumber*)value;

- (float)primitiveLonValue;
- (void)setPrimitiveLonValue:(float)value_;

- (id)primitiveName;
- (void)setPrimitiveName:(id)value;

- (NSNumber*)primitivePortalNumber;
- (void)setPrimitivePortalNumber:(NSNumber*)value;

- (int16_t)primitivePortalNumberValue;
- (void)setPrimitivePortalNumberValue:(int16_t)value_;

- (NSNumber*)primitivePotralId;
- (void)setPrimitivePotralId:(NSNumber*)value;

- (int32_t)primitivePotralIdValue;
- (void)setPrimitivePotralIdValue:(int32_t)value_;

- (NSNumber*)primitiveStationId;
- (void)setPrimitiveStationId:(NSNumber*)value;

- (int32_t)primitiveStationIdValue;
- (void)setPrimitiveStationIdValue:(int32_t)value_;

- (MFAStation*)primitiveStation;
- (void)setPrimitiveStation:(MFAStation*)value;

@end
