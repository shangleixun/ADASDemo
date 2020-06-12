//
//  InputStyleCell.h
//  iOSDrawPath
//
//  Created by 尚雷勋 on 2020/6/11.
//  Copyright © 2020 Tongli Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXTERN NSNotificationName const UITextFieldsResignResponderNotification;

/// 在输入开始和输入内容即将结束时，更新内容。
/// @param view 输入视图，这里是 TextField.
/// @param justShow 是否只是展示出来了 TextField.
typedef void(^UIInputViewInputHandler)(id _Nullable view, BOOL justShow);
/// 移动到下一个的回调。
typedef void(^MoveToNextField)(id _Nullable view);

@interface InputStyleModel : NSObject

/// Key is unique.
@property (nonatomic, copy) NSString *key;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *value;
@property (nonatomic, copy) NSString *unit;
@property (nonatomic, assign) BOOL canInput;

- (instancetype)initWithKey:(NSString *)key title:(NSString *)title;

@end

@interface InputStyleCell : UITableViewCell

@property (nonatomic, strong) UILabel *inputTitle;
@property (nonatomic, copy) NSString *inputText;
@property (nonatomic, strong) UITextField *inputField;

@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, strong) InputStyleModel *model;
@property (nonatomic, copy) UIInputViewInputHandler inputHandler;

@end

NS_ASSUME_NONNULL_END
