//
//  UIImageViewSign.h
//  PDFTest
//
//  Created by 石显军 on 16/8/10.
//  Copyright © 2016年 石显军. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UIImageViewSign;

@protocol UIImageViewSignDelegate <NSObject>

/** 点击 编辑图片删除按钮 */
- (void)didchickDeleteImageViewSign:(UIImageViewSign *)view;

@end

@interface UIImageViewSign : UIImageView


/**
 *@ 使用这个方法初始化  其他方法没有处理
 *@ image   显示的图片 签名图片、意见图片、时间图片 等等
 *@ width   view的宽度 高度根据图片进行计算 以保证图片不会变形
 *@ origin  view的坐标
 *@ show    是否显示 删除按钮
 */

- (instancetype)initWithImage:(UIImage *)image width:(CGFloat)width origin:(CGPoint)origin showDeleteBtn:(BOOL)show;


/** 代理 */
@property (nonatomic, weak) id<UIImageViewSignDelegate> delegate;

@end
