//
//  UIImageViewSign.m
//  PDFTest
//
//  Created by 石显军 on 16/8/10.
//  Copyright © 2016年 石显军. All rights reserved.
//

#import "UIImageViewSign.h"
#import "UIViewExt.h"

#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define kScreenWidth [UIScreen mainScreen].bounds.size.width

#define kMinWidth (100)

@interface UIImageViewSign ()
{
    CGFloat _imageWidth;
    
    CGFloat _imageHeight;
    
    /** 刚刚点击时手指的位置 */
    CGPoint _beginPoint;
}

/** 删除按钮 */
@property (nonatomic, strong) UIButton *btnDele;

/** 调整大小按钮 */
@property (nonatomic, strong) UIImageView *changeSizeView;

@end

@implementation UIImageViewSign

- (instancetype)initWithImage:(UIImage *)image width:(CGFloat)width origin:(CGPoint)origin showDeleteBtn:(BOOL)show
{
    assert(image != nil); // image 不可以为空
    
    self = [super initWithImage:image];
    if (self) {
        
        self.frame = CGRectMake(origin.x, origin.y, width, [self getHeightForWidth:width]);
        
        [self _initdata];
        
        [self _loadSubviewsAndShowBtnDelete:show];
    }
    
    return self;
}

#pragma mark - Getter
- (UIButton *)btnDele
{
    if (_btnDele == nil) {
        _btnDele = [UIButton buttonWithType:UIButtonTypeCustom];
        [_btnDele setImage:[UIImage imageNamed:@"btn_Dele"] forState:UIControlStateNormal];
        _btnDele.frame = CGRectMake(self.width_ext - 30, 0, 30, 30);
        [_btnDele addTarget:self action:@selector(chickDeleItem) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _btnDele;
}

- (UIImageView *)changeSizeView
{
    if (_changeSizeView == nil) {
        _changeSizeView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"btn_ChangeSize"]];
        _changeSizeView.contentMode = UIViewContentModeCenter;
        _changeSizeView.frame = CGRectMake(self.width_ext - 30, self.height_ext - 30, 30, 30);
        _changeSizeView.userInteractionEnabled = YES;
        UIPanGestureRecognizer *signPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(signhandleChangeSizePanGestures:)];
        signPanGestureRecognizer.minimumNumberOfTouches = 1;
        signPanGestureRecognizer.maximumNumberOfTouches = 1;
        [_changeSizeView addGestureRecognizer:signPanGestureRecognizer];
    }
    return _changeSizeView;
}

#pragma mark - Private
- (void)_initdata
{
    self.userInteractionEnabled = YES;
}

- (void)_loadSubviewsAndShowBtnDelete:(BOOL)showBtnDelete
{
    self.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.layer.borderWidth = 0.5;
    
    _imageWidth = self.image.size.width;
    _imageHeight = self.image.size.height;
    
    if (showBtnDelete) [self addSubview:self.btnDele];
    
    [self addSubview:self.changeSizeView];
    
    UIPanGestureRecognizer *signPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(signhandlePanGestures:)];
    signPanGestureRecognizer.minimumNumberOfTouches = 1;
    signPanGestureRecognizer.maximumNumberOfTouches = 1;
    [self addGestureRecognizer:signPanGestureRecognizer];
}


/** 根据宽度和图片大小计算 高度*/
- (CGFloat)getHeightForWidth:(CGFloat)width
{
    return (width / (self.image.size.width / self.image.size.height));
}

/** 根据宽度和图片大小计算 高度*/
- (CGFloat)getWidthForHeight:(CGFloat)height
{
    return (height / (self.image.size.height / self.image.size.width));
}

#pragma mark - Action
- (void)chickDeleItem
{
    if ([self.delegate respondsToSelector:@selector(didchickDeleteImageViewSign:)]) {
        [self.delegate didchickDeleteImageViewSign:self];
    }
}

- (void)signhandlePanGestures:(UIPanGestureRecognizer *)recognizer
{
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
        {
            _beginPoint = [recognizer locationInView:self];
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGPoint location = [recognizer locationInView:self.superview];
            self.center = CGPointMake(location.x - (_beginPoint.x - self.width_ext/2.f), location.y - (_beginPoint.y - self.height_ext/2.f));
            
            if (self.left_ext < 0) {
                self.left_ext = 0;
            }
            
            if (self.top_ext < 0) {
                self.top_ext = 0;
            }
            
            if (self.right_ext > kScreenWidth) {
                self.right_ext = kScreenWidth;
            }
            
            if (self.bottom_ext > kScreenHeight) {
                self.bottom_ext = kScreenHeight;
            }
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
        
        }
            break;
        default:
            break;
    }
}

- (void)signhandleChangeSizePanGestures:(UIPanGestureRecognizer *)recognizer
{
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
        {
            _beginPoint = self.frame.origin;
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGPoint location = [recognizer locationInView:self.superview];
            if (location.x < _beginPoint.x || location.y < _beginPoint.y) {
                return;
            }
            
            CGFloat width = location.x - _beginPoint.x;
            
            if (width < kMinWidth) {
                return;
            }
            
            CGFloat height = location.y - _beginPoint.y;
            if (height < [self getHeightForWidth:kMinWidth]) {
                return;
            }
            
            if (width / self.image.size.width > height / self.image.size.height) {
                
                if (width > kScreenWidth || [self getHeightForWidth:width] > kScreenHeight) {
                    return;
                }
                
                self.width_ext = width;
                self.height_ext = [self getHeightForWidth:width];
                
            }else{
                
                if (height > kScreenHeight || [self getWidthForHeight:height] > kScreenWidth) {
                    return;
                }
                
                self.height_ext = height;
                self.width_ext = [self getWidthForHeight:height];
            }
            
            self.btnDele.right_ext = self.width_ext;
            self.changeSizeView.right_ext = self.width_ext;
            self.changeSizeView.bottom_ext = self.height_ext;
            
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            
        }
            break;
        default:
            break;
    }
}


@end
