//
//  CGGeometry+Extension.h
//  GLP
//
//  Created by 尚雷勋 on 2020/6/11.
//  Copyright © 2020 GiANTLEAP Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CGGeometry.h>

#ifndef CGGEOMETRY_EXTENSION_H_
#define CGGEOMETRY_EXTENSION_H_

CF_IMPLICIT_BRIDGING_ENABLED

CF_ASSUME_NONNULL_BEGIN

/// Returns a new rectangle with the change of width.
/// @param inRect Input rect structure.
/// @param deltaW Change of the width.
CG_INLINE CGRect CGRectChangeWidth(CGRect inRect, CGFloat deltaW) __attribute__ ((warn_unused_result));

CG_INLINE CGRect
CGRectChangeWidth(CGRect inRect, CGFloat deltaW)
{
    return CGRectMake(inRect.origin.x, inRect.origin.y, inRect.size.width + deltaW, inRect.size.height);
}

CG_INLINE CGRect
CGRectChangeHeight(CGRect inRect, CGFloat deltaH)
{
    return CGRectMake(inRect.origin.x, inRect.origin.y, inRect.size.width, inRect.size.height + deltaH);
}

CG_INLINE CGRect
CGRectChangeX(CGRect inRect, CGFloat deltaX)
{
    return CGRectMake(inRect.origin.x + deltaX, inRect.origin.y, inRect.size.width, inRect.size.height);
}

CG_INLINE CGRect
CGRectChangeY(CGRect inRect, CGFloat deltaY)
{
    return CGRectMake(inRect.origin.x, inRect.origin.y + deltaY, inRect.size.width, inRect.size.height);
}

CG_INLINE CGRect
CGRectNewWidth(CGRect inRect, CGFloat newW)
{
    return CGRectMake(inRect.origin.x, inRect.origin.y, newW, inRect.size.height);
}

CG_INLINE CGRect
CGRectNewHeight(CGRect inRect, CGFloat newH)
{
    return CGRectMake(inRect.origin.x, inRect.origin.y, inRect.size.width, newH);
}

CG_INLINE CGRect
CGRectNewX(CGRect inRect, CGFloat newX)
{
    return CGRectMake(newX, inRect.origin.y, inRect.size.width, inRect.size.height);
}

CG_INLINE CGRect
CGRectNewY(CGRect inRect, CGFloat newY)
{
    return CGRectMake(inRect.origin.x, newY, inRect.size.width, inRect.size.height);
}

CG_INLINE CGRect
CGRectMakeEx(CGPoint origin, CGSize size)
{
    return CGRectMake(origin.x, origin.y, size.width, size.height);
}

CF_ASSUME_NONNULL_END

CF_IMPLICIT_BRIDGING_DISABLED

#endif /* CGGEOMETRY_EXTENSION_H_ */

