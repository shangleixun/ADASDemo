//
//  InputStyleCell.m
//  iOSDrawPath
//
//  Created by 尚雷勋 on 2020/6/11.
//  Copyright © 2020 Tongli Inc. All rights reserved.
//

#import "InputStyleCell.h"
#import "Masonry.h"

NSNotificationName const UITextFieldsResignResponderNotification = @"UITextFieldsResignResponserNotification";

// MARK:- InputStyleModel

@implementation InputStyleModel

- (instancetype)initWithKey:(NSString *)key title:(NSString *)title {
    if (self = [super init]) {
        _key = [key copy];
        _title = [title copy];
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@:%p key: %@, title:%@, value:%@", NSStringFromClass([self class]), &self, _key, _title, _value];
}

@end


@interface InputStyleCell ()<UITextFieldDelegate>

@end

@implementation InputStyleCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self addCustomViews];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resignResponder) name:UITextFieldsResignResponderNotification object:nil];
    }
    return self;
}

- (void)addCustomViews {
    _inputTitle = UILabel.new;
    _inputTitle.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:13];
    _inputTitle.numberOfLines = 0;
    _inputTitle.layer.cornerRadius = 6.0;
    
    _inputField = [[UITextField alloc] init];
    _inputField.borderStyle = UITextBorderStyleRoundedRect;
    _inputField.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:16];
    _inputField.keyboardType = UIKeyboardTypeDecimalPad;
    _inputField.delegate = self;
    
    UILabel *rightView = UILabel.new;
    rightView.frame = CGRectMake(0, 0, 10, 40);
    rightView.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:17];
    
    _inputField.rightView = rightView;
    _inputField.rightViewMode = UITextFieldViewModeAlways;
    
    [_inputField addTarget:self action:@selector(textFieldTextDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    [self.contentView addSubview:_inputTitle];
    [self.contentView addSubview:_inputField];
    
    CGFloat padding = 8.0;
    [_inputTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top).offset(padding);
        make.left.equalTo(self.contentView.mas_left).offset(2*padding);
        make.width.mas_equalTo(200);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-padding);
    }];
    
    [_inputField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top).offset(padding);
        make.left.equalTo(self.inputTitle.mas_right).offset(padding/2.0);
        make.right.equalTo(self.contentView.mas_right).offset(-padding * 2);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-padding);
    }];
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (self.inputHandler) {
        self.inputHandler(self, YES);
    }
    return YES;
}

- (void)textFieldTextDidChange:(UITextField *)sender {
    _inputText = sender.text;
    if (self.inputHandler) {
        self.inputHandler(self, NO);
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    // 做切换到下一个的操作
    
    return YES;
}

- (void)setModel:(InputStyleModel *)model {
    _model = model;
    
    if (_model.title.length > 0) {
        _inputTitle.text = _model.title;
    } else {
        _inputTitle.text = @"";
    }
    
    if (_model.value.length > 0) {
        _inputField.text = _model.value;
        _inputText = _model.value;
    } else {
        _inputField.text = @"";
    }
    
    _inputField.userInteractionEnabled = model.canInput;
    
    UILabel *rightView = (UILabel *)_inputField.rightView;
    rightView.text = _model.unit;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
    
}

- (void)resignResponder {
    [self.inputField resignFirstResponder];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
