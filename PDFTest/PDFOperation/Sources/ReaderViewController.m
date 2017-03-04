//
//	ReaderViewController.m
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
#import "ReaderViewController.h"
#import "ThumbsViewController.h"
#import "ReaderMainToolbar.h"
#import "ReaderMainPagebar.h"
#import "ReaderContentView.h"
#import "ReaderThumbCache.h"
#import "ReaderThumbQueue.h"

#import "UIButtonSuspension.h"
#import "UIImageViewSign.h"
#import "ReaderContentPage.h"

#import "NewMySignatureViewController.h"

#import "NSString+IntervalSince1970.h"

#import "UIControllerPDFOpinionEdit.h"

#import <MessageUI/MessageUI.h>
#import "UIViewExt.h"

/** 处理pdf文件 使用的文件夹 */
#define kDataProcessingPdf @"dataProcessingPdf"

typedef NS_ENUM(NSInteger, PDFCurrEditType) {
    PDFCurrEditType_None = 0,
    PDFCurrEditType_Sign = 1,
    PDFCurrEditType_Opinion = 2
};

@interface ReaderViewController ()
<UIScrollViewDelegate,
UIGestureRecognizerDelegate,
MFMailComposeViewControllerDelegate,
UIDocumentInteractionControllerDelegate,
ReaderMainToolbarDelegate,
ReaderMainPagebarDelegate,
ReaderContentViewDelegate,
ThumbsViewControllerDelegate,
UIActionSheetDelegate,
UIImageViewSignDelegate,
UIControllerPDFOpinionEditDelegate,
UIAlertViewDelegate>

/** 签名按钮 */
@property (nonatomic, strong) UIButtonSuspension *btnSign;

/** 意见按钮 */
@property (nonatomic, strong) UIButtonSuspension *btnOpinion;

/** 签名完成按钮 */
@property (nonatomic, strong) UIButtonSuspension *btnSignDone;

/** 签名图片 */
@property (nonatomic, strong) UIImageViewSign *imageViewSign;

/** 签名时间图片 */
@property (nonatomic, strong) UIImageViewSign *imageViewSignTime;

/** 意见图片 */
@property (nonatomic, strong) UIImageViewSign *imageViewOpinion;

/** 正在编辑的类型 */
@property (nonatomic, assign) PDFCurrEditType currEditType;

/** 是否可以编辑PDF文件 */
@property (nonatomic, assign) BOOL canEditPdf;

/** PDF 文件名称 */
@property (nonatomic, strong) NSString *PdfFileName;

/** 文件ID */
@property (nonatomic, strong) NSString *fileID;

/** 展示文件页码 */
@property (nonatomic, assign) NSInteger showPage;
@end

@implementation ReaderViewController
{
	ReaderDocument *document;

	UIScrollView *theScrollView;

	ReaderMainToolbar *mainToolbar;

	ReaderMainPagebar *mainPagebar;

	NSMutableDictionary *contentViews;

	UIUserInterfaceIdiom userInterfaceIdiom;

	NSInteger currentPage, minimumPage, maximumPage;

	UIDocumentInteractionController *documentInteraction;

	UIPrintInteractionController *printInteraction;

	CGFloat scrollViewOutset;

	CGSize lastAppearSize;

	NSDate *lastHideTime;

	BOOL ignoreDidScroll;
    
}

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

#pragma mark - Constants

#define STATUS_HEIGHT 20.0f

#define TOOLBAR_HEIGHT 44.0f
#define PAGEBAR_HEIGHT 48.0f

#define SCROLLVIEW_OUTSET_SMALL 4.0f
#define SCROLLVIEW_OUTSET_LARGE 8.0f

#define TAP_AREA_SIZE 48.0f

#pragma mark - Properties

@synthesize delegate;

#pragma mark - ReaderViewController methods

- (void)updateContentSize:(UIScrollView *)scrollView
{
	CGFloat contentHeight = scrollView.bounds.size.height; // Height

	CGFloat contentWidth = (scrollView.bounds.size.width * maximumPage);

	scrollView.contentSize = CGSizeMake(contentWidth, contentHeight);
}

- (void)updateContentViews:(UIScrollView *)scrollView
{
	[self updateContentSize:scrollView]; // Update content size first

	[contentViews enumerateKeysAndObjectsUsingBlock: // Enumerate content views
		^(NSNumber *key, ReaderContentView *contentView, BOOL *stop)
		{
			NSInteger page = [key integerValue]; // Page number value

			CGRect viewRect = CGRectZero; viewRect.size = scrollView.bounds.size;

			viewRect.origin.x = (viewRect.size.width * (page - 1)); // Update X

			contentView.frame = CGRectInset(viewRect, scrollViewOutset, 0.0f);
		}
	];

	NSInteger page = currentPage; // Update scroll view offset to current page

	CGPoint contentOffset = CGPointMake((scrollView.bounds.size.width * (page - 1)), 0.0f);

	if (CGPointEqualToPoint(scrollView.contentOffset, contentOffset) == false) // Update
	{
		scrollView.contentOffset = contentOffset; // Update content offset
	}

	[mainToolbar setBookmarkState:[document.bookmarks containsIndex:page]];

	[mainPagebar updatePagebar]; // Update page bar
}

- (void)addContentView:(UIScrollView *)scrollView page:(NSInteger)page
{
	CGRect viewRect = CGRectZero; viewRect.size = scrollView.bounds.size;

	viewRect.origin.x = (viewRect.size.width * (page - 1)); viewRect = CGRectInset(viewRect, scrollViewOutset, 0.0f);

	NSURL *fileURL = document.fileURL; NSString *phrase = document.password; NSString *guid = document.guid; // Document properties

	ReaderContentView *contentView = [[ReaderContentView alloc] initWithFrame:viewRect fileURL:fileURL page:page password:phrase]; // ReaderContentView

	contentView.message = self; [contentViews setObject:contentView forKey:[NSNumber numberWithInteger:page]]; [scrollView addSubview:contentView];

	[contentView showPageThumb:fileURL page:page password:phrase guid:guid]; // Request page preview thumb
}

