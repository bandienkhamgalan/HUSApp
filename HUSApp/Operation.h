//
//  Operation.h
//  app development project
//
//  Created by Bandi Enkh-Amgalan on 2/11/15.
//  Copyright (c) 2015 a. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Patient;

@interface Operation : NSManagedObject

@property (nonatomic, retain) NSNumber * admittedToICU;
@property (nonatomic, retain) NSNumber * alive;
@property (nonatomic, retain) NSNumber * approach;
@property (nonatomic, retain) NSNumber * bloodLoss;
@property (nonatomic, retain) NSNumber * complications;
@property (nonatomic, retain) NSNumber * durationOfStay;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSDate * deathDate;
@property (nonatomic, retain) NSNumber * duration;
@property (nonatomic, retain) NSDate * followUpDate;
@property (nonatomic, retain) NSNumber * resection;
@property (nonatomic, retain) Patient *patient;

- (NSArray *)complicationsArray;
- (NSMutableDictionary *)complicationsDictionary;
+ (NSMutableDictionary *)emptyComplications;
- (void)setComplicationsValue:(NSDictionary *)complications;

+ (NSArray *)trueKeys;
+ (NSMutableDictionary *)bitFieldToDictionary:(int)field withSortedKeys:(NSArray *)sortedKeys;
- (NSArray *)resectionsArray;
- (NSMutableDictionary *)resectionsDictionary;
+ (NSMutableDictionary *)emptyResections;
- (void)setResectionsValue:(NSDictionary *)resections;
+ (int)dictionaryToBitField:(NSDictionary *)keys withSortedKeys:(NSArray *)sortedKeys;
- (NSString *)approachString;
+ (NSArray *)possibleApproaches;
- (void)setApproachValue:(NSString *)approach;
- (NSString *)dateString;
-(NSString *)simpleDateString:(NSDate *)date;
- (NSString *)durationString;
- (NSString *)followUpDateString;
- (NSString *)deathDateString;
- (NSDictionary *)serialize;


@end
