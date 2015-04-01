// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MFAStation.h instead.

@import CoreData;

extern const struct MFAStationAttributes {
	__unsafe_unretained NSString *lat;
	__unsafe_unretained NSString *lineId;
	__unsafe_unretained NSString *lon;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *schemeFilePath;
	__unsafe_unretained NSString *stationId;
} MFAStationAttributes;

extern const struct MFAStationRelationships {
	__unsafe_unretained NSString *city;
	__unsafe_unretained NSString *interchangesFrom;
	__unsafe_unretained NSString *interchangesTo;
	__unsafe_unretained NSString *line;
	__unsafe_unretained NSString *node;
	__unsafe_unretained NSString *portals;
} MFAStationRelationships;

@class MFACity;
@class MFAInterchange;
@class MFAInterchange;
@class MFALine;
@class MFANode;
@class MFAPortal;

@interface MFAStationID : NSManagedObjectID {}
@end

@interface _MFAStation : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) MFAStationID* objectID;

@property (nonatomic, strong) NSNumber* lat;

@property (atomic) float latValue;
- (float)latValue;
- (void)setLatValue:(float)value_;

//- (BOOL)validateLat:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* lineId;

@property (atomic) int32_t lineIdValue;
- (int32_t)lineIdValue;
- (void)setLineIdValue:(int32_t)value_;

//- (BOOL)validateLineId:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* lon;

@property (atomic) float lonValue;
- (float)lonValue;
- (void)setLonValue:(float)value_;

//- (BOOL)validateLon:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* name;

//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* schemeFilePath;

//- (BOOL)validateSchemeFilePath:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* stationId;

@property (atomic) int32_t stationIdValue;
- (int32_t)stationIdValue;
- (void)setStationIdValue:(int32_t)value_;

//- (BOOL)validateStationId:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) MFACity *city;

//- (BOOL)validateCity:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) MFAInterchange *interchangesFrom;

//- (BOOL)validateInterchangesFrom:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) MFAInterchange *interchangesTo;

//- (BOOL)validateInterchangesTo:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) MFALine *line;

//- (BOOL)validateLine:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) MFANode *node;

//- (BOOL)validateNode:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSSet *portals;

- (NSMutableSet*)portalsSet;

@end

@interface _MFAStation (PortalsCoreDataGeneratedAccessors)
- (void)addPortals:(NSSet*)value_;
- (void)removePortals:(NSSet*)value_;
- (void)addPortalsObject:(MFAPortal*)value_;
- (void)removePortalsObject:(MFAPortal*)value_;

@end

@interface _MFAStation (CoreDataGeneratedPrimitiveAccessors)

- (NSNumber*)primitiveLat;
- (void)setPrimitiveLat:(NSNumber*)value;

- (float)primitiveLatValue;
- (void)setPrimitiveLatValue:(float)value_;

- (NSNumber*)primitiveLineId;
- (void)setPrimitiveLineId:(NSNumber*)value;

- (int32_t)primitiveLineIdValue;
- (void)setPrimitiveLineIdValue:(int32_t)value_;

- (NSNumber*)primitiveLon;
- (void)setPrimitiveLon:(NSNumber*)value;

- (float)primitiveLonValue;
- (void)setPrimitiveLonValue:(float)value_;

- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;

- (NSString*)primitiveSchemeFilePath;
- (void)setPrimitiveSchemeFilePath:(NSString*)value;

- (NSNumber*)primitiveStationId;
- (void)setPrimitiveStationId:(NSNumber*)value;

- (int32_t)primitiveStationIdValue;
- (void)setPrimitiveStationIdValue:(int32_t)value_;

- (MFACity*)primitiveCity;
- (void)setPrimitiveCity:(MFACity*)value;

- (MFAInterchange*)primitiveInterchangesFrom;
- (void)setPrimitiveInterchangesFrom:(MFAInterchange*)value;

- (MFAInterchange*)primitiveInterchangesTo;
- (void)setPrimitiveInterchangesTo:(MFAInterchange*)value;

- (MFALine*)primitiveLine;
- (void)setPrimitiveLine:(MFALine*)value;

- (MFANode*)primitiveNode;
- (void)setPrimitiveNode:(MFANode*)value;

- (NSMutableSet*)primitivePortals;
- (void)setPrimitivePortals:(NSMutableSet*)value;

@end
