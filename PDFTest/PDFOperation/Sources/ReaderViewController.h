//
//	ReaderViewController.h
//	Reader v2.8.6
//
//	Created by Julius Oklamcak on 2011-07-01.
//	Copyright © 2011-2015 Julius Oklamcak. All rights reserved.
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights to
//	use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
//	of the Software, and to permit persons to whom the Software is furnished to
//	do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in all
//	copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//	OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//	WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//	CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import <UIKit/UIKit.h>

#import "ReaderDocument.h"

@class ReaderViewController;

@protocol ReaderViewControllerDelegate <NSObject>

@optional // Delegate protocols

/** 点击隐藏按钮 */
- (void)dismissReaderViewController:(ReaderViewController *)viewController;

/** 已经生成一个新的文件 */
- (void)readerViewController:(ReaderViewController *)viewController didCreateNewPdfWithPath:(NSString *)pdfPath fileName:(NSString *)fileName fileID:(NSString *)fileID currPage:(NSInteger)currPage;

/** 用户点击上传按钮 */
- (void)readerViewController:(ReaderViewController *)viewController didChickUpdateItemWithNewPdfPath:(NSString *)pdfPath fileID:(NSString *)fileID;

@end

@interface ReaderViewController : UIViewController

@property (nonatomic, weak, readwrite) id <ReaderViewControllerDelegate> delegate;

- (instancetype)initWithReaderDocument:(ReaderDocument *)object fileName:(NSString *)fileName canEdit:(BOOL)canEdit fileID:(NSString *)fileID showPage:(NSInteger)showPage;

/** 
 *@ 销毁 编辑 所生成的PDF 文件
 *@ 文件的存在会影响到 右上角 上传按钮的显示
 */
- (void)destructionNewPdfFile;

@end
