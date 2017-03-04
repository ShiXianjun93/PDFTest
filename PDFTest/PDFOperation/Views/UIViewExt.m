/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import "UIViewExt.h"

CGPoint CGRectGetCenter(CGRect rect)
{
    CGPoint pt;
    pt.x = CGRectGetMidX(rect);
    pt.y = CGRectGetMidY(rect);
    return pt;
}

CGRect CGRectMoveToCenter(CGRect rect, CGPoint center)
{
    CGRect newrect = CGRectZero;
    newrect.origin.x = center.x-CGRectGetMidX(rect);
    newrect.origin.y = center.y-CGRectGetMidY(rect);
    newrect.size = rect.size;
    return newrect;
}

@implementation UIView (ViewGeometry)

// Retrieve and set the origin
- (CGPoint) origin
{
	return self.frame.origin;
}

- (void) setOrigin: (CGPoint) aPoint
{
	CGRect newframe = self.frame;
	newframe.origin = aPoint;
	self.frame = newframe;
}


// Retrieve and set the size
- (CGSize) size
{
	return self.frame.size;
}

- (void) setSize: (CGSize) aSize
{
	CGRect newframe = self.frame;
	newframe.size = aSize;
	self.frame = newframe;
}

// Query other frame locations
- (CGPoint) bottomRight
{
	CGFloat x = self.frame.origin.x + self.frame.size.width;
	CGFloat y = self.frame.origin.y + self.frame.size.height;
	return CGPointMake(x, y);
}

- (CGPoint) bottomLeft
{
	CGFloat x = self.frame.origin.x;
	CGFloat y = self.frame.origin.y + self.frame.size.height;
	return CGPointMake(x, y);
}

- (CGPoint) topRight
{
	CGFloat x = self.frame.origin.x + self.frame.size.width;
	CGFloat y = self.frame.origin.y;
	return CGPointMake(x, y);
}


// Retrieve and set height, width, top, bottom, left, right
- (CGFloat) height_ext
{
	return self.frame.size.height;
}

- (void) setHeight_ext:(CGFloat)height_ext
{
	CGRect newframe = self.frame;
	newframe.size.height = height_ext;
	self.frame = newframe;
}

- (CGFloat) width_ext
{
	return self.frame.size.width;
}

- (void) setWidth_ext:(CGFloat)width_ext
{
	CGRect newframe = self.frame;
	newframe.size.width = width_ext;
	self.frame = newframe;
}

- (CGFloat) top_ext
{
	return self.frame.origin.y;
}

- (void) setTop_ext:(CGFloat)top_ext
{
	CGRect newframe = self.frame;
	newframe.origin.y = top_ext;
	self.frame = newframe;
}

- (CGFloat) left_ext
{
	return self.frame.origin.x;
}

- (void) setLeft_ext:(CGFloat)left_ext
{
	CGRect newframe = self.frame;
	newframe.origin.x = left_ext;
	self.frame = newframe;
}

- (CGFloat) bottom_ext
{
	return self.frame.origin.y + self.frame.size.height;
}

- (void) setBottom_ext:(CGFloat)bottom_ext
{
	CGRect newframe = self.frame;
	newframe.origin.y = bottom_ext - self.frame.size.height;
	self.frame = newframe;
}

- (CGFloat) right_ext
{
	return self.frame.origin.x + self.frame.size.width;
}

- (void) setRight_ext:(CGFloat)right_ext
{
	CGFloat delta = right_ext - (self.frame.origin.x + self.frame.size.width);
	CGRect newframe = self.frame;
	newframe.origin.x += delta ;
	self.frame = newframe;
}

// Move via offset
- (void) moveBy: (CGPoint) delta
{
	CGPoint newcenter = self.center;
	newcenter.x += delta.x;
	newcenter.y += delta.y;
	self.center = newcenter;
}

// Scaling
- (void) scaleBy: (CGFloat) scaleFactor
{
	CGRect newframe = self.frame;
	newframe.size.width *= scaleFactor;
	newframe.size.height *= scaleFactor;
	self.frame = newframe;
}

// Ensure that both dimensions fit within the given size by scaling down
- (void) fitInSize: (CGSize) aSize
{
	CGFloat scale;
	CGRect newframe = self.frame;
	
	if (newframe.size.height && (newframe.size.height > aSize.height))
	{
		scale = aSize.height / newframe.size.height;
		newframe.size.width *= scale;
		newframe.size.height *= scale;
	}
	
	if (newframe.size.width && (newframe.size.width >= aSize.width))
	{
		scale = aSize.width / newframe.size.width;
		newframe.size.width *= scale;
		newframe.size.height *= scale;
	}
	
	self.frame = newframe;	
}
@end