- (void)layoutContentViews:(UIScrollView *)scrollView
{
	CGFloat viewWidth = scrollView.bounds.size.width; // View width

	CGFloat contentOffsetX = scrollView.contentOffset.x; // Content offset X

	NSInteger pageB = ((contentOffsetX + viewWidth - 1.0f) / viewWidth); // Pages

	NSInteger pageA = (contentOffsetX / viewWidth); pageB += 2; // Add extra pages

	if (pageA < minimumPage) pageA = minimumPage; if (pageB > maximumPage) pageB = maximumPage;

	NSRange pageRange = NSMakeRange(pageA, (pageB - pageA + 1)); // Make page range (A to B)

	NSMutableIndexSet *pageSet = [NSMutableIndexSet indexSetWithIndexesInRange:pageRange];

	for (NSNumber *key in [contentViews allKeys]) // Enumerate content views
	{
		NSInteger page = [key integerValue]; // Page number value

		if ([pageSet containsIndex:page] == NO) // Remove content view
		{
			ReaderContentView *contentView = [contentViews objectForKey:key];

			[contentView removeFromSuperview]; [contentViews removeObjectForKey:key];
		}
		else // Visible content view - so remove it from page set
		{
			[pageSet removeIndex:page];
		}
	}

	NSInteger pages = pageSet.count;

	if (pages > 0) // We have pages to add
	{
		NSEnumerationOptions options = 0; // Default

		if (pages == 2) // Handle case of only two content views
		{
			if ((maximumPage > 2) && ([pageSet lastIndex] == maximumPage)) options = NSEnumerationReverse;
		}
		else if (pages == 3) // Handle three content views - show the middle one first
		{
			NSMutableIndexSet *workSet = [pageSet mutableCopy]; options = NSEnumerationReverse;

			[workSet removeIndex:[pageSet firstIndex]]; [workSet removeIndex:[pageSet lastIndex]];

			NSInteger page = [workSet firstIndex]; [pageSet removeIndex:page];

			[self addContentView:scrollView page:page];
		}

		[pageSet enumerateIndexesWithOptions:options usingBlock: // Enumerate page set
			^(NSUInteger page, BOOL *stop)
			{
				[self addContentView:scrollView page:page];
			}
		];
	}
}

- (void)handleScrollViewDidEnd:(UIScrollView *)scrollView
{
	CGFloat viewWidth = scrollView.bounds.size.width; // Scroll view width

	CGFloat contentOffsetX = scrollView.contentOffset.x; // Content offset X

	NSInteger page = (contentOffsetX / viewWidth); page++; // Page number

	if (page != currentPage) // Only if on different page
	{
		currentPage = page; document.pageNumber = [NSNumber numberWithInteger:page];

		[contentViews enumerateKeysAndObjectsUsingBlock: // Enumerate content views
			^(NSNumber *key, ReaderContentView *contentView, BOOL *stop)
			{
				if ([key integerValue] != page) [contentView zoomResetAnimated:NO];
			}
		];

		[mainToolbar setBookmarkState:[document.bookmarks containsIndex:page]];

		[mainPagebar updatePagebar]; // Update page bar
	}
}

- (void)showDocumentPage:(NSInteger)page
{
	if (page != currentPage) // Only if on different page
	{
		if ((page < minimumPage) || (page > maximumPage)) return;

		currentPage = page; document.pageNumber = [NSNumber numberWithInteger:page];

		CGPoint contentOffset = CGPointMake((theScrollView.bounds.size.width * (page - 1)), 0.0f);

		if (CGPointEqualToPoint(theScrollView.contentOffset, contentOffset) == true)
			[self layoutContentViews:theScrollView];
		else
			[theScrollView setContentOffset:contentOffset];

		[contentViews enumerateKeysAndObjectsUsingBlock: // Enumerate content views
			^(NSNumber *key, ReaderContentView *contentView, BOOL *stop)
			{
				if ([key integerValue] != page) [contentView zoomResetAnimated:NO];
			}
		];

		[mainToolbar setBookmarkState:[document.bookmarks containsIndex:page]];

		[mainPagebar updatePagebar]; // Update page bar
	}
}

- (void)showDocument
{
	[self updateContentSize:theScrollView]; // Update content size first

	[self showDocumentPage:[document.pageNumber integerValue]]; // Show page

	document.lastOpen = [NSDate date]; // Update document last opened date
}

- (void)closeDocument
{
	if (printInteraction != nil) [printInteraction dismissAnimated:NO];

	[document archiveDocumentProperties]; // Save any ReaderDocument changes

	[[ReaderThumbQueue sharedInstance] cancelOperationsWithGUID:document.guid];

	[[ReaderThumbCache sharedInstance] removeAllObjects]; // Empty the thumb cache

	if ([delegate respondsToSelector:@selector(dismissReaderViewController:)] == YES)
	{
		[delegate dismissReaderViewController:self]; // Dismiss the ReaderViewController
	}
	else // We have a "Delegate must respond to -dismissReaderViewController:" error
	{
		NSAssert(NO, @"Delegate must respond to -dismissReaderViewController:");
	}
}

#pragma mark - UIViewController methods

