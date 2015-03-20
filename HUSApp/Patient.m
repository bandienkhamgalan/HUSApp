//
//  Patient.m
//  app development project
//
//  Created by Bandi Enkh-Amgalan on 2/11/15.
//  Copyright (c) 2015 a. All rights reserved.
//

#import "Patient.h"

@implementation Patient

@dynamic age;
@dynamic gender;
@dynamic patientID;
@dynamic operations;

-(NSString *)description
{
    return [NSString stringWithFormat:@"Patient aged: %@, id: %@ and gender: %@",  self.age, self.patientID, self.gender];
}

- (NSString *)genderString
{
    return [self.gender isEqualToNumber:[NSNumber numberWithInt:0]] ? @"Male" : @"Female";
}

- (NSString *)ageString
{
    return self.age != nil ? [self.age stringValue] : @"";
}


- (NSString *)firstLetter
{
    [self willAccessValueForKey:@"firstLetter"];
    NSString *firstLetter = [[[self patientID] substringToIndex:1] uppercaseString];
    [self didAccessValueForKey:@"firstLetter"];
    return firstLetter;
}

@end