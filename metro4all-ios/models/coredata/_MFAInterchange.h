// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MFAInterchange.h instead.

@import CoreData;

extern const struct MFAInterchangeAttributes {
	__unsafe_unretained NSString *elevator;
	__unsafe_unretained NSString *elevatorMinusSteps;
	__unsafe_unretained NSString *escalator;
	__unsafe_unretained NSString *fromStationId;
	__unsafe_unretained NSString *maxAngle;
	__unsafe_unretained NSString *maxRailWidth;
	__unsafe_unretained NSString *maxWidth;
	__unsafe_unretained NSString *minRailWidth;
	__unsafe_unretained NSString *minStep;
	__unsafe_unretained NSString *minStepRamp;
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

@property (nonatomic, strong) NSNumber* elevator;

@property (atomic) BOOL elevatorValue;
- (BOOL)elevatorValue;
- (void)setElevatorValue:(BOOL)value_;

//- (BOOL)validateElevator:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* elevatorMinusSteps;

@property (atomic) int32_t elevatorMinusStepsValue;
- (int32_t)elevatorMinusStepsValue;
- (void)setElevatorMinusStepsValue:(int32_t)value_;

//- (BOOL)validateElevatorMinusSteps:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* escalator;

@property (atomic) BOOL escalatorValue;
- (BOOL)escalatorValue;
- (void)setEscalatorValue:(BOOL)value_;

//- (BOOL)validateEscalator:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* fromStationId;

@property (atomic) int32_t fromStationIdValue;
- (int32_t)fromStationIdValue;
- (void)setFromStationIdValue:(int32_t)value_;

//- (BOOL)validateFromStationId:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* maxAngle;

@property (atomic) float maxAngleValue;
- (float)maxAngleValue;
- (void)setMaxAngleValue:(float)value_;

//- (BOOL)validateMaxAngle:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* maxRailWidth;

@property (atomic) int32_t maxRailWidthValue;
- (int32_t)maxRailWidthValue;
- (void)setMaxRailWidthValue:(int32_t)value_;

//- (BOOL)validateMaxRailWidth:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* maxWidth;

@property (atomic) int32_t maxWidthValue;
- (int32_t)maxWidthValue;
- (void)setMaxWidthValue:(int32_t)value_;

//- (BOOL)validateMaxWidth:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* minRailWidth;

@property (atomic) int32_t minRailWidthValue;
- (int32_t)minRailWidthValue;
- (void)setMinRailWidthValue:(int32_t)value_;

//- (BOOL)validateMinRailWidth:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* minStep;

@property (atomic) int32_t minStepValue;
- (int32_t)minStepValue;
- (void)setMinStepValue:(int32_t)value_;

//- (BOOL)validateMinStep:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* minStepRamp;

@property (atomic) int32_t minStepRampValue;
- (int32_t)minStepRampValue;
- (void)setMinStepRampValue:(int32_t)value_;

//- (BOOL)validateMinStepRamp:(id*)value_ error:(NSError**)error_;

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

- (NSNumber*)primitiveElevator;
- (void)setPrimitiveElevator:(NSNumber*)value;

- (BOOL)primitiveElevatorValue;
- (void)setPrimitiveElevatorValue:(BOOL)value_;

- (NSNumber*)primitiveElevatorMinusSteps;
- (void)setPrimitiveElevatorMinusSteps:(NSNumber*)value;

- (int32_t)primitiveElevatorMinusStepsValue;
- (void)setPrimitiveElevatorMinusStepsValue:(int32_t)value_;

- (NSNumber*)primitiveEscalator;
- (void)setPrimitiveEscalator:(NSNumber*)value;

- (BOOL)primitiveEscalatorValue;
- (void)setPrimitiveEscalatorValue:(BOOL)value_;

- (NSNumber*)primitiveFromStationId;
- (void)setPrimitiveFromStationId:(NSNumber*)value;

- (int32_t)primitiveFromStationIdValue;
- (void)setPrimitiveFromStationIdValue:(int32_t)value_;

- (NSNumber*)primitiveMaxAngle;
- (void)setPrimitiveMaxAngle:(NSNumber*)value;

- (float)primitiveMaxAngleValue;
- (void)setPrimitiveMaxAngleValue:(float)value_;

- (NSNumber*)primitiveMaxRailWidth;
- (void)setPrimitiveMaxRailWidth:(NSNumber*)value;

- (int32_t)primitiveMaxRailWidthValue;
- (void)setPrimitiveMaxRailWidthValue:(int32_t)value_;

- (NSNumber*)primitiveMaxWidth;
- (void)setPrimitiveMaxWidth:(NSNumber*)value;

- (int32_t)primitiveMaxWidthValue;
- (void)setPrimitiveMaxWidthValue:(int32_t)value_;

- (NSNumber*)primitiveMinRailWidth;
- (void)setPrimitiveMinRailWidth:(NSNumber*)value;

- (int32_t)primitiveMinRailWidthValue;
- (void)setPrimitiveMinRailWidthValue:(int32_t)value_;

- (NSNumber*)primitiveMinStep;
- (void)setPrimitiveMinStep:(NSNumber*)value;

- (int32_t)primitiveMinStepValue;
- (void)setPrimitiveMinStepValue:(int32_t)value_;

- (NSNumber*)primitiveMinStepRamp;
- (void)setPrimitiveMinStepRamp:(NSNumber*)value;

- (int32_t)primitiveMinStepRampValue;
- (void)setPrimitiveMinStepRampValue:(int32_t)value_;

- (NSNumber*)primitiveToStationId;
- (void)setPrimitiveToStationId:(NSNumber*)value;

- (int32_t)primitiveToStationIdValue;
- (void)setPrimitiveToStationIdValue:(int32_t)value_;

- (MFAStation*)primitiveFromStation;
- (void)setPrimitiveFromStation:(MFAStation*)value;

- (MFAStation*)primitiveToStation;
- (void)setPrimitiveToStation:(MFAStation*)value;

@end
