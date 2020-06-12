//
//  NSArray+MEME.m
//  GLP
//
//  Created by 尚雷勋 on 2020/4/28.
//  Copyright © 2020 GiANTLEAP Inc. All rights reserved.
//

#import "NSArray+MEME.h"

@implementation NSArray (MEME)

/// The next object of the referenced object in the array.
/// @param object The referenced object.
- (id)nextObjectOf:(id)object {
    
    NSUInteger index = [self indexOfObject:object];
    if (index == NSNotFound) {
        return nil;
    }
    // last object
    else if (index == self.count - 1) {
        return self.firstObject;
    }
    else {
        return self[index + 1];
    }
}

/// The previous object of the referenced object in the array.
/// @param object The referenced object.
- (id)previousObjectOf:(id)object {
    
    NSUInteger index = [self indexOfObject:object];
    if (index == NSNotFound) {
        return nil;
    }
    // first object
    else if (index == 0) {
        return self.lastObject;
    }
    else {
        return self[index - 1];
    }
}

/// The second object in the array.
/// @discussion If the array does not have two objects, return nil.
- (id)secondObject {
    if (self.count > 1) {
        return self[1];
    }
    return nil;
}

/// The third object in the array.
/// @discussion If the array does not have three objects, return nil.
- (id)thirdObject {
    if (self.count > 2) {
        return self[2];
    }
    return nil;
}

/// The second to last object in the array.
/// @discussion If the array does not have two objects, return nil.
- (id)secondToLastObject {
    if (self.count > 1) {
        NSUInteger lastIndex = self.count - 1;
        return self[lastIndex - 1];
    }
    return nil;
}

/// The third to last object in the array.
/// @discussion If the array does not have three objects, return nil.
- (id)thirdToLastObject {
    if (self.count > 2) {
        NSUInteger lastIndex = self.count - 1;
        return self[lastIndex - 2];
    }
    return nil;
}

@end
