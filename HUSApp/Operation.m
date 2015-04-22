/**
	Operation.m
 
	A subclass of NSManagedObject that provides an object-oriented representation of an Operation entity stored in Core Data. 
	This class also contains many convenience methods for getting and setting properties of Operation in a simple manner.
 */

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
@dynamic dlco;
@dynamic duration;
@dynamic fev1;
@dynamic followUpDate;
@dynamic resection;
@dynamic patient;
@dynamic durationOfStay;

/*	description is implemented to be used for debug output */
- (NSString *)description
{
	return [NSString stringWithFormat:@"Operation on %@ for %@", self.dateString, self.patient];
}

/*	durationString returns a string representation of the duration of an operation formatted as (X hours and Y minutes). */
- (NSString *)durationString
{
    int minutes = self.duration.intValue;
    if( minutes > 60 )
    {
		//	handle special cases: 1. plural and singular form of "hour" and 2. 0 minutes
        return minutes % 60 == 0 ? [NSString stringWithFormat:@"%d hour%c", minutes / 60, minutes < 120 ? '\0' : 's'] : [NSString stringWithFormat:@"%d hour%c and %d minutes", minutes / 60,  minutes < 120 ? '\0' : 's', minutes % 60];
    }
    else
        return [NSString stringWithFormat:@"%d minutes", minutes];
}

/*	simpleDateString is a helper method that takes a Date object and returns a string representation formatted as (month day, year).  */
-(NSString *)simpleDateString:(NSDate *)date
{
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle:NSDateFormatterLongStyle];
	[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
	return [dateFormatter stringFromDate:date];
}

/*	simpleDateString returns a string representation of the date of an operation formatted as (month day, year). */
- (NSString *)dateString
{
	return [self simpleDateString:self.date];
}

/*	simpleDateString returns a string representation of the follow up of an operation formatted as (month day, year). */
- (NSString *)followUpDateString
{
	return [self simpleDateString:self.followUpDate];
}

/*	deathDateString returns a string representation of the death date of the patient for an operation formatted as (month day, year at hh:mm am/pm). */
- (NSString *)deathDateString
{
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle:NSDateFormatterLongStyle];
	[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
	return [dateFormatter stringFromDate:self.deathDate];
}

/*	Methods related to "complications"
 
	An Operation can have zero or more complications. Complications are stored as a bitmask, but is exposed externally as a string-boolean dictionary.
	Complications that arose are set as "true" while the rest are "false".  */

/*	complicationsArray property getter: returns an array containing only the complications that are set (keys that map to "true") */
- (NSArray *)complicationsArray
{
	return [Operation trueKeys:self.complicationsDictionary];
}

/*	complicationsDictionary returns a dictionary representation of the internally stored complications bitfield */
- (NSMutableDictionary *)complicationsDictionary
{
	//	retrieve an array of possible keys for a complications dictionary (all possible complications) sorted alphabetically
    NSArray *sortedComplicationKeys = [[Operation emptyComplications].allKeys sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:nil ascending:YES]]];
	
	//	retrieve stored bitfield
	int complications = self.complications == nil ? 0 : self.complications.intValue;
	
	return [Operation bitFieldToDictionary:complications withSortedKeys:sortedComplicationKeys];
}

/*	setComplicationsValue sets the internally stored bitfield according to a dictionary passed as a parameter */
- (void)setComplicationsValue:(NSDictionary *)complications
{
	self.complications = [NSNumber numberWithInt:[Operation dictionaryToBitField:complications withSortedKeys:[[Operation emptyComplications].allKeys sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:nil ascending:YES]]]]];
}

/*	emptyComplications is a **class method** returns an "empty" complications dictionary (all keys set to "false"). */
+ (NSMutableDictionary *)emptyComplications
{
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:false], @"Pneumonia", [NSNumber numberWithBool:false], @"Respiratory Failure", [NSNumber numberWithBool:false], @"Empyema", [NSNumber numberWithBool:false], @"Prolonged Air Leak", [NSNumber numberWithBool:false], @"Pulmonary Embolism", [NSNumber numberWithBool:false], @"Arrythmia", [NSNumber numberWithBool:false], @"Myocardial Infarction", [NSNumber numberWithBool:false], @"Delirium", [NSNumber numberWithBool:false], @"Cerebral Infarktion/Bleeding", nil];
}

/*	Methods related to "resections"
 
	An Operation can be one or more resection types. Resections are stored as a bitmask, but is exposed externally as a string-boolean dictionary.
	Resections that apply to an Operation arose are set as "true" while the rest are "false".  */

