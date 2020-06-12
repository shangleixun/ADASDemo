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
    
    InputStyleModel *model1 = [[InputStyleModel alloc] initWithTitle:NSLocalizedString(@"Vehicle width/cm", @"")];
    InputStyleModel *model2 = [[InputStyleModel alloc] initWithTitle:NSLocalizedString(@"Distance between camera and the center of vehicle/cm", @"")];
    InputStyleModel *model3 = [[InputStyleModel alloc] initWithTitle:NSLocalizedString(@"Distance between camera and the front bumper/cm", @"")];
    InputStyleModel *model4 = [[InputStyleModel alloc] initWithTitle:NSLocalizedString(@"Distance between camera and the front tire/cm", @"")];
    InputStyleModel *model5 = [[InputStyleModel alloc] initWithTitle:NSLocalizedString(@"Camera height (ground)/cm", @"")];
    InputStyleModel *model6 = [[InputStyleModel alloc] initWithTitle:NSLocalizedString(@"Camera lens/mm", @"")];
    InputStyleModel *model7 = [[InputStyleModel alloc] initWithTitle:NSLocalizedString(@"Camera sensor size/mm", @"")];
    InputStyleModel *model8 = [[InputStyleModel alloc] initWithTitle:NSLocalizedString(@"Vanishing point/pixel point", @"")];
    
    _dataSource = @[ model1, model2, model3, model4, model5, model6, model7, model8 ];
    
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
}

- (void)edgeHide {
    
    _isSelectedFieldVisible = [_tableView.indexPathsForVisibleRows containsObject:_selectedIndexPath];
    [[NSNotificationCenter defaultCenter] postNotificationName:UITextFieldsResignResponderNotification object:nil];
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
