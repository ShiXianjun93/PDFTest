//
//  UIControllerPDFOpinionEdit.m
//  ESuperVisionProject
//
//  Created by 石显军 on 16/8/12.
//  Copyright © 2016年 dhyt. All rights reserved.
//

#import "UIControllerPDFOpinionEdit.h"

@interface UIControllerPDFOpinionEdit ()

@property (strong, nonatomic) IBOutlet UITextView *textView;

@end

@implementation UIControllerPDFOpinionEdit

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _initdata];
    
    [self _loadSubviews];
    
    [self _loadNavItems];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.textView becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.textView resignFirstResponder];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Private
- (void)_initdata
{
    self.title = @"编辑意见";
}

- (void)_loadSubviews
{
    [self.textView becomeFirstResponder];
}

- (void)_loadNavItems
{
    UIButton *btnCancel = [UIButton buttonWithType:UIButtonTypeCustom];
    btnCancel.frame = CGRectMake(0, 0, 31, 40);
    [btnCancel setTitle:@"取消" forState:UIControlStateNormal];
    [btnCancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnCancel.titleLabel.font = [UIFont systemFontOfSize:15];
    btnCancel.adjustsImageWhenHighlighted = NO;
    [btnCancel addTarget:self action:@selector(chickCancelItem) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithCustomView:btnCancel];
    self.navigationItem.leftBarButtonItem = cancelItem;
    
    UIButton *btnDone = [UIButton buttonWithType:UIButtonTypeCustom];
    btnDone.frame = CGRectMake(0, 0, 31, 40);
    [btnDone setTitle:@"完成" forState:UIControlStateNormal];
    [btnDone setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnDone.titleLabel.font = [UIFont systemFontOfSize:15];
    btnDone.adjustsImageWhenHighlighted = NO;
    [btnDone addTarget:self action:@selector(chickDoneItem) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithCustomView:btnDone];
    self.navigationItem.rightBarButtonItem = doneItem;
}

#pragma mark - Action
- (void)chickCancelItem
{    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)chickDoneItem
{
    if (self.textView.text.length == 0) {
        
        NSLog(@"请输入意见内容");
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(controllerPDFOpinionEdit:didEditDoneWithOpinion:)]) {
        [self.delegate controllerPDFOpinionEdit:self didEditDoneWithOpinion:self.textView.text];
    }
}

@end
