//
//  Operation.m
//  app development project
//
//  Created by Bandi Enkh-Amgalan on 2/11/15.
//  Copyright (c) 2015 a. All rights reserved.
//

#import "Operation.h"
#import "Patient.h"


@implementation Operation

@dynamic admittedToICU;
@dynamic alive;
@dynamic bloodLoss;
@dynamic complications;
@dynamic date;
@dynamic deathDate;
@dynamic duration;
@dynamic followUpDate;
@dynamic resection;
@dynamic patient;

- (NSString *)year
{
    [self willAccessValueForKey:@"year"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy";
    return [dateFormatter stringFromDate:self.date];
}

@end
