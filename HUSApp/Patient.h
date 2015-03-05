//
//  Patient.h
//  app development project
//
//  Created by Bandi Enkh-Amgalan on 2/11/15.
//  Copyright (c) 2015 a. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface Patient : NSManagedObject

@property (nonatomic, retain) NSNumber * age;
@property (nonatomic, retain) NSNumber * gender;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * patientID;
@property (nonatomic, retain) NSSet *operations;
@end

@interface Patient (CoreDataGeneratedAccessors)

- (void)addOperationsObject:(NSManagedObject *)value;
- (void)removeOperationsObject:(NSManagedObject *)value;
- (void)addOperations:(NSSet *)values;
- (void)removeOperations:(NSSet *)values;
- (BOOL)isCompletePatient;

- (NSString *)firstLetter;

@end
