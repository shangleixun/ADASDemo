//
//  InputParametersView.m
//  iOSDrawPath
//
//  Created by 尚雷勋 on 2020/6/11.
//  Copyright © 2020 Tongli Inc. All rights reserved.
//

#import "InputParametersView.h"
#import "Masonry.h"

// MARK:- InputParametersView

static NSString *INPUT_CELL_ID = @"InputStyleCell";

@interface InputParametersView ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UITextField *selectedField;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

@property (nonatomic, assign) BOOL isSelectedFieldVisible;

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
    
    [self addSubview:_tableView];
    
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    NSArray<NSString *> *keys = @[ @"vhwd", @"dccv", @"dcfb", @"dcft", @"camh", @"caml", @"cams", @"vanp" ];
    NSArray<NSString *> *titles = @[ NSLocalizedString(@"Vehicle width/cm", @""),
                                     NSLocalizedString(@"Distance between camera and the center of vehicle/cm", @""),
                                     NSLocalizedString(@"Distance between camera and the front bumper/cm", @""),
                                     NSLocalizedString(@"Distance between camera and the front tire/cm", @""),
                                     NSLocalizedString(@"Camera height (ground)/cm", @""),
                                     NSLocalizedString(@"Camera lens/mm", @""),
                                     NSLocalizedString(@"Camera sensor size/mm", @""),
                                     NSLocalizedString(@"Vanishing point/pixel point", @"") ];
    
    NSMutableArray<InputStyleModel *> *models = [NSMutableArray arrayWithCapacity:20];
    for (NSUInteger idx = 0; idx < keys.count; ++idx) {
        InputStyleModel *model = [[InputStyleModel alloc] initWithKey:keys[idx] title:titles[idx]];
        [models addObject:model];
    }
    
    _dataSource = [models copy];
}

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
        } else if (valuedCount < _dataSource.count) {
            self.stateChangedBlock(IPVStateHalfFilled);
        } else {
            self.stateChangedBlock(IPVStateCanSend);
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
        InputStyleCell *firstCell = [_tableView visibleCells].firstObject;
        if (firstCell != nil && [firstCell.inputField canBecomeFirstResponder]) {
            [firstCell.inputField becomeFirstResponder];
        }
    }
    
    [UIView performWithoutAnimation:^{
        [_tableView reloadRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:_dataSource.count-1 inSection:0] ] withRowAnimation:UITableViewRowAnimationNone];
    }];
    
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
