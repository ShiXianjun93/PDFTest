//
//  LQView111.m
//  ESuperVisionProject
//
//  Created by liuqiang on 16/5/31.
//  Copyright © 2016年 dhyt. All rights reserved.
//

#import "LQView111.h"
#import "LQBezierPath.h"

@interface LQView111()

@property (nonatomic,strong) NSMutableArray *paths;
@end

@implementation LQView111
//懒加载很重要
- (NSMutableArray *)paths
{
    if (!_paths) {
        _paths = [NSMutableArray array];
    }
    return _paths;
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
    for (int i=0; i<self.paths.count; i++) {
        LQBezierPath *path = self.paths[i];
        [path.lineColor set];
        [path setLineCapStyle:kCGLineCapRound];
        [path setLineJoinStyle:kCGLineJoinRound];
        [path stroke];
    }
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    self.Have_path = YES;
    UITouch *t = [touches anyObject];
    CGPoint p = [t locationInView:t.view];
    [self recordMarkWithPoint:p];
    LQBezierPath *path = [[LQBezierPath alloc] init];
    [path moveToPoint:p];
    // 设置线宽
//    [path setLineWidth:self.lineWidth];
    
//    使用block来传值
    if (self.lineWidthBlock) {
        [path setLineWidth:(self.lineWidthBlock()*10)];
    }else{
        [path setLineWidth:1];
    }
    
    [path setLineColor:self.lineColor];
    [self.paths addObject:path];

}
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *t = [touches anyObject];
    CGPoint p = [t locationInView:t.view];
    [self recordMarkWithPoint:p];
    
    [self.paths.lastObject addLineToPoint:p];
    
    [self setNeedsDisplay];
}
-(void)clear
{
    self.Have_path = NO;
    [self.paths removeAllObjects];
    [self setNeedsDisplay];
    
    [self resetRecordMark];
}
-(void)back
{
    [self.paths removeLastObject];
    [self setNeedsDisplay];
}
-(void)erase{
    self.lineColor = self.backgroundColor;
    [self setNeedsDisplay];
}
-(void)save
{
       
}

/** 重置边界记录 */
- (void)resetRecordMark
{
    _maxTop = _maxLeft = NSIntegerMax;
    _maxRight = _maxBottom = 0;
}

/** 记录边界 */
- (void)recordMarkWithPoint:(CGPoint)point
{
    _maxTop = point.y < _maxTop ? point.y : _maxTop;
    _maxLeft = point.x < _maxLeft ? point.x : _maxLeft;
    _maxRight = point.x > _maxRight ? point.x : _maxRight;
    _maxBottom = point.y > _maxBottom ? point.y : _maxBottom;
}

@end
