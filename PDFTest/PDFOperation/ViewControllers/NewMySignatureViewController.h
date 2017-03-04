//
//  NewMySignatureViewController.h
//  ESuperVisionProject
//
//  Created by liuqiang on 16/8/11.
//  Copyright © 2016年 dhyt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewMySignatureViewController : UIViewController
@property (nonatomic,copy) void (^backSignatureImageView)(UIImage * ,NewMySignatureViewController *);


@property (nonatomic,assign) BOOL isOnlyGetImage;
@end
