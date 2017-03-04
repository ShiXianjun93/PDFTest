//
//  NewMySignatureViewController.m
//  ESuperVisionProject
//
//  Created by liuqiang on 16/8/11.
//  Copyright © 2016年 dhyt. All rights reserved.
//

#import "NewMySignatureViewController.h"
#import "LQView111.h"
//颜色红定义
#define kUIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define kSpace (5)

#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define kScreenWidth [UIScreen mainScreen].bounds.size.width

@interface NewMySignatureViewController ()
/**
 *  上传
 */
- (IBAction)UpdateAction:(UIButton *)sender;
/**
 *  清楚
 */
- (IBAction)ClearAction:(UIButton *)sender;
/**
 *  画板
 */

@property (strong, nonatomic) IBOutlet LQView111 *SignBG;

@property (strong, nonatomic) IBOutlet UILabel *CutSignColor;
@property (strong, nonatomic) IBOutlet UILabel *SignColor1;
@property (strong, nonatomic) IBOutlet UILabel *SignColor2;
@property (strong, nonatomic) IBOutlet UILabel *SignColor3;
@property (strong, nonatomic) IBOutlet UILabel *SignColor4;

@property (strong, nonatomic) IBOutlet UISlider *lineWidthSlide;

- (IBAction)MySlider:(UISlider *)sender;

@end

@implementation NewMySignatureViewController
{
    UIColor *curretColor;
    UIButton *ClearBTN;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    curretColor = kUIColorFromRGB(0x191919);
   //    [self createNavigation];
    [self load_subView];
    self.SignBG.lineColor = curretColor;
    __weak typeof(self) weakself = self;
    self.SignBG.lineWidthBlock = ^CGFloat(){
        return  weakself.lineWidthSlide.value;
    };
    
    [self.SignBG resetRecordMark];
    
    
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    self.view.transform = CGAffineTransformMakeRotation(M_PI/2);
    self.view.bounds = CGRectMake(0, 0, kScreenHeight, kScreenWidth);
    [self.navigationController.navigationBar setHidden:YES];
    
    if (ClearBTN == nil) {
        ClearBTN = [UIButton buttonWithType:UIButtonTypeCustom];
        ClearBTN.transform = CGAffineTransformMakeRotation(M_PI/2);
        ClearBTN.frame = CGRectMake(28, kScreenHeight-68, 48, 47.5);
        [ClearBTN setImage:[UIImage imageNamed:@"My_ClearSign"] forState:UIControlStateNormal];
        [ClearBTN addTarget:self action:@selector(clearMethod) forControlEvents:UIControlEventTouchUpInside];
        UIWindow *VV = [UIApplication sharedApplication].keyWindow;
        [VV addSubview:ClearBTN];
    }

}
- (void)clearMethod{
    [self.SignBG clear];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self.navigationController.navigationBar setHidden:NO];
    [ClearBTN removeFromSuperview];
    ClearBTN = nil;
}

- (void)load_subView
{
    _SignColor1.backgroundColor =kUIColorFromRGB(0x2431d8);
    _SignColor2.backgroundColor =kUIColorFromRGB(0xff1d22);
    _SignColor3.backgroundColor =kUIColorFromRGB(0x7c7c7c);
    _SignColor4.backgroundColor =kUIColorFromRGB(0x191919);
    [_SignColor1 addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)]];
    [_SignColor2 addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)]];
    [_SignColor3 addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)]];
    [_SignColor4 addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)]];
}
- (void)tap:(UITapGestureRecognizer *)Tap{
    switch (Tap.view.tag - 100) {
        case 0:
        {
            curretColor = kUIColorFromRGB(0x2431d8);
            _CutSignColor.backgroundColor = curretColor;
            self.SignBG.lineColor = curretColor;
        }
            break;
        case 1:
        {
            curretColor = kUIColorFromRGB(0xff1d22);
            _CutSignColor.backgroundColor = curretColor;
            self.SignBG.lineColor = curretColor;
        }
            break;
        case 2:
        {
            curretColor = kUIColorFromRGB(0x7c7c7c);
            _CutSignColor.backgroundColor = curretColor;
            self.SignBG.lineColor = curretColor;
        }
            break;
        case 3:
        {
            curretColor = kUIColorFromRGB(0x191919);
            _CutSignColor.backgroundColor = curretColor;
            self.SignBG.lineColor = curretColor;
        }
            break;
        default:
            break;
    }
}

- (void)backClick
{
    [self.navigationController popViewControllerAnimated:YES];
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)BackAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)UpdateAction:(UIButton *)sender {
    
    if (!_SignBG.Have_path) {
        NSLog(@"请编辑签名");
        return;
    }
    
    UIImage *image = [self getImageWithView:self.SignBG];
    
    // 裁剪 书写签名区域 上下左右 留白 5px
    UIImage *cutImage = [UIImage imageWithCGImage:CGImageCreateWithImageInRect(image.CGImage, CGRectMake(self.SignBG.maxLeft - kSpace, self.SignBG.maxTop - kSpace, self.SignBG.maxRight - self.SignBG.maxLeft + 10, self.SignBG.maxBottom - self.SignBG.maxTop + 10))];
    
    // 比例处理 3:2
    UIImageView *modelView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 300, 200)];
    modelView.backgroundColor = [UIColor clearColor];
    modelView.contentMode = UIViewContentModeScaleAspectFit;
    modelView.image = cutImage;
    
    UIImage *resultImg = [self getImageWithView:modelView];
    
    if (self.isOnlyGetImage) {
        if (self.backSignatureImageView) {
            self.backSignatureImageView(resultImg, self);
        }
        
        return;
    }
    
    NSMutableArray *fileArr = @[].mutableCopy;
    NSDictionary *info = @{@"data":UIImagePNGRepresentation(resultImg),
                           @"name":@"file",
                           @"fileName":@"signatureImg.png",
                           @"type" : @"image/png"};
    [fileArr addObject:info];
    [self requestData:fileArr WithImage:image];
}

- (UIImage *)getImageWithView:(UIView *)view
{
    UIGraphicsBeginImageContext(view.bounds.size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:ctx];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)requestData:(NSMutableArray *)fileArr WithImage:(UIImage *)image
{
   
    
}
- (IBAction)ClearAction:(UIButton *)sender {
    [self.SignBG clear];
}
- (IBAction)MySlider:(UISlider *)sender {
    self.SignBG.lineWidth = sender.value;
}
@end
