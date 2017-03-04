//
//  UIButtonSuspension.m
//  PDFTest
//
//  Created by 石显军 on 16/8/10.
//  Copyright © 2016年 石显军. All rights reserved.
//

#import "UIButtonSuspension.h"
#import "UIViewExt.h"

#pragma mark - 签名按钮

/**
 *@ 按钮大小
 */
#define kBtnSignWidth (54)

/**
 *@ 上方吸引距离
 */
#define kSignTopSpace (100)

/**
 *@ 下方吸引距离
 */
#define kSignBottomSpace (100)

#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define kScreenWidth [UIScreen mainScreen].bounds.size.width

@implementation UIButtonSuspension

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        [self _initdata];
        
        [self _loadSubviews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        [self _initdata];
        
        [self _loadSubviews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame image:(UIImage *)image
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setBackgroundImage:image forState:UIControlStateNormal];
        
        [self _initdata];
        
        [self _loadSubviews];
        
    }
    return self;
}

#pragma mark - Setter
- (void)setAnimaHidden:(BOOL)animaHidden
{
    if (_animaHidden != animaHidden) {
        _animaHidden = animaHidden;
        
        __weak typeof(self) weakself = self;
        [UIView animateWithDuration:0.5 animations:^{
            weakself.alpha = !weakself.animaHidden;
        }];
    }
}

#pragma mark - Private
- (void)_initdata
{
    
}

- (void)_loadSubviews
{
    self.adjustsImageWhenHighlighted = NO;
    
    UIPanGestureRecognizer *signPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(signhandlePanGestures:)];
    signPanGestureRecognizer.minimumNumberOfTouches = 1;
    signPanGestureRecognizer.maximumNumberOfTouches = 1;
    [self addGestureRecognizer:signPanGestureRecognizer];
}

- (void)signhandlePanGestures:(UIPanGestureRecognizer *)recognizer
{
    if (recognizer.state != UIGestureRecognizerStateEnded && recognizer.state != UIGestureRecognizerStateFailed) {
        CGPoint location = [recognizer locationInView:self.superview];
        self.center = CGPointMake(location.x, location.y);
        
    }
    if (recognizer.state == UIGestureRecognizerStateEnded && recognizer.state != UIGestureRecognizerStateFailed)
    {
        __weak typeof(self) weakself = self;
        
        [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.4 initialSpringVelocity:0.4 options:UIViewAnimationOptionAllowAnimatedContent animations:^{
            
            CGPoint menuCenter = weakself.center;
            if (menuCenter.y <= kSignTopSpace) {
                weakself.top_ext = 52;
                
                if (weakself.left_ext < 8) {
                    weakself.left_ext = 8;
                }
                
                if (weakself.right_ext > kScreenWidth - 8) {
                    weakself.right_ext = kScreenWidth - 8;
                }
                
            }else if (menuCenter.y >= (kScreenHeight - kSignBottomSpace)){
                weakself.bottom_ext = kScreenHeight - 52;
                
                if (weakself.left_ext < 8) {
                    weakself.left_ext = 8;
                }
                
                if (weakself.right_ext > kScreenWidth - 8) {
                    weakself.right_ext = kScreenWidth - 8;
                }
                
            }else if (menuCenter.x < kScreenWidth/2.f){
                weakself.left_ext = 8;
            }else if (menuCenter.x >= kScreenWidth/2.f){
                weakself.right_ext = kScreenWidth - 8;
            }
            
        } completion:nil];
        
    }
}

@end
