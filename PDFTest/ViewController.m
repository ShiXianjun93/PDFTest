//
//  ViewController.m
//  PDFTest
//
//  Created by 石显军 on 2017/3/4.
//  Copyright © 2017年 石显军. All rights reserved.
//

#import "ViewController.h"
#import "ReaderViewController.h"
#import "ModelFile.h"

@interface ViewController ()<ReaderViewControllerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadPDF];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self loadPDF];
}

- (void)loadPDF
{
    NSArray *pdfs = [[NSBundle mainBundle] pathsForResourcesOfType:@"pdf" inDirectory:nil];
    NSString *filePath = [pdfs firstObject]; assert(filePath != nil);
    
    // 基本数据  无关紧要
    ModelFile *file = [[ModelFile alloc] init];
    file.name = @"PDF 测试文件";
    file.notice_mime_id = @"1";
    [self openPDFWithModel:file filePath:filePath];
}

#pragma mark - 打开PDF文件
- (void)openPDFWithModel:(ModelFile *)file filePath:(NSString *)filePath
{
    ReaderDocument *document = [ReaderDocument withDocumentFilePath:filePath password:nil];
    
    if (document != nil) // Must have a valid ReaderDocument object in order to proceed with things
    {
        ReaderViewController *readerViewController = [[ReaderViewController alloc] initWithReaderDocument:document fileName:file.name canEdit:YES fileID:file.notice_mime_id showPage:1];
        [readerViewController destructionNewPdfFile];
        readerViewController.delegate = self; // Set the ReaderViewController delegate to self
        
        readerViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        readerViewController.modalPresentationStyle = UIModalPresentationFullScreen;
        
        [self presentViewController:readerViewController animated:YES completion:NULL];
    }
    else // Log an error so that we know that something went wrong
    {
        NSLog(@"PDF文件打开失败");
    }
}

#pragma mark - ReaderViewControllerDelegate

- (void)dismissReaderViewController:(ReaderViewController *)viewController
{
    [viewController dismissViewControllerAnimated:YES completion:nil];
    
    [viewController destructionNewPdfFile];
}

/** 已经生成一个新的文件 */
- (void)readerViewController:(ReaderViewController *)viewController didCreateNewPdfWithPath:(NSString *)pdfPath fileName:(NSString *)fileName fileID:(NSString *)fileID currPage:(NSInteger)currPage
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [viewController dismissViewControllerAnimated:NO completion:nil];
    });

    ReaderDocument *document = [ReaderDocument withDocumentFilePath:pdfPath password:@""];
    
    if (document != nil) // Must have a valid ReaderDocument object in order to proceed with things
    {
        
        ReaderViewController *readerViewController = [[ReaderViewController alloc] initWithReaderDocument:document fileName:fileName canEdit:YES fileID:fileID showPage:currPage];
        
        readerViewController.delegate = self; // Set the ReaderViewController delegate to self
        
        readerViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        readerViewController.modalPresentationStyle = UIModalPresentationFullScreen;
        
        [self presentViewController:readerViewController animated:NO completion:NULL];
    }
    
    else // Log an error so that we know that something went wrong
    {
        
    }
}

/** 用户点击上传按钮 */
- (void)readerViewController:(ReaderViewController *)viewController didChickUpdateItemWithNewPdfPath:(NSString *)pdfPath fileID:(NSString *)fileID
{
    [viewController dismissViewControllerAnimated:YES completion:nil];
    
    // 上传新的PDF 文件

}

@end
