//
//  RCTAppleHealthKit+Methods_Activity.m
//  RCTAppleHealthKit
//
//  Created by Alexander Vallorosi on 4/27/17.
//  Copyright © 2017 Alexander Vallorosi. All rights reserved.
//

#import "RCTAppleHealthKit+Methods_Activity.h"
#import "RCTAppleHealthKit+Queries.h"
#import "RCTAppleHealthKit+Utils.h"

@implementation RCTAppleHealthKit (Methods_Activity)

- (void)activity_getActivitySummary:(NSDictionary *)input callback:(RCTResponseSenderBlock)callback
{
  // Create the date components for the predicate
  NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
  NSDate *endDate = [NSDate date];
  NSDate *startDate = [NSDate date];
  NSCalendarUnit unit = NSCalendarUnitDay;

  NSDateComponents *startDateComponents = [calendar components:unit fromDate:startDate];
  startDateComponents.calendar = calendar;

  NSDateComponents *endDateComponents = [calendar components:unit fromDate:endDate];
  endDateComponents.calendar = calendar;

  // Create the predicate for the query
  NSPredicate *summariesWithinRange =
  [HKQuery predicateForActivitySummariesBetweenStartDateComponents:startDateComponents endDateComponents:endDateComponents];

  // Build the query
  HKActivitySummaryQuery *query = [[HKActivitySummaryQuery alloc] initWithPredicate:summariesWithinRange resultsHandler:^(HKActivitySummaryQuery * _Nonnull query, NSArray<HKActivitySummary *> * _Nullable activitySummaries, NSError * _Nullable error) {

      if (activitySummaries == nil) {
        callback(@[RCTMakeError(@"error getting activity summary", nil, nil)]);
        return;
      }

      HKUnit *energyUnit   = HKUnit.calorieUnit;
      HKUnit *standUnit    = HKUnit.countUnit;
      HKUnit *exerciseUnit = HKUnit.secondUnit;

      HKQuantity *quantity = activitySummaries.lastObject.appleStandHours;
      double appleStandHours = [quantity doubleValueForUnit:standUnit];

      HKQuantity *quantity2 = activitySummaries.lastObject.appleStandHoursGoal;
      double appleStandHoursGoal = [quantity2 doubleValueForUnit:standUnit];

      HKQuantity *quantity3 = activitySummaries.lastObject.activeEnergyBurned;
      double activeEnergyBurned = [quantity3 doubleValueForUnit:energyUnit];

      HKQuantity *quantity4 = activitySummaries.lastObject.activeEnergyBurnedGoal;
      double activeEnergyBurnedGoal = [quantity4 doubleValueForUnit:energyUnit];

      HKQuantity *quantity5 = activitySummaries.lastObject.appleExerciseTime;
      double appleExerciseTime = [quantity5 doubleValueForUnit:exerciseUnit];

      HKQuantity *quantity6 = activitySummaries.lastObject.appleExerciseTimeGoal;
      double appleExerciseTimeGoal = [quantity6 doubleValueForUnit:exerciseUnit];

      NSDictionary *results = @{
                                 @"appleStandHours": @(appleStandHours),
                                 @"appleStandHoursGoal": @(appleStandHoursGoal),
                                 @"activeEnergyBurned": @(activeEnergyBurned),
                                 @"activeEnergyBurnedGoal": @(activeEnergyBurnedGoal),
                                 @"appleExerciseTime": @(appleExerciseTime),
                                 @"appleExerciseTimeGoal": @(appleExerciseTimeGoal)
                                 };

      callback(@[[NSNull null], results]);
  }];

  // Run the query
  [self.healthStore executeQuery:query];
}

- (void)activity_getActiveEnergyBurned:(NSDictionary *)input callback:(RCTResponseSenderBlock)callback
{
    HKQuantityType *activeEnergyType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
    NSDate *startDate = [RCTAppleHealthKit dateFromOptions:input key:@"startDate" withDefault:nil];
    NSDate *endDate = [RCTAppleHealthKit dateFromOptions:input key:@"endDate" withDefault:[NSDate date]];
    HKUnit *cal = [HKUnit kilocalorieUnit];

    if(startDate == nil){
        callback(@[RCTMakeError(@"startDate is required in options", nil, nil)]);
        return;
    }
    NSPredicate * predicate = [RCTAppleHealthKit predicateForSamplesBetweenDates:startDate endDate:endDate];

    [self fetchQuantitySamplesOfType:activeEnergyType
                                unit:cal
                           predicate:predicate
                           ascending:false
                               limit:HKObjectQueryNoLimit
                          completion:^(NSArray *results, NSError *error) {
                              if(results){
                                  callback(@[[NSNull null], results]);
                                  return;
                              } else {
                                  NSLog(@"error getting active energy burned samples: %@", error);
                                  callback(@[RCTMakeError(@"error getting active energy burned samples", nil, nil)]);
                                  return;
                              }
                          }];
}

@end
