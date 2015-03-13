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

-(NSDictionary *)serialize
{
	return [NSDictionary dictionaryWithObjectsAndKeys:@"date", self.date, @"approach", self.approachString, @"resection", self.resectionsArray, @"duration", self.duration, @"bloodLoss", self.bloodLoss, @"admittedToICU", self.admittedToICU, @"durationOfStay", self.durationOfStay, @"followUpDate", self.followUpDate, @"complications", self.complicationsArray, @"death", [NSNumber numberWithBool:!self.alive.boolValue], @"deathDate", self.deathDate, nil];
}

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

- (NSMutableDictionary *)complicationsDictionary
{
    NSArray *sortedComplicationKeys = [[Operation emptyComplications].allKeys sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:nil ascending:YES]]];
	int complications = self.complications == nil ? 0 : self.complications.intValue;
	return [Operation bitFieldToDictionary:complications withSortedKeys:sortedComplicationKeys];
}

+ (NSMutableDictionary *)emptyComplications
{
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:false], @"Pneumonia", [NSNumber numberWithBool:false], @"Respiratory failure", [NSNumber numberWithBool:false], @"Empyema", [NSNumber numberWithBool:false], @"Prolonged air leak", [NSNumber numberWithBool:false], @"Pulmonary embolism", [NSNumber numberWithBool:false], @"Arrythmia", [NSNumber numberWithBool:false], @"Myocardial infarction", [NSNumber numberWithBool:false], @"Delirium", [NSNumber numberWithBool:false], @"Cerebral infarktion/bleeding", nil];
}

- (void)setComplicationsValue:(NSDictionary *)complications
{
    self.complications = [NSNumber numberWithInt:[Operation dictionaryToBitField:complications withSortedKeys:[[Operation emptyComplications].allKeys sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:nil ascending:YES]]]]];
}

+ (NSMutableDictionary *)emptyResections
{
	return [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:false], @"Lobectomy", [NSNumber numberWithBool:false], @"Segmentectomy", [NSNumber numberWithBool:false], @"Pneumonectomy", [NSNumber numberWithBool:false], @"Broncho- or Vasculo-plastic", [NSNumber numberWithBool:false], @"Nonanatomical resection", nil];
}

- (void)setResectionsValue:(NSDictionary *)resections
{
	self.resection = [NSNumber numberWithInt:[Operation dictionaryToBitField:resections withSortedKeys:[[[Operation emptyResections] allKeys] sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:nil ascending:YES]]]]];
}

+ (NSMutableDictionary *)bitFieldToDictionary:(int)field withSortedKeys:(NSArray *)sortedKeys
{
	NSMutableDictionary *toReturn = [NSMutableDictionary dictionary];
	for(int i = 0 ; i < sortedKeys.count ; i++)
		[toReturn setObject:[NSNumber numberWithBool:field & 1 << i] forKey:[sortedKeys objectAtIndex:i]];
	return toReturn;
}

- (NSMutableDictionary *)resectionsDictionary
{
	NSArray *sortedPossibleResections = [[[Operation emptyResections] allKeys] sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:nil ascending:YES]]];
	int resections = self.resection == nil ? 0 : self.resection.intValue;
	return [Operation bitFieldToDictionary:resections withSortedKeys:sortedPossibleResections];
}

+ (int)dictionaryToBitField:(NSDictionary *)dictionary withSortedKeys:(NSArray *)sortedKeys
{
	int toSet = 0;
	for(int index = 0 ; index < sortedKeys.count ; index++)
		if([[dictionary objectForKey:[sortedKeys objectAtIndex:index]] isEqualToNumber:[NSNumber numberWithBool:YES]])
			toSet |= 1 << index;
	return toSet;
}

- (NSArray *)resectionsArray
{
	return [Operation trueKeys:self.resectionsDictionary];
}

+ (NSArray *)trueKeys:(NSDictionary *)dictionary
{
	NSMutableArray *toReturn = [NSMutableArray array];
	for( NSString * key in dictionary )
		if( [[dictionary objectForKey:key] isEqualToNumber:[NSNumber numberWithBool:true]] )
			[toReturn addObject:key];
	return toReturn;
}

- (NSArray *)complicationsArray
{
	return [Operation trueKeys:self.complicationsDictionary];
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
	if([[Operation possibleApproaches] containsObject:approach])
		self.approach = [NSNumber numberWithInteger:[[Operation possibleApproaches] indexOfObject:approach]];
	else
		self.approach = nil;
}

@end