- (instancetype)initWithReaderDocument:(ReaderDocument *)object fileName:(NSString *)fileName canEdit:(BOOL)canEdit fileID:(NSString *)fileID showPage:(NSInteger)showPage
{
    
    assert(fileID != nil);// fileID 不可为空
    
	if ((self = [super initWithNibName:nil bundle:nil])) // Initialize superclass
	{
		if ((object != nil) && ([object isKindOfClass:[ReaderDocument class]])) // Valid object
		{
			userInterfaceIdiom = [UIDevice currentDevice].userInterfaceIdiom; // User interface idiom

			NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter]; // Default notification center

			[notificationCenter addObserver:self selector:@selector(applicationWillResign:) name:UIApplicationWillTerminateNotification object:nil];

			[notificationCenter addObserver:self selector:@selector(applicationWillResign:) name:UIApplicationWillResignActiveNotification object:nil];

			scrollViewOutset = ((userInterfaceIdiom == UIUserInterfaceIdiomPad) ? SCROLLVIEW_OUTSET_LARGE : SCROLLVIEW_OUTSET_SMALL);

			[object updateDocumentProperties]; document = object; // Retain the supplied ReaderDocument object for our use

			[ReaderThumbCache touchThumbCacheWithGUID:object.guid]; // Touch the document thumb cache directory
            
            self.PdfFileName = fileName;
            
            self.canEditPdf = canEdit;
            
            self.fileID = fileID;
            
            self.showPage = showPage;
		}
		else // Invalid ReaderDocument object
		{
			self = nil;
		}
	}

	return self;
}

- (void)dealloc
{
    [self deletePdfPageFiles];
    
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
	[super viewDidLoad];

	assert(document != nil); // Must have a valid ReaderDocument

	self.view.backgroundColor = [UIColor grayColor]; // Neutral gray

	UIView *fakeStatusBar = nil; CGRect viewRect = self.view.bounds; // View bounds

	if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) // iOS 7+
	{
		if ([self prefersStatusBarHidden] == NO) // Visible status bar
		{
			CGRect statusBarRect = viewRect; statusBarRect.size.height = STATUS_HEIGHT;
			fakeStatusBar = [[UIView alloc] initWithFrame:statusBarRect]; // UIView
			fakeStatusBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
			fakeStatusBar.backgroundColor = [UIColor blackColor];
			fakeStatusBar.contentMode = UIViewContentModeRedraw;
			fakeStatusBar.userInteractionEnabled = NO;

			viewRect.origin.y += STATUS_HEIGHT; viewRect.size.height -= STATUS_HEIGHT;
		}
	}

	CGRect scrollViewRect = CGRectInset(viewRect, -scrollViewOutset, 0.0f);
	theScrollView = [[UIScrollView alloc] initWithFrame:scrollViewRect]; // All
	theScrollView.autoresizesSubviews = NO; theScrollView.contentMode = UIViewContentModeRedraw;
	theScrollView.showsHorizontalScrollIndicator = NO; theScrollView.showsVerticalScrollIndicator = NO;
	theScrollView.scrollsToTop = NO; theScrollView.delaysContentTouches = NO; theScrollView.pagingEnabled = YES;
	theScrollView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	theScrollView.backgroundColor = [UIColor clearColor]; theScrollView.delegate = self;
	[self.view addSubview:theScrollView];

	CGRect toolbarRect = viewRect; toolbarRect.size.height = TOOLBAR_HEIGHT;
	mainToolbar = [[ReaderMainToolbar alloc] initWithFrame:toolbarRect document:document pdfFileName:self.PdfFileName]; // ReaderMainToolbar
	mainToolbar.delegate = self; // ReaderMainToolbarDelegate
	[self.view addSubview:mainToolbar];

	CGRect pagebarRect = self.view.bounds; pagebarRect.size.height = PAGEBAR_HEIGHT;
	pagebarRect.origin.y = (self.view.bounds.size.height - pagebarRect.size.height);
	mainPagebar = [[ReaderMainPagebar alloc] initWithFrame:pagebarRect document:document]; // ReaderMainPagebar
	mainPagebar.delegate = self; // ReaderMainPagebarDelegate
	[self.view addSubview:mainPagebar];

	if (fakeStatusBar != nil) [self.view addSubview:fakeStatusBar]; // Add status bar background view

	UITapGestureRecognizer *singleTapOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
	singleTapOne.numberOfTouchesRequired = 1; singleTapOne.numberOfTapsRequired = 1; singleTapOne.delegate = self;
	[self.view addGestureRecognizer:singleTapOne];

	UITapGestureRecognizer *doubleTapOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
	doubleTapOne.numberOfTouchesRequired = 1; doubleTapOne.numberOfTapsRequired = 2; doubleTapOne.delegate = self;
	[self.view addGestureRecognizer:doubleTapOne];

	UITapGestureRecognizer *doubleTapTwo = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
	doubleTapTwo.numberOfTouchesRequired = 2; doubleTapTwo.numberOfTapsRequired = 2; doubleTapTwo.delegate = self;
	[self.view addGestureRecognizer:doubleTapTwo];

	[singleTapOne requireGestureRecognizerToFail:doubleTapOne]; // Single tap requires double tap to fail

	contentViews = [NSMutableDictionary new]; lastHideTime = [NSDate date];

	minimumPage = 1; maximumPage = [document.pageCount integerValue];
    
    [self _initdata];
    
    [self _loadSubviews];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	if (CGSizeEqualToSize(lastAppearSize, CGSizeZero) == false)
	{
		if (CGSizeEqualToSize(lastAppearSize, self.view.bounds.size) == false)
		{
			[self updateContentViews:theScrollView]; // Update content views
		}

		lastAppearSize = CGSizeZero; // Reset view size tracking
	}
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];

	if (CGSizeEqualToSize(theScrollView.contentSize, CGSizeZero) == true)
	{
		[self performSelector:@selector(showDocument) withObject:nil afterDelay:0.0];
	}

#if (READER_DISABLE_IDLE == TRUE) // Option

	[UIApplication sharedApplication].idleTimerDisabled = YES;

