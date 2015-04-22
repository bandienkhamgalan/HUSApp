/**
	Patient.h
 */

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface Patient : NSManagedObject

@property (nonatomic, retain) NSNumber * age;
@property (nonatomic, retain) NSNumber * gender;
@property (nonatomic, retain) NSString * patientID;
@property (nonatomic, retain) NSSet *operations;
@end

@interface Patient (CoreDataGeneratedAccessors)

- (void)addOperationsObject:(NSManagedObject *)value;
- (void)removeOperationsObject:(NSManagedObject *)value;
- (void)addOperations:(NSSet *)values;
- (void)removeOperations:(NSSet *)values;
- (BOOL)isCompletePatient;
- (NSString *)genderString;
- (NSString *)ageString;

@end
