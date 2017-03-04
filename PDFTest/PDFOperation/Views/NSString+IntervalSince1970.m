//
//  NSString+IntervalSince1970.m
//  YunTuProject
//
//  Created by 石显军 on 15/4/13.
//  Copyright (c) 2015年 qyh. All rights reserved.
//

#import "NSString+IntervalSince1970.h"

@implementation NSString (IntervalSince1970)

- (NSString *)getTimeWithDateFormat:(NSString *)format
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[self integerValue]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    return [dateFormatter stringFromDate:date];
}


- (NSString *)getYearMonthDayTime
{
    return [self getTimeWithDateFormat:@"yyyy年MM月dd日"];
}

- (NSString *)getYearMonthDayHourMTime
{
    return [self getTimeWithDateFormat:@"yyyy/MM/dd HH:mm"];
}

- (NSString *)getYearMonthDayHourMTime1
{
    return [self getTimeWithDateFormat:@"yyyy:MM:dd HH:mm"];
}
@end