#endif // end of READER_DISABLE_IDLE Option
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];

	lastAppearSize = self.view.bounds.size; // Track view size

#if (READER_DISABLE_IDLE == TRUE) // Option

	[UIApplication sharedApplication].idleTimerDisabled = NO;

#endif // end of READER_DISABLE_IDLE Option
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (void)viewDidUnload
{
#ifdef DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif

	mainToolbar = nil; mainPagebar = nil;

	theScrollView = nil; contentViews = nil; lastHideTime = nil;

	documentInteraction = nil; printInteraction = nil;

	lastAppearSize = CGSizeZero; currentPage = 0;

	[super viewDidUnload];
}

- (BOOL)prefersStatusBarHidden
{
	return YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
	return UIStatusBarStyleLightContent;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	if (userInterfaceIdiom == UIUserInterfaceIdiomPad) if (printInteraction != nil) [printInteraction dismissAnimated:NO];

	ignoreDidScroll = YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
	if (CGSizeEqualToSize(theScrollView.contentSize, CGSizeZero) == false)
	{
		[self updateContentViews:theScrollView]; lastAppearSize = CGSizeZero;
	}
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	ignoreDidScroll = NO;
}

- (void)didReceiveMemoryWarning
{
#ifdef DEBUG
	NSLog(@"%s", __FUNCTION__);
#endif

	[super didReceiveMemoryWarning];
}

#pragma mark - UIScrollViewDelegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	if (ignoreDidScroll == NO) [self layoutContentViews:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	[self handleScrollViewDidEnd:scrollView];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
	[self handleScrollViewDidEnd:scrollView];
}

#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)recognizer shouldReceiveTouch:(UITouch *)touch
{
	if ([touch.view isKindOfClass:[UIScrollView class]]) return YES;

	return NO;
}

#pragma mark - UIGestureRecognizer action methods

- (void)decrementPageNumber
{
	if ((maximumPage > minimumPage) && (currentPage != minimumPage))
	{
		CGPoint contentOffset = theScrollView.contentOffset; // Offset

		contentOffset.x -= theScrollView.bounds.size.width; // View X--

		[theScrollView setContentOffset:contentOffset animated:YES];
	}
}

- (void)incrementPageNumber
{
	if ((maximumPage > minimumPage) && (currentPage != maximumPage))
	{
		CGPoint contentOffset = theScrollView.contentOffset; // Offset

		contentOffset.x += theScrollView.bounds.size.width; // View X++

		[theScrollView setContentOffset:contentOffset animated:YES];
	}
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateRecognized)
	{
		CGRect viewRect = recognizer.view.bounds; // View bounds

		CGPoint point = [recognizer locationInView:recognizer.view]; // Point

		CGRect areaRect = CGRectInset(viewRect, TAP_AREA_SIZE, 0.0f); // Area rect

		if (CGRectContainsPoint(areaRect, point) == true) // Single tap is inside area
		{
			NSNumber *key = [NSNumber numberWithInteger:currentPage]; // Page number key

			ReaderContentView *targetView = [contentViews objectForKey:key]; // View

			id target = [targetView processSingleTap:recognizer]; // Target object

			if (target != nil) // Handle the returned target object
			{
				if ([target isKindOfClass:[NSURL class]]) // Open a URL
				{
					NSURL *url = (NSURL *)target; // Cast to a NSURL object

					if (url.scheme == nil) // Handle a missing URL scheme
					{
						NSString *www = url.absoluteString; // Get URL string

						if ([www hasPrefix:@"www"] == YES) // Check for 'www' prefix
						{
							NSString *http = [[NSString alloc] initWithFormat:@"http://%@", www];

							url = [NSURL URLWithString:http]; // Proper http-based URL
						}
					}

					if ([[UIApplication sharedApplication] openURL:url] == NO)
					{
						#ifdef DEBUG
							NSLog(@"%s '%@'", __FUNCTION__, url); // Bad or unknown URL
						#endif
					}
				}
				else // Not a URL, so check for another possible object type
				{
					if ([target isKindOfClass:[NSNumber class]]) // Goto page
					{
						NSInteger number = [target integerValue]; // Number

						[self showDocumentPage:number]; // Show the page
					}
				}
			}
			else // Nothing active tapped in the target content view
			{
				if ([lastHideTime timeIntervalSinceNow] < -0.75) // Delay since hide
				{
					if ((mainToolbar.alpha < 1.0f) || (mainPagebar.alpha < 1.0f)) // Hidden
					{
						[mainToolbar showToolbar]; [mainPagebar showPagebar]; // Show
					}
				}
			}

			return;
		}

		CGRect nextPageRect = viewRect;
		nextPageRect.size.width = TAP_AREA_SIZE;
		nextPageRect.origin.x = (viewRect.size.width - TAP_AREA_SIZE);

		if (CGRectContainsPoint(nextPageRect, point) == true) // page++
		{
			[self incrementPageNumber]; return;
		}

		CGRect prevPageRect = viewRect;
		prevPageRect.size.width = TAP_AREA_SIZE;

		if (CGRectContainsPoint(prevPageRect, point) == true) // page--
		{
			[self decrementPageNumber]; return;
		}
	}
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)recognizer
{
	if (recognizer.state == UIGestureRecognizerStateRecognized)
	{
		CGRect viewRect = recognizer.view.bounds; // View bounds

		CGPoint point = [recognizer locationInView:recognizer.view]; // Point

		CGRect zoomArea = CGRectInset(viewRect, TAP_AREA_SIZE, TAP_AREA_SIZE); // Area

		if (CGRectContainsPoint(zoomArea, point) == true) // Double tap is inside zoom area
		{
			NSNumber *key = [NSNumber numberWithInteger:currentPage]; // Page number key

			ReaderContentView *targetView = [contentViews objectForKey:key]; // View

			switch (recognizer.numberOfTouchesRequired) // Touches count
			{
				case 1: // One finger double tap: zoom++
				{
					[targetView zoomIncrement:recognizer]; break;
				}

				case 2: // Two finger double tap: zoom--
				{
					[targetView zoomDecrement:recognizer]; break;
				}
			}

			return;
		}

		CGRect nextPageRect = viewRect;
		nextPageRect.size.width = TAP_AREA_SIZE;
		nextPageRect.origin.x = (viewRect.size.width - TAP_AREA_SIZE);

		if (CGRectContainsPoint(nextPageRect, point) == true) // page++
		{
			[self incrementPageNumber]; return;
		}

		CGRect prevPageRect = viewRect;
		prevPageRect.size.width = TAP_AREA_SIZE;

		if (CGRectContainsPoint(prevPageRect, point) == true) // page--
		{
			[self decrementPageNumber]; return;
		}
	}
}

