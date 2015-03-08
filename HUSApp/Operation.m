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
@dynamic durationOfStay;

- (NSString *)durationString
{
    int minutes = self.duration.intValue;
    if( minutes > 60 )
    {
        return minutes % 60 == 0 ? [NSString stringWithFormat:@"%d hours", minutes / 60] : [NSString stringWithFormat:@"%d hours and %d minutes", minutes / 60, minutes % 60];
    }
    else
        return [NSString stringWithFormat:@"%d minutes", minutes];
}

- (NSArray *)complicationsArray
{
    NSArray *sortedComplicationKeys = [[Operation emptyComplications].allKeys sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:nil ascending:YES]]];
    NSMutableArray *toReturn = [NSMutableArray array];
    int complications = self.complications.intValue;
    for(int i = 0 ; i < sortedComplicationKeys.count ; i++)
        if( complications & 1 << i )
            [toReturn addObject:[sortedComplicationKeys objectAtIndex:i]];
    return toReturn;
}

+ (NSMutableDictionary *)emptyComplications
{
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:false], @"Pneumonia", [NSNumber numberWithBool:false], @"Respiratory failure", [NSNumber numberWithBool:false], @"Empyema", [NSNumber numberWithBool:false], @"Prolonged air leak", [NSNumber numberWithBool:false], @"Pulmonary embolism", [NSNumber numberWithBool:false], @"Arrythmia", [NSNumber numberWithBool:false], @"Myocardial infarction", [NSNumber numberWithBool:false], @"Delirium", [NSNumber numberWithBool:false], @"Cerebral infarktion/bleeding", nil];
}

- (void)setComplicationsValue:(NSDictionary *)complications
{
    NSArray *sortedComplicationKeys = [[Operation emptyComplications].allKeys sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:nil ascending:YES]]];
    int toSet = 0;
    for(int i = 0 ; i < sortedComplicationKeys.count ; i++)
    {
        if( [[complications objectForKey:[sortedComplicationKeys objectAtIndex:i]] isEqualToNumber:[NSNumber numberWithBool:YES]] )
            toSet |= 1 << i;
        else
            toSet &= ~(1 << i);
    }
    self.complications = [NSNumber numberWithInt:toSet];
}

-(NSString *)simpleDateString:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    return [dateFormatter stringFromDate:date];
}

- (NSString *)dateString
{
    return [self simpleDateString:self.date];
}

- (NSString *)followUpDateString
{
    return [self simpleDateString:self.followUpDate];
}

- (NSString *)deathDateString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    return [dateFormatter stringFromDate:self.deathDate];
}

- (NSString *)resectionString
{
    return self.resection == nil ? nil : [[Operation possibleResections] objectAtIndex:self.resection.integerValue];
}

+ (NSArray *)possibleResections
{
    return [NSArray arrayWithObjects:@"Lobectomy", @"Segmentectomy", @"Pneumonectomy", @"Broncho- or Vasculo-plastic", @"Nonanatomical resection", nil];
}

- (void)setResectionValue:(NSString *)resection
{
    self.resection = [NSNumber numberWithInteger:[[Operation possibleResections] indexOfObject:resection]];
}

- (NSString *)approachString
{
    return self.approach == nil ? nil : [[Operation possibleApproaches] objectAtIndex:self.approach.integerValue];
}

+ (NSArray *)possibleApproaches
{
    return [NSArray arrayWithObjects:@"Minimally Invasive", @"Thoracotomy", nil];
}

- (void)setApproachValue:(NSString *)approach
{
    self.approach = [NSNumber numberWithInteger:[[Operation possibleApproaches] indexOfObject:approach]];
}

@end