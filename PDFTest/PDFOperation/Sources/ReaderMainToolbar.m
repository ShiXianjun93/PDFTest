//
//	ReaderMainToolbar.m
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

#import "ReaderConstants.h"
#import "ReaderMainToolbar.h"
#import "ReaderDocument.h"
#import "UIViewExt.h"

#import <MessageUI/MessageUI.h>

/** 处理pdf文件 使用的文件夹 */
#define kDataProcessingPdf @"dataProcessingPdf"

#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define kScreenWidth [UIScreen mainScreen].bounds.size.width

@interface ReaderMainToolbar ()<UIAlertViewDelegate>

/** 保存按钮 */
@property (nonatomic, strong) UIButton *btnSave;

/** 文件名称 */
@property (nonatomic, strong) NSString *fileName;

@end

@implementation ReaderMainToolbar
{
	UIButton *markButton;

	UIImage *markImageN;
	UIImage *markImageY;
}

#pragma mark - Constants

#define BUTTON_X 8.0f
#define BUTTON_Y 8.0f

#define BUTTON_SPACE 8.0f
#define BUTTON_HEIGHT 30.0f

#define BUTTON_FONT_SIZE 15.0f
#define TEXT_BUTTON_PADDING 24.0f

#define ICON_BUTTON_WIDTH 40.0f

#define TITLE_FONT_SIZE 19.0f
#define TITLE_HEIGHT 28.0f

#pragma mark - Properties

@synthesize delegate;

#pragma mark - ReaderMainToolbar instance methods

- (instancetype)initWithFrame:(CGRect)frame
{
	return [self initWithFrame:frame document:nil pdfFileName:@""];
}

- (instancetype)initWithFrame:(CGRect)frame document:(ReaderDocument *)document pdfFileName:(NSString *)fileName
{
	assert(document != nil); // Must have a valid ReaderDocument

	if ((self = [super initWithFrame:frame]))
	{
        self.fileName = fileName;
        
        [self _initdata];
        
        [self _loadSubviews];
        
	}

	return self;
}

#pragma mark -

#pragma mark - Private
- (void)_initdata
{
    
}

- (void)_loadSubviews
{
    UIFont *doneButtonFont = [UIFont systemFontOfSize:BUTTON_FONT_SIZE];
    NSString *doneButtonText = @"返回";
    
    UIButton *btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    btnBack.frame = CGRectMake(8, BUTTON_Y, 40, BUTTON_HEIGHT);
    [btnBack setTitleColor:[UIColor colorWithWhite:0.0f alpha:1.0f] forState:UIControlStateNormal];
    [btnBack setTitleColor:[UIColor colorWithWhite:1.0f alpha:1.0f] forState:UIControlStateHighlighted];
    [btnBack setTitle:doneButtonText forState:UIControlStateNormal]; btnBack.titleLabel.font = doneButtonFont;
    [btnBack addTarget:self action:@selector(doneButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    btnBack.autoresizingMask = UIViewAutoresizingNone;
    btnBack.exclusiveTouch = YES;
    [self addSubview: btnBack];
    
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(50, BUTTON_Y, kScreenWidth - 100, BUTTON_HEIGHT)];
    lblTitle.textAlignment = NSTextAlignmentCenter;
    lblTitle.textColor = [UIColor blackColor];
    lblTitle.text = self.fileName;
    lblTitle.font = [UIFont boldSystemFontOfSize:15];
    [self addSubview:lblTitle];
    
    if ([self haveNewPdfFile]) {
        
        UIButton *btnUpdate = [UIButton buttonWithType:UIButtonTypeCustom];
        btnUpdate.frame = CGRectMake(8, BUTTON_Y, 40, BUTTON_HEIGHT);
        [btnUpdate setTitleColor:[UIColor colorWithWhite:0.0f alpha:1.0f] forState:UIControlStateNormal];
        [btnUpdate setTitleColor:[UIColor colorWithWhite:1.0f alpha:1.0f] forState:UIControlStateHighlighted];
        [btnUpdate setTitle:@"上传" forState:UIControlStateNormal];
        btnUpdate.titleLabel.font = [UIFont systemFontOfSize:BUTTON_FONT_SIZE];
        [btnUpdate addTarget:self action:@selector(updateButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        btnUpdate.autoresizingMask = UIViewAutoresizingNone;
        btnUpdate.exclusiveTouch = YES;
        [self addSubview: btnUpdate];
        btnUpdate.right_ext = kScreenWidth - 8;
    }
    
}

- (BOOL)haveNewPdfFile
{
    return [[NSFileManager defaultManager] fileExistsAtPath:[NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@/newPdf.pdf", kDataProcessingPdf]];
}


- (void)setBookmarkState:(BOOL)state
{
#if (READER_BOOKMARKS == TRUE) // Option

	if (state != markButton.tag) // Only if different state
	{
		if (self.hidden == NO) // Only if toolbar is visible
		{
			UIImage *image = (state ? markImageY : markImageN);

			[markButton setImage:image forState:UIControlStateNormal];
		}

		markButton.tag = state; // Update bookmarked state tag
	}

	if (markButton.enabled == NO) markButton.enabled = YES;

#endif // end of READER_BOOKMARKS Option
}

- (void)updateBookmarkImage
{
#if (READER_BOOKMARKS == TRUE) // Option

	if (markButton.tag != NSIntegerMin) // Valid tag
	{
		BOOL state = markButton.tag; // Bookmarked state

		UIImage *image = (state ? markImageY : markImageN);

		[markButton setImage:image forState:UIControlStateNormal];
	}

	if (markButton.enabled == NO) markButton.enabled = YES;

#endif // end of READER_BOOKMARKS Option
}

- (void)hideToolbar
{
	if (self.hidden == NO)
	{
		[UIView animateWithDuration:0.25 delay:0.0
			options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
			animations:^(void)
			{
				self.alpha = 0.0f;
			}
			completion:^(BOOL finished)
			{
				self.hidden = YES;
			}
		];
	}
}

- (void)showToolbar
{
	if (self.hidden == YES)
	{
		[self updateBookmarkImage]; // First

		[UIView animateWithDuration:0.25 delay:0.0
			options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
			animations:^(void)
			{
				self.hidden = NO;
				self.alpha = 1.0f;
			}
			completion:NULL
		];
	}
}

#pragma mark - UIButton action methods

- (void)doneButtonTapped:(UIButton *)button
{
    if ([self haveNewPdfFile]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"放弃已经编辑的文件?" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"放弃", nil];
        [alert show];
    }else{
        [delegate tappedInToolbar:self doneButton:nil];
    }
}

- (void)updateButtonTapped:(UIButton *)button
{
    [delegate tappedInToolbar:self updateButton:button];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [delegate tappedInToolbar:self doneButton:nil];
    }
}


@end