#pragma mark - ReaderContentViewDelegate methods

- (void)contentView:(ReaderContentView *)contentView touchesBegan:(NSSet *)touches
{
	if ((mainToolbar.alpha > 0.0f) || (mainPagebar.alpha > 0.0f))
	{
		if (touches.count == 1) // Single touches only
		{
			UITouch *touch = [touches anyObject]; // Touch info

			CGPoint point = [touch locationInView:self.view]; // Touch location

			CGRect areaRect = CGRectInset(self.view.bounds, TAP_AREA_SIZE, TAP_AREA_SIZE);

			if (CGRectContainsPoint(areaRect, point) == false) return;
		}

		[mainToolbar hideToolbar]; [mainPagebar hidePagebar]; // Hide

		lastHideTime = [NSDate date]; // Set last hide time
	}
}

#pragma mark - ReaderMainToolbarDelegate methods

- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar doneButton:(UIButton *)button
{
#if (READER_STANDALONE == FALSE) // Option

	[self closeDocument]; // Close ReaderViewController

#endif // end of READER_STANDALONE Option
}

/** 上传已编辑的文件 */

- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar updateButton:(UIButton *)button
{
    if ([self.delegate respondsToSelector:@selector(readerViewController:didChickUpdateItemWithNewPdfPath:fileID:)]) {
        
        NSString *newPdfPath = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@/newPdf.pdf", kDataProcessingPdf];
        
        [self.delegate readerViewController:self didChickUpdateItemWithNewPdfPath:newPdfPath fileID:self.fileID];
    }
}

#pragma mark - MFMailComposeViewControllerDelegate methods

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
#ifdef DEBUG
	if ((result == MFMailComposeResultFailed) && (error != NULL)) NSLog(@"%@", error);
#endif

	[self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - UIDocumentInteractionControllerDelegate methods

- (void)documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController *)controller
{
	documentInteraction = nil;
}

#pragma mark - ThumbsViewControllerDelegate methods

- (void)thumbsViewController:(ThumbsViewController *)viewController gotoPage:(NSInteger)page
{
#if (READER_ENABLE_THUMBS == TRUE) // Option

	[self showDocumentPage:page];

#endif // end of READER_ENABLE_THUMBS Option
}

- (void)dismissThumbsViewController:(ThumbsViewController *)viewController
{
#if (READER_ENABLE_THUMBS == TRUE) // Option

	[self dismissViewControllerAnimated:NO completion:NULL];

#endif // end of READER_ENABLE_THUMBS Option
}

#pragma mark - ReaderMainPagebarDelegate methods

- (void)pagebar:(ReaderMainPagebar *)pagebar gotoPage:(NSInteger)page
{
	[self showDocumentPage:page];
}

#pragma mark - UIApplication notification methods

- (void)applicationWillResign:(NSNotification *)notification
{
	[document archiveDocumentProperties]; // Save any ReaderDocument changes

	if (userInterfaceIdiom == UIUserInterfaceIdiomPad) if (printInteraction != nil) [printInteraction dismissAnimated:NO];
}


#pragma mark - 悬浮按钮相关代码

#pragma mark - Private
- (void)_initdata
{
    
}

- (void)_loadSubviews
{
    
    if (self.canEditPdf) {
        [self.view addSubview:self.btnSign];
        
        [self.view addSubview:self.btnOpinion];
        
        [self.view addSubview:self.btnSignDone];
    }
    
    [self showDocumentPage:self.showPage];
}

- (void)showSignBtn
{
    
}

- (void)hideSignBtn
{
    
}

/**
 *@ 创建处理PDF文件路径 并且 清空路径内的文件
 */
- (void)createPDFProcessingFilesPath
{
    NSString *processingPdfPath = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@/filePages",kDataProcessingPdf];
    if(![[NSFileManager defaultManager] fileExistsAtPath:processingPdfPath]){
        [[NSFileManager defaultManager] createDirectoryAtPath:processingPdfPath withIntermediateDirectories:YES attributes:nil error:nil];
        
        [self splitPdfDataAndWriteToFile];
        
    }else{
        
        NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:processingPdfPath error:NULL];
        if (contents.count == 0) {
            [self splitPdfDataAndWriteToFile];
        }
    }
}

/** 删除拼接文件 */
- (void)deletePdfPageFiles
{
    NSString *processingPdfPath = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@/filePages",kDataProcessingPdf];
    
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:processingPdfPath error:NULL];
    NSEnumerator *e = [contents objectEnumerator];
    NSString *filename;
    while ((filename = [e nextObject])) {
        
        [[NSFileManager defaultManager] removeItemAtPath:[processingPdfPath stringByAppendingPathComponent:filename] error:NULL];
    }
}

/**
 *@ 销毁生存的新PDF文件
 */
- (void)destructionNewPdfFile
{
    NSString *newPdfPath = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@/newPdf.pdf", kDataProcessingPdf];
    [[NSFileManager defaultManager] removeItemAtPath:newPdfPath error:NULL];
}

