//
//  UIControllerPDFOpinionEdit.h
//  ESuperVisionProject
//
//  Created by 石显军 on 16/8/12.
//  Copyright © 2016年 dhyt. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UIControllerPDFOpinionEdit;

@protocol UIControllerPDFOpinionEditDelegate <NSObject>

@optional
/**
 *@ 已经编辑完 意见
 */
- (void)controllerPDFOpinionEdit:(UIControllerPDFOpinionEdit *)controller didEditDoneWithOpinion:(NSString *)opinion;

@end

@interface UIControllerPDFOpinionEdit : UIViewController

/** 代理 */
@property (nonatomic, weak) id<UIControllerPDFOpinionEditDelegate> delegate;

@end
