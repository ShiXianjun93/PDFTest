//
//  UIButtonSuspension.h
//  PDFTest
//
//  Created by 石显军 on 16/8/10.
//  Copyright © 2016年 石显军. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButtonSuspension : UIButton

/** 设置按钮 hidden 带有动画 */
@property (nonatomic, assign) BOOL animaHidden;

/** 初始化 */
- (instancetype)initWithFrame:(CGRect)frame image:(UIImage *)image;

@end
