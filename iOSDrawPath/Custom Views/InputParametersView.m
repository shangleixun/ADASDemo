//
//  InputParametersView.m
//  iOSDrawPath
//
//  Created by 尚雷勋 on 2020/6/11.
//  Copyright © 2020 Tongli Inc. All rights reserved.
//

#import "InputParametersView.h"
#import "Masonry.h"
#import "NSArray+MEME.h"

// MARK:- InputParametersView

static NSString *INPUT_CELL_ID = @"InputStyleCell";

@interface InputParametersView ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray<InputStyleModel *> *dataSource;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UITextField *selectedField;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@property (nonatomic, assign) BOOL isSelectedFieldVisible;

@property (nonatomic, strong) UIButton *sendButton;

@end


@implementation InputParametersView


- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        [self addSubTableView];
    }
    return self;
}

- (void)addSubTableView {
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.estimatedRowHeight = UITableViewAutomaticDimension;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.backgroundColor = UIColor.orangeColor;
    [_tableView registerClass:[InputStyleCell class] forCellReuseIdentifier:INPUT_CELL_ID];
    
    
    _sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _sendButton.frame = CGRectMake(0, 0, 10 /* table view will expand width to fit */, 60);
    _sendButton.titleLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:40];
    [_sendButton setTitle:NSLocalizedString(@"Send", @"") forState:UIControlStateNormal];
    [_sendButton setTitleColor:UIColor.grayColor forState:UIControlStateNormal];
    
    _tableView.tableFooterView = _sendButton;
    
    [self addSubview:_tableView];
    
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    NSArray<NSString *> *keys = @[ @"vhwd", @"dccv", @"dcfb", @"dcft", @"camh", @"caml", @"cams", @"vanp" ];
    NSArray<NSString *> *titles = @[ NSLocalizedString(@"Vehicle width", @""),
                                     NSLocalizedString(@"Distance between camera and the center of vehicle", @""),
                                     NSLocalizedString(@"Distance between camera and the front bumper", @""),
                                     NSLocalizedString(@"Distance between camera and the front tire", @""),
                                     NSLocalizedString(@"Camera height (ground)", @""),
                                     NSLocalizedString(@"Camera lens", @""),
                                     NSLocalizedString(@"Camera sensor size", @""),
                                     NSLocalizedString(@"Vanishing point", @"") ];
    
    NSArray<NSNumber *> *canInputs = @[ @(YES), @(YES), @(YES), @(YES), @(YES), @(YES), @(YES), @(YES) ];
    NSArray<NSString *> *units = @[ @"|㎝", @"|㎝", @"|㎝", @"|㎝", @"|㎝", @"|㎜", @"|㎛", @"|x,y" ];
    
    NSMutableArray<InputStyleModel *> *models = [NSMutableArray arrayWithCapacity:20];
    for (NSUInteger idx = 0; idx < keys.count; ++idx) {
        InputStyleModel *model = [[InputStyleModel alloc] initWithKey:keys[idx] title:titles[idx]];
        model.unit = units[idx];
        model.canInput = canInputs[idx].boolValue;
        [models addObject:model];
    }
    
    _dataSource = [models copy];
}

// MARK:- Table view data source and delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 8;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    InputStyleCell *cell = [tableView dequeueReusableCellWithIdentifier:INPUT_CELL_ID forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.indexPath = indexPath;
    cell.model = _dataSource[indexPath.row];
    
    if (indexPath.row == 0) {
        _selectedField = cell.inputField;
    }
    
    __weak typeof(self) weakSelf = self;
    cell.inputHandler = ^(id  _Nullable view, BOOL justShow) {
        
        InputStyleCell *backCell = (InputStyleCell *)view;
        
        if (backCell != nil && [backCell isMemberOfClass:[InputStyleCell class]]) {
            weakSelf.selectedField = backCell.inputField;
            weakSelf.selectedIndexPath = backCell.indexPath;
            
            if (justShow) {
                [weakSelf showingCellFrameChangedWithIndexPath:backCell.indexPath];
            } else {
                weakSelf.dataSource[backCell.indexPath.row].value = [backCell.inputText copy];
                [weakSelf checkCanSendState];
            }
        }
    };
    
    return cell;
}

// MARK:- Useful methods

- (void)checkCanSendState {
    
    __block NSUInteger valuedCount = 0;
    [_dataSource enumerateObjectsUsingBlock:^(InputStyleModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.value.length > 0) {
            valuedCount++;
        }
    }];
    
    if (self.stateChangedBlock) {
        if (valuedCount == 0) {
            self.stateChangedBlock(IPVStateAllEmpty);
            [_sendButton setTitleColor:UIColor.grayColor forState:UIControlStateNormal];
        } else if (valuedCount < _dataSource.count) {
            self.stateChangedBlock(IPVStateHalfFilled);
            [_sendButton setTitleColor:UIColor.grayColor forState:UIControlStateNormal];
        } else {
            self.stateChangedBlock(IPVStateCanSend);
            [_sendButton setTitleColor:UIColor.greenColor forState:UIControlStateNormal];
        }
    }
}

- (void)showingCellFrameChangedWithIndexPath:(NSIndexPath *)indexPath {
    CGRect cellRect = [_tableView rectForRowAtIndexPath:indexPath];
    if (self.frameChangedBlock) {
        self.frameChangedBlock(cellRect);
    }
}

- (void)edgeShow {
    
    if (_isSelectedFieldVisible) {
        if ([self.selectedField canBecomeFirstResponder]) {
            [self.selectedField becomeFirstResponder];
        }
    } else {
        InputStyleCell *firstCell = [_tableView visibleCells].secondObject;
        if (firstCell != nil && [firstCell.inputField canBecomeFirstResponder]) {
            [firstCell.inputField becomeFirstResponder];
        }
    }
    
    [UIView performWithoutAnimation:^{
        [_tableView reloadRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:_dataSource.count-1 inSection:0] ] withRowAnimation:UITableViewRowAnimationNone];
    }];
    // If the reload action has filled all textfields, change send button's state
    [self checkCanSendState];
}

- (void)edgeHide {
    
    _isSelectedFieldVisible = [_tableView.indexPathsForVisibleRows containsObject:_selectedIndexPath];
    [[NSNotificationCenter defaultCenter] postNotificationName:UITextFieldsResignResponderNotification object:nil];
}

- (void)updateModelByKey:(NSString *)key withValue:(NSString *)value {
    
    [_dataSource enumerateObjectsUsingBlock:^(InputStyleModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.key isEqualToString:key]) {
            obj.value = value;
            *stop = YES;
        }
    }];
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
