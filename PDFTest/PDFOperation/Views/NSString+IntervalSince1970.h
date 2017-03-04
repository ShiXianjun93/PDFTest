//
//  NSString+IntervalSince1970.h
//  YunTuProject
//
//  Created by 石显军 on 15/4/13.
//  Copyright (c) 2015年 qyh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (IntervalSince1970)

/*
 *@ 时间戳 转换 时间字符串
 *@ Parameter - "format" 转换时间的格式
 *@ Return 根据时间格式 生成 格式化字符串
 */
- (NSString *)getTimeWithDateFormat:(NSString *)format;

/*
 *@ 转换成年月日
 *@ return 返回年月日 @"2015年04月13日"
 */
- (NSString *)getYearMonthDayTime;

/*
 *@ 转换成年月日时分
 *@ return 返回年月日 @"2015/04/13日 14:22"
 */
- (NSString *)getYearMonthDayHourMTime;


/*
 *@ 转换成年月日时分
 *@ return 返回年月日 @"2015:04:13日 14:22"
 */
- (NSString *)getYearMonthDayHourMTime1;;

@end
