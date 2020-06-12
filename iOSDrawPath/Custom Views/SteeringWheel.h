//
//  SteeringWheel.h
//  iOSDrawPath
//
//  Created by 尚雷勋 on 2020/6/9.
//  Copyright © 2020 Tongli Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define kSteeringWheelButtonStartTag 900

typedef NS_ENUM(NSUInteger, DispatchSourceTimerState) {
    DispatchSourceTimerStateNull,
    DispatchSourceTimerStateStarted,
    DispatchSourceTimerStateCancelled = DispatchSourceTimerStateNull
};

typedef NS_ENUM(NSUInteger, SteeringWheelButtonDirection) {
    SteeringWheelButtonDirectionUp = (NSUInteger)kSteeringWheelButtonStartTag,
    SteeringWheelButtonDirectionLeft,
    SteeringWheelButtonDirectionRight,
    SteeringWheelButtonDirectionDown
};

typedef void(^UIButtonTouchUpInsideEvent)(id _Nullable sender);

@interface SteeringWheel : UIView

@property (nonatomic, copy) UIButtonTouchUpInsideEvent btnTouchEvent;

@end

NS_ASSUME_NONNULL_END
