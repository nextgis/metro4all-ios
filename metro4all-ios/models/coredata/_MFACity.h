// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MFACity.h instead.

@import CoreData;

extern const struct MFACityAttributes {
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *path;
	__unsafe_unretained NSString *version;
} MFACityAttributes;

extern const struct MFACityRelationships {
	__unsafe_unretained NSString *lines;
} MFACityRelationships;

@class MFALine;

@interface MFACityID : NSManagedObjectID {}
@end

@interface _MFACity : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) MFACityID* objectID;

@property (nonatomic, strong) NSString* name;

//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* path;

//- (BOOL)validatePath:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* version;

@property (atomic) int32_t versionValue;
- (int32_t)versionValue;
- (void)setVersionValue:(int32_t)value_;

//- (BOOL)validateVersion:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSSet *lines;

- (NSMutableSet*)linesSet;

@end

@interface _MFACity (LinesCoreDataGeneratedAccessors)
- (void)addLines:(NSSet*)value_;
- (void)removeLines:(NSSet*)value_;
- (void)addLinesObject:(MFALine*)value_;
- (void)removeLinesObject:(MFALine*)value_;

@end

@interface _MFACity (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;

- (NSString*)primitivePath;
- (void)setPrimitivePath:(NSString*)value;

- (NSNumber*)primitiveVersion;
- (void)setPrimitiveVersion:(NSNumber*)value;

- (int32_t)primitiveVersionValue;
- (void)setPrimitiveVersionValue:(int32_t)value_;

- (NSMutableSet*)primitiveLines;
- (void)setPrimitiveLines:(NSMutableSet*)value;

@end