/*	resectionsArray returns an array containing only the resections that apply (keys that map to "true") */
- (NSArray *)resectionsArray
{
	return [Operation trueKeys:self.resectionsDictionary];
}

/*	resectionsDictionary returns a dictionary representation of the internally stored resection bitfield */
- (NSMutableDictionary *)resectionsDictionary
{
	//	retrieve an array of possible keys for a resections dictionary (all possible resections) sorted alphabetically
    NSArray *sortedPossibleResections = [[[Operation emptyResections] allKeys] sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:nil ascending:YES]]];
	
	//	retrieve stored bitfield
    int resections = self.resection == nil ? 0 : self.resection.intValue;
	
    return [Operation bitFieldToDictionary:resections withSortedKeys:sortedPossibleResections];
}

/*	setResectionsValue sets the internally stored bitfield according to a dictionary passed as a parameter */
- (void)setResectionsValue:(NSDictionary *)resections
{
	self.resection = [NSNumber numberWithInt:[Operation dictionaryToBitField:resections withSortedKeys:[[[Operation emptyResections] allKeys] sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:nil ascending:YES]]]]];
}

/*	emptyResections is a **class method** returns an "empty" resections dictionary (all keys set to "false"). */
+ (NSMutableDictionary *)emptyResections
{
	return [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:false], @"Lobectomy", [NSNumber numberWithBool:false], @"Segmentectomy", [NSNumber numberWithBool:false], @"Pneumonectomy", [NSNumber numberWithBool:false], @"Broncho- or Vasculo-plastic", [NSNumber numberWithBool:false], @"Nonanatomical resection", nil];
}

/*	Methods related to "approach"
 
	An Operation can be only one of two possible approaches. Approach is stored as an integer index, but is exposed externally as a string.  */

/*	approachString returns a string representation of the internally stored approach integer */
- (NSString *)approachString
{
	return self.approach == nil ? nil : [[Operation possibleApproaches] objectAtIndex:self.approach.integerValue];
}

/*	approachString sets the internally stored integer according to a string passed as parameter */
- (void)setApproachValue:(NSString *)approach
{
	if([[Operation possibleApproaches] containsObject:approach])
		self.approach = [NSNumber numberWithInteger:[[Operation possibleApproaches] indexOfObject:approach]];
	else
		self.approach = nil;
}

/*	possibleApproaches is a **class method** that returns an array containing all approach options. */
+ (NSArray *)possibleApproaches
{
    return [NSArray arrayWithObjects:@"Minimally Invasive", @"Thoracotomy", nil];
}

/*	Helper methods */

/*	bitFieldToDictionary:withSortedKeys: is a **class method** that takes two parameters:
	a bitfield and an array of keys (must be sorted for accurate storage and retrieval).
	It then "parses" the bitfield into a string to boolean dictionary, referencing the order of the keys in the array. */
+ (NSMutableDictionary *)bitFieldToDictionary:(int)field withSortedKeys:(NSArray *)sortedKeys
{
	NSMutableDictionary *toReturn = [NSMutableDictionary dictionary];
	for(int i = 0 ; i < sortedKeys.count ; i++)
		[toReturn setObject:[NSNumber numberWithBool:field & 1 << i] forKey:[sortedKeys objectAtIndex:i]];
	return toReturn;
}

/*	bitFieldToDictionary:withSortedKeys: is a **class method** that takes two parameters:
	a dictionary and an array of keys (must be sorted for accurate storage and retrieval).
	It then returns a bitfield representation of the string to boolean dictionary, referencing the order of the keys in the array. */
+ (int)dictionaryToBitField:(NSDictionary *)dictionary withSortedKeys:(NSArray *)sortedKeys
{
	int toSet = 0;
	for(int index = 0 ; index < sortedKeys.count ; index++)
		if([[dictionary objectForKey:[sortedKeys objectAtIndex:index]] isEqualToNumber:[NSNumber numberWithBool:YES]])
			toSet |= 1 << index;
	return toSet;
}

/*	trueKeys is a simple **class method** that takes a dictionary that maps to boolean, and returns an
	array containing the keys that map to "true". */
+ (NSArray *)trueKeys:(NSDictionary *)dictionary
{
	NSMutableArray *toReturn = [NSMutableArray array];
	for( NSString * key in dictionary )
		if( [[dictionary objectForKey:key] isEqualToNumber:[NSNumber numberWithBool:true]] )
			[toReturn addObject:key];
	return toReturn;
}

@end