#pragma mark - Setter

- (void)setCurrEditType:(PDFCurrEditType)currEditType
{
    if (_currEditType != currEditType) {
        _currEditType = currEditType;
        
        self.btnSign.animaHidden = _currEditType != PDFCurrEditType_None;
        
        self.btnOpinion.animaHidden = _currEditType != PDFCurrEditType_None;
        
        self.btnSignDone.animaHidden = _currEditType == PDFCurrEditType_None;
    }
}

#pragma mark - Getter

- (UIButtonSuspension *)btnSign
{
    if (_btnSign == nil) {
        _btnSign = [[UIButtonSuspension alloc] initWithFrame:CGRectMake(kScreenWidth - 8 - kBtnSignWidth, kScreenHeight - 200, kBtnSignWidth, kBtnSignWidth) image:[UIImage imageNamed:@"btn_Sign"]];
        [_btnSign addTarget:self action:@selector(chickSingItem) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnSign;
}

- (UIButtonSuspension *)btnOpinion
{
    if (_btnOpinion == nil) {
        _btnOpinion = [[UIButtonSuspension alloc] initWithFrame:CGRectMake(kScreenWidth - 8 - kBtnSignWidth, kScreenHeight - 135, kBtnSignWidth, kBtnSignWidth) image:[UIImage imageNamed:@"btn_Opinion"]];
        [_btnOpinion addTarget:self action:@selector(chickOpinionItem) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnOpinion;
}

- (UIButtonSuspension *)btnSignDone
{
    if (_btnSignDone == nil) {
        _btnSignDone = [[UIButtonSuspension alloc] initWithFrame:CGRectMake(kScreenWidth - 8 - kBtnSignWidth, 150, kBtnSignWidth, kBtnSignWidth) image:[UIImage imageNamed:@"btn_SignDone"]];
        [_btnSignDone addTarget:self action:@selector(chickSignDoneItem) forControlEvents:UIControlEventTouchUpInside];
        _btnSignDone.animaHidden = YES;
    }
    return _btnSignDone;
}

#pragma mark - Action
- (void)chickSingItem
{
    // 手写签名
    
    NewMySignatureViewController *New = [[NewMySignatureViewController alloc] initWithNibName:@"NewMySignatureViewController" bundle:[NSBundle mainBundle]];
    self.hidesBottomBarWhenPushed = YES;
    New.isOnlyGetImage = YES;
    __weak typeof(self) weakself = self;
    New.backSignatureImageView = ^(UIImage *image ,UIViewController *vc){
        
        [weakself.imageViewSign removeFromSuperview];
        weakself.imageViewSign = [[UIImageViewSign alloc] initWithImage:image width:kScreenWidth - 200 origin:CGPointMake(100, kScreenHeight - 500) showDeleteBtn:YES];
        weakself.imageViewSign.delegate = self;
        [weakself.view addSubview:weakself.imageViewSign];
        
        [weakself.imageViewSignTime removeFromSuperview];
        weakself.imageViewSignTime = [[UIImageViewSign alloc] initWithImage:[weakself getCurrTimeImage] width:kScreenWidth - 200 origin:CGPointMake(100, weakself.imageViewSign.bottom_ext + 50) showDeleteBtn:NO];
        weakself.imageViewSignTime.delegate = self;
        [weakself.view addSubview:weakself.imageViewSignTime];
        
        weakself.currEditType = PDFCurrEditType_Sign;
        
        [vc.navigationController dismissViewControllerAnimated:YES completion:nil];
        
    };
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:New];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)chickOpinionItem
{
    
    UIControllerPDFOpinionEdit *opinionEdit = [[UIControllerPDFOpinionEdit alloc] initWithNibName:@"UIControllerPDFOpinionEdit" bundle:[NSBundle mainBundle]];
    opinionEdit.delegate = self;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:opinionEdit];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)chickSignDoneItem
{
    ReaderContentView *currShowView = nil;
    for (id subview in theScrollView.subviews) {
        if ([subview isKindOfClass:[ReaderContentView class]]) {
            
            ReaderContentView *view = subview;
            if (view.tag == currentPage) {
                currShowView = view;
            }
            
        }
    }
    
    
    switch (self.currEditType) {
        case PDFCurrEditType_Sign:
        {
            NSLog(@"处理中");
            [self addImageViews:@[self.imageViewSign, self.imageViewSignTime] onPDFURL:document.fileURL page:currentPage readerContentView:currShowView block:^{
                NSLog(@"处理完成");
            }];
            
            [self.imageViewSign removeFromSuperview];
            [self.imageViewSignTime removeFromSuperview];
        }
            break;
        case PDFCurrEditType_Opinion:
        {
            NSLog(@"处理中");
            [self addImageViews:@[self.imageViewOpinion] onPDFURL:document.fileURL page:currentPage readerContentView:currShowView block:^{
                NSLog(@"处理完成");
            }];
            
            [self.imageViewOpinion removeFromSuperview];
        }
            break;
        default:
            break;
    }
    
    self.currEditType = PDFCurrEditType_None;
}

- (UIImage *)getCurrTimeImage
{
    NSString *strCurrTime = [[NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]] getYearMonthDayTime];
    
    UILabel *lblTime = [[UILabel alloc] init];
    lblTime.font = [UIFont systemFontOfSize:15];
    lblTime.textColor = [UIColor blackColor];
    lblTime.text = strCurrTime;
    [lblTime sizeToFit];
    lblTime.backgroundColor = [UIColor clearColor];
    lblTime.width_ext = lblTime.width_ext + 40;
    
    CGSize size = lblTime.bounds.size;
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    [lblTime.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark - UIImageViewSignDelegate
/** 点击 编辑图片删除按钮 */
- (void)didchickDeleteImageViewSign:(UIImageViewSign *)view
{
    if (view == self.imageViewSignTime || view == self.imageViewSign) {
        
        [self.imageViewSign removeFromSuperview];
        
        [self.imageViewSignTime removeFromSuperview];
    }
    
    if (view == self.imageViewOpinion) {
        
        [self.imageViewOpinion removeFromSuperview];
        
    }
    
    self.currEditType = PDFCurrEditType_None;
}

#pragma mark - UIControllerPDFOpinionEditDelegate
/**
 *@ 已经编辑完 意见
 */
- (void)controllerPDFOpinionEdit:(UIControllerPDFOpinionEdit *)controller didEditDoneWithOpinion:(NSString *)opinion
{
    [controller dismissViewControllerAnimated:YES completion:nil];
    
    UILabel *lblTime = [[UILabel alloc] init];
    lblTime.font = [UIFont systemFontOfSize:15];
    lblTime.textColor = [UIColor blackColor];
    lblTime.text = opinion;
    lblTime.numberOfLines = 0;
    lblTime.width_ext = kScreenWidth - 100;
    [lblTime sizeToFit];
    lblTime.backgroundColor = [UIColor clearColor];
    lblTime.width_ext = lblTime.width_ext + 40;
    
    CGSize size = lblTime.bounds.size;
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    [lblTime.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [self.imageViewOpinion removeFromSuperview];
    self.imageViewOpinion = [[UIImageViewSign alloc] initWithImage:image width:kScreenWidth - 200 origin:CGPointMake(100, kScreenHeight - 500) showDeleteBtn:YES];
    self.imageViewOpinion.delegate = self;
    [self.view addSubview:self.imageViewOpinion];
    
    self.currEditType = PDFCurrEditType_Opinion;
    
}


#pragma mark - 将图片贴到PDF文件上
/**
 *@ 将图片添加到  PDF 文件上
 *@ images      (UIImageViewSign) 图片视图数组
 *@ pdfData     pdf文件数据
 *@ pageIndex   pdf页码
 *@ zoomScale   当前pdf页面缩放的比例值
 */
-(void)addImageViews:(NSArray *)imageViews onPDFURL:(NSURL *)pdfURL page:(NSInteger)pageIndex readerContentView:(ReaderContentView *)readerContentView block:(void(^)())block{
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableData* outputPDFData = [[NSMutableData alloc] init];
        CGDataConsumerRef dataConsumer = CGDataConsumerCreateWithCFData((CFMutableDataRef)outputPDFData);
        
        CFMutableDictionaryRef attrDictionary = NULL;
        attrDictionary = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        CFDictionarySetValue(attrDictionary, kCGPDFContextTitle, CFSTR("My Doc"));
        CGContextRef pdfContext = CGPDFContextCreate(dataConsumer, NULL, attrDictionary);
        CFRelease(dataConsumer);
        CFRelease(attrDictionary);
        CGRect pageRect;
        
        // Draw the old "pdfData" on pdfContext
        CFDataRef myPDFData = (__bridge CFDataRef) [NSData dataWithContentsOfURL:pdfURL];
        CGDataProviderRef provider = CGDataProviderCreateWithCFData(myPDFData);
        CGPDFDocumentRef pdf = CGPDFDocumentCreateWithProvider(provider);
        CGDataProviderRelease(provider);
        CGPDFPageRef page = CGPDFDocumentGetPage(pdf, pageIndex);
        pageRect = CGPDFPageGetBoxRect(page, kCGPDFMediaBox);
        CGContextBeginPage(pdfContext, &pageRect);
        CGContextDrawPDFPage(pdfContext, page);
        
        for (UIImageViewSign *imageViewSign in imageViews) {
            if ([imageViewSign isKindOfClass:[UIImageViewSign class]]) {
                
                /** 获取PDF某一页信息 */
                ReaderContentPage *contentPage = [[ReaderContentPage alloc] initWithURL:pdfURL page:pageIndex password:@""];
                
                // 显示当前页PDF 缩放后 的高
                CGFloat contentViewHeight = readerContentView.contentSize.width / (contentPage.pageWidth / contentPage.pageHeight);
                
                if (contentViewHeight < kScreenHeight) {
                    
                    CGFloat topSpace = (kScreenHeight - contentViewHeight) / 2.f;
                    CGFloat realTop = imageViewSign.top_ext - topSpace;
                    
                    pageRect = CGRectMake(imageViewSign.left_ext/readerContentView.zoomScale, contentPage.pageHeight - realTop/readerContentView.zoomScale - imageViewSign.height_ext/readerContentView.zoomScale, imageViewSign.width_ext/readerContentView.zoomScale, imageViewSign.height_ext/readerContentView.zoomScale);
                    
                    CGImageRef pageImage = [imageViewSign.image CGImage];
                    CGContextDrawImage(pdfContext, pageRect, pageImage);
                    
                    
                }else{
                    
                    NSLog(@"放大");
                    
                    pageRect = CGRectMake((readerContentView.contentOffset.x + imageViewSign.left_ext)/readerContentView.zoomScale, contentPage.pageHeight - (readerContentView.contentOffset.y + imageViewSign.top_ext)/readerContentView.zoomScale - imageViewSign.height_ext/readerContentView.zoomScale, imageViewSign.width_ext/readerContentView.zoomScale, imageViewSign.height_ext/readerContentView.zoomScale);
                    
                    CGImageRef pageImage = [imageViewSign.image CGImage];
                    CGContextDrawImage(pdfContext, pageRect, pageImage);
                }
            }
        }
        
        // release the allocated memory
        CGPDFContextEndPage(pdfContext);
        CGPDFContextClose(pdfContext);
        CGContextRelease(pdfContext);
        
        [self createPDFProcessingFilesPath];
        
        NSString *pdfFilePath = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@/filePages/outPutPDF_%ld.pdf",kDataProcessingPdf, (long)pageIndex];
        [outputPDFData writeToFile:pdfFilePath atomically:YES];
        
        NSMutableArray *arrPdfPaths = [[NSMutableArray alloc] init];
        
        for (NSInteger i = 1; i <= maximumPage; i++) {
            NSString *pdfPath = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@/filePages/outPutPDF_%ld.pdf", kDataProcessingPdf, (long)i];
            [arrPdfPaths addObject:pdfPath];
        }
        
        NSString *filePath = [self joinPDF:arrPdfPaths pdfPathOutput:[NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@/newPdf.pdf", kDataProcessingPdf]];
        
        
        
        if ([self.delegate respondsToSelector:@selector(readerViewController:didCreateNewPdfWithPath:fileName:fileID:currPage:)]) {
            [self.delegate readerViewController:self didCreateNewPdfWithPath:filePath fileName:self.PdfFileName fileID:self.fileID currPage:currentPage];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) {
                block();
            }
        });
        
    });
}

- (void)updateSubviewsWithNewPdfFilePath:(NSString *)pdfFilePath readerContentView:(ReaderContentView *)readerContentView page:(NSInteger)pageIndex
{
    [readerContentView removeFromSuperview];
    
    CGRect viewRect = CGRectZero; viewRect.size = theScrollView.bounds.size;
    
    viewRect.origin.x = (viewRect.size.width * (pageIndex - 1)); viewRect = CGRectInset(viewRect, scrollViewOutset, 0.0f);
    
    NSURL *fileURL = document.fileURL; NSString *phrase = document.password; NSString *guid = document.guid; // Document properties
    
    ReaderContentView *contentView = [[ReaderContentView alloc] initWithFrame:viewRect fileURL:fileURL page:pageIndex password:phrase]; // ReaderContentView
    
    contentView.message = self; [contentViews setObject:contentView forKey:[NSNumber numberWithInteger:pageIndex]]; [theScrollView addSubview:contentView];
    
    [contentView showPageThumb:fileURL page:pageIndex password:phrase guid:guid]; // Request page preview thumb
}

/** 
 *@  整合 PDF 文件
 *@  listOfPaths  需要整和文件路径数组
 *@  整合后的文件输出
 */

- (NSString *)joinPDF:(NSArray *)listOfPaths pdfPathOutput:(NSString *)pdfPathOutput{
    
    CFURLRef pdfURLOutput = (  CFURLRef)CFBridgingRetain([NSURL fileURLWithPath:pdfPathOutput]);
    NSInteger numberOfPages = 0;
    CGContextRef writeContext = CGPDFContextCreateWithURL(pdfURLOutput, NULL, NULL);
    
    for (NSString *source in listOfPaths) {
        
        CFURLRef pdfURL = (  CFURLRef)CFBridgingRetain([[NSURL alloc] initFileURLWithPath:source]);
        CGPDFDocumentRef pdfRef = CGPDFDocumentCreateWithURL((CFURLRef) pdfURL);
        numberOfPages = CGPDFDocumentGetNumberOfPages(pdfRef);
        CGPDFPageRef page;
        CGRect mediaBox;
        
        for (int i=1; i<=numberOfPages; i++) {
            
            page = CGPDFDocumentGetPage(pdfRef, i);
            mediaBox = CGPDFPageGetBoxRect(page, kCGPDFMediaBox);
            CGContextBeginPage(writeContext, &mediaBox);
            CGContextDrawPDFPage(writeContext, page);
            CGContextEndPage(writeContext);
            
        }
        CGPDFDocumentRelease(pdfRef);
        CFRelease(pdfURL);
    }
    
    CFRelease(pdfURLOutput);
    CGPDFContextClose(writeContext);
    CGContextRelease(writeContext);
    
    return pdfPathOutput;
}


- (void)splitPdfDataAndWriteToFile
{
    for (NSInteger i = 1; i <= maximumPage; i++) {
        
        NSMutableData* outputPDFData = [[NSMutableData alloc] init];
        CGDataConsumerRef dataConsumer = CGDataConsumerCreateWithCFData((CFMutableDataRef)outputPDFData);
        
        CFMutableDictionaryRef attrDictionary = NULL;
        attrDictionary = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        CFDictionarySetValue(attrDictionary, kCGPDFContextTitle, CFSTR("My Doc"));
        CGContextRef pdfContext = CGPDFContextCreate(dataConsumer, NULL, attrDictionary);
        CFRelease(dataConsumer);
        CFRelease(attrDictionary);
        CGRect pageRect;
        
        // Draw the old "pdfData" on pdfContext
        CFDataRef myPDFData = (__bridge CFDataRef) [NSData dataWithContentsOfURL:document.fileURL];
        CGDataProviderRef provider = CGDataProviderCreateWithCFData(myPDFData);
        CGPDFDocumentRef pdf = CGPDFDocumentCreateWithProvider(provider);
        CGDataProviderRelease(provider);
        CGPDFPageRef page = CGPDFDocumentGetPage(pdf, i);
        pageRect = CGPDFPageGetBoxRect(page, kCGPDFMediaBox);
        CGContextBeginPage(pdfContext, &pageRect);
        CGContextDrawPDFPage(pdfContext, page);
        
        // release the allocated memory
        CGPDFContextEndPage(pdfContext);
        CGPDFContextClose(pdfContext);
        CGContextRelease(pdfContext);
        
        // write new PDFData in "outPutPDF.pdf" file in document directory
        NSString *pdfFilePath = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@/filePages/outPutPDF_%ld.pdf",kDataProcessingPdf, (long)i];
        [outputPDFData writeToFile:pdfFilePath atomically:YES];
        
    }
}

@end
