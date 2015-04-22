/**
	Patient.m
 
	A subclass of NSManagedObject that provides an object-oriented representation of an Patient entity stored in Core Data.
 */

#import "Patient.h"

@implementation Patient

@dynamic age;
@dynamic gender;
@dynamic patientID;
@dynamic operations;

/*	description is implemented to be used for debug output */
-(NSString *)description
{
    return [NSString stringWithFormat:@"Patient aged: %@, id: %@ and gender: %@",  self.age, self.patientID, self.gender];
}

/*	durationString returns a string representation of the gender of a Patient, which is internally stored as an integer. */
- (NSString *)genderString
{
    return [self.gender isEqualToNumber:[NSNumber numberWithInt:0]] ? @"Male" : @"Female";
}

/*	durationString returns a string representation of the age of a Patient, which is internally stored as an integer. */
- (NSString *)ageString
{
    return self.age != nil ? [self.age stringValue] : @"";
}

@end