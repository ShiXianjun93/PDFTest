//
//  LQView111.h
//  ESuperVisionProject
//
//  Created by liuqiang on 16/5/31.
//  Copyright © 2016年 dhyt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LQView111 : UIView

@property (nonatomic,assign) BOOL Have_path;

@property (nonatomic,assign) CGFloat lineWidth;

@property (nonatomic,strong) UIColor *lineColor;

@property(nonatomic,copy)CGFloat(^lineWidthBlock)();

@property (nonatomic, assign, readonly) CGFloat maxTop;
@property (nonatomic, assign, readonly) CGFloat maxBottom;
@property (nonatomic, assign, readonly) CGFloat maxLeft;
@property (nonatomic, assign, readonly) CGFloat maxRight;


-(void)clear;
-(void)back;
-(void)erase;
-(void)save;


/** 重置边界记录 */
- (void)resetRecordMark;

@end
