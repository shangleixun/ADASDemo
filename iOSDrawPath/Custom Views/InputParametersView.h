//
//  InputParametersView.h
//  iOSDrawPath
//
//  Created by 尚雷勋 on 2020/6/11.
//  Copyright © 2020 Tongli Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InputStyleCell.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, IPVState) {
    IPVStateNull,
    IPVStateAllEmpty,
    IPVStateHalfFilled,
    IPVStateCanSend
};

typedef void(^UIFrameChanged)(CGRect newFrame);
typedef void(^IPVTotalStateChanged)(IPVState state);

@interface InputParametersView : UIView

@property (nonatomic, copy) UIFrameChanged frameChangedBlock;
@property (nonatomic, copy) IPVTotalStateChanged stateChangedBlock;

- (void)updateModelByKey:(NSString *)key withValue:(NSString *)value;

- (void)edgeShow;
- (void)edgeHide;

@end

NS_ASSUME_NONNULL_END
