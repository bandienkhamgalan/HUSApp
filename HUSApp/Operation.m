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
@dynamic approach;
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

- (NSArray *)complicationsArray
{
    return [Operation emptyComplications].allKeys;
}

+ (NSDictionary *)emptyComplications
{
    return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:false], @"Pneumonia", [NSNumber numberWithBool:false], @"Respiratory failure", [NSNumber numberWithBool:false], @"Empyema", [NSNumber numberWithBool:false], @"Prolonged air leak", [NSNumber numberWithBool:false], @"Pulmonary embolism", [NSNumber numberWithBool:false], @"Arrythmia", [NSNumber numberWithBool:false], @"Myocardial infarction", [NSNumber numberWithBool:false], @"Delirium", [NSNumber numberWithBool:false], @"Cerebral infarktion/bleeding", nil];
}

- (void)setComplicationsValue:(NSDictionary *)complications
{
    
}

+ (NSArray *)possibleResections
{
    return [NSArray arrayWithObjects:@"Lobectomy", @"Segmentectomy", @"Pneumonectomy", @"Broncho- or Vasculo-plastic", @"Nonanatomical resection", nil];
}

- (void)setResectionValue:(NSString *)resection
{
    
}

+ (NSArray *)possibleApproaches
{
    return [NSArray arrayWithObjects:@"Minimally Invasive", @"Thoracotomy", nil];
}

- (void)setApproachValue:(NSString *)approach
{
    
}

@end