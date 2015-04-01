// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MFANode.h instead.

@import CoreData;

extern const struct MFANodeAttributes {
	__unsafe_unretained NSString *nodeId;
} MFANodeAttributes;

extern const struct MFANodeRelationships {
	__unsafe_unretained NSString *stations;
} MFANodeRelationships;

@class MFAStation;

@interface MFANodeID : NSManagedObjectID {}
@end

@interface _MFANode : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) MFANodeID* objectID;

@property (nonatomic, strong) NSNumber* nodeId;

@property (atomic) int32_t nodeIdValue;
- (int32_t)nodeIdValue;
- (void)setNodeIdValue:(int32_t)value_;

//- (BOOL)validateNodeId:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSSet *stations;

- (NSMutableSet*)stationsSet;

@end

@interface _MFANode (StationsCoreDataGeneratedAccessors)
- (void)addStations:(NSSet*)value_;
- (void)removeStations:(NSSet*)value_;
- (void)addStationsObject:(MFAStation*)value_;
- (void)removeStationsObject:(MFAStation*)value_;

@end

@interface _MFANode (CoreDataGeneratedPrimitiveAccessors)

- (NSNumber*)primitiveNodeId;
- (void)setPrimitiveNodeId:(NSNumber*)value;

- (int32_t)primitiveNodeIdValue;
- (void)setPrimitiveNodeIdValue:(int32_t)value_;

- (NSMutableSet*)primitiveStations;
- (void)setPrimitiveStations:(NSMutableSet*)value;

@end
