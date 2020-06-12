//
//  NSArray+MEME.h
//  GLP
//
//  Created by 尚雷勋 on 2020/4/28.
//  Copyright © 2020 GiANTLEAP Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray<__covariant ObjectType> (MEME)

- (nullable ObjectType)nextObjectOf:(ObjectType)object;
- (nullable ObjectType)previousObjectOf:(ObjectType)object;

- (nullable ObjectType)secondObject;
- (nullable ObjectType)thirdObject;
- (nullable ObjectType)secondToLastObject;
- (nullable ObjectType)thirdToLastObject;

@end

NS_ASSUME_NONNULL_END
