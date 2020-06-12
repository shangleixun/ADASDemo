//
//  ViewController.m
//  iOSDrawPath
//
//  Created by 尚雷勋 on 2020/6/9.
//  Copyright © 2020 Tongli Inc. All rights reserved.
//

#import "ViewController.h"
#import "SteeringWheel.h"
#import "InputParametersView.h"
#import "Masonry.h"
#import "CGGeometry+Extension.h"

#define kPixelWidthMax 1280
#define kPixelHeightMax 720

@interface ViewController () {
    
    CGSize _v_size;
    CGPoint _input_origin;
    CGPoint _input_origin_hide;
    CGSize _input_size;
    
    CGPoint _selected_screen_point;
    CGPoint _selected_pixel_point;
    
    double _keyboardAnimDuration;
}

@property (nonatomic, strong) UIImageView *videoView;
@property (nonatomic, strong) UIImageView *touchPoint;
@property (nonatomic, strong) SteeringWheel *wheel;

@property (nonatomic, strong) UILabel *showInfo;

@property (nonatomic, strong) InputParametersView *inputView;

@property (nonatomic, assign) BOOL inputViewShowing;

@property (nonatomic, assign) CGRect inputViewFrame;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self addVideoViewAndWheelControl];
    [self addInputView];
    [self addViewControllerObservers:YES];
}

- (void)addInputView {
    
    CGFloat kScreenWidth = UIScreen.mainScreen.bounds.size.width;
    CGFloat kScreenHeight = UIScreen.mainScreen.bounds.size.height;
    
    _input_size = CGSizeMake(kScreenWidth*3/5, kScreenHeight - 162);
    _input_origin = CGPointMake(kScreenWidth/2.0-_input_size.width/2.0, 0);
    _input_origin_hide = CGPointMake(kScreenWidth + 30.0, 0);
    
    _inputView = [[InputParametersView alloc] initWithFrame:CGRectMakeEx(_input_origin_hide, _input_size)];
    
    __weak typeof(self) weakSelf = self;
    _inputView.frameChangedBlock = ^(CGRect newFrame) {
        CGRect new = [weakSelf.view convertRect:newFrame fromView:weakSelf.inputView];
        NSLog(@"textfield frame %@", NSStringFromCGRect(new));
    };
    _inputView.stateChangedBlock = ^(IPVState state) {
        
    };
    
    [self.view addSubview:_inputView];
}

- (void)addVideoViewAndWheelControl {
    
    CGFloat kScreenWidth = UIScreen.mainScreen.bounds.size.width;
    CGFloat kScreenHeight = UIScreen.mainScreen.bounds.size.height;
    _v_size = CGSizeMake(kScreenWidth, kScreenHeight);
    
    _videoView = [[UIImageView alloc] init];
    _videoView.userInteractionEnabled = YES;
    _videoView.image = [UIImage imageNamed:@"image"];
    _videoView.contentMode = UIViewContentModeScaleToFill;
    
    [self.view addSubview:_videoView];
    
    [_videoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self drawDottedLine];
    
    _wheel = [[SteeringWheel alloc] initWithFrame:CGRectMake(0, 0, 120, 120)];
    _wheel.backgroundColor = [UIColor colorWithRed:239/255.0 green:239/255.0 blue:239/255.0 alpha:1.0];
    _wheel.layer.cornerRadius = 60.0f;
    
    __weak typeof(self) weakSelf = self;
    _wheel.btnTouchEvent = ^(id  _Nullable sender) {
        UIView *senderView = (UIView *)sender;
        if (senderView != nil) {
            NSLog(@"点击了 或者长按了 %@", @(senderView.tag));
            [weakSelf moveTargetViewWithDirection:(SteeringWheelButtonDirection)senderView.tag];
        }
    };
    
    [_videoView addSubview:_wheel];
    
    [_wheel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_videoView.mas_right);
        make.bottom.equalTo(_videoView.mas_bottom);
        make.width.mas_equalTo(120);
        make.height.mas_equalTo(120);
    }];

    
    _touchPoint = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"corner"]];
    [_videoView addSubview:_touchPoint];
    _selected_pixel_point = CGPointZero;
    
    [self viewDrawLine];
    
    
    _showInfo = UILabel.new;
    _showInfo.backgroundColor = [UIColor colorWithRed:239/255.0 green:239/255.0 blue:239/255.0 alpha:1.0];
    _showInfo.frame = CGRectMake(100, 100, 150, 60);
    _showInfo.font = [UIFont systemFontOfSize:20.0 weight:UIFontWeightHeavy];
    
    _showInfo.layer.cornerRadius = 5.0;
    _showInfo.layer.borderWidth = 0;
    
    [_videoView addSubview:_showInfo];
    
    UIScreenEdgePanGestureRecognizer *edgePan = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(edgeShowInputView:)];
    edgePan.edges = UIRectEdgeRight;
    [self.view addGestureRecognizer:edgePan];
    
    
    
    
}

- (void)edgeShowInputView:(UIScreenEdgePanGestureRecognizer *)ges {
    
    switch (ges.state) {
        case UIGestureRecognizerStateBegan:
        {
            if (_inputViewShowing) {
                return;
            }
            
            __weak typeof(self) weakSelf = self;
            CGRect targetRect = CGRectMakeEx(_input_origin, _input_size);
            [UIView animateWithDuration:0.3 animations:^{
                weakSelf.inputView.frame = targetRect;
            } completion:^(BOOL finished) {
                weakSelf.inputViewShowing = YES;
                [weakSelf.inputView edgeShow];
            }];
        }
            break;
            
        default:
            break;
    }
}

// MARK:- Make move by touching video view

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    CGPoint point = [[touches anyObject] locationInView:self.view];
    point = [_videoView.layer convertPoint:point fromLayer:self.view.layer];
    if ([_videoView.layer containsPoint:point]) {
        
        if (_inputViewShowing) {
            CGRect targetRect = CGRectMakeEx(_input_origin_hide, _input_size);
            __weak typeof(self) weakSelf = self;
            
            [UIView animateWithDuration:0.3 animations:^{
                weakSelf.inputView.frame = targetRect;
                [weakSelf.inputView edgeHide];
            } completion:^(BOOL finished) {
                weakSelf.inputViewShowing = NO;
            }];
            
            return;
        }
        
        CGPoint wheelPoint = [_wheel.layer convertPoint:point fromLayer:_videoView.layer];
        if ([_wheel.layer containsPoint:wheelPoint]) {
            return;
        }
        
        NSLog(@"点击的点是：%@", NSStringFromCGPoint(point));
        CGFloat pixelWidthMax = (CGFloat)kPixelWidthMax;
        CGFloat pixelHeightMax = (CGFloat)kPixelHeightMax;
        CGFloat _x_p = point.x / _v_size.width * pixelWidthMax;
        CGFloat _y_p = point.y / _v_size.height * pixelHeightMax;
        
        _x_p = ceil(_x_p);
        _y_p = ceil(_y_p);
        if (_x_p > pixelWidthMax) {
            _x_p = pixelWidthMax;
        }
        if (_y_p > pixelHeightMax) {
            _y_p = pixelHeightMax;
        }
        
        [self moveTargetViewToPixelX:_x_p Y:_y_p];
        
        NSLog(@"实际像素点：%@", NSStringFromCGPoint(CGPointMake(_x_p, _y_p)));
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    CGPoint point = [[touches anyObject] locationInView:self.view];
    point = [_videoView.layer convertPoint:point fromLayer:self.view.layer];
    if ([_videoView.layer containsPoint:point]) {
        
        if (_inputViewShowing) {
            return;
        }
        
        CGPoint wheelPoint = [_wheel.layer convertPoint:point fromLayer:_videoView.layer];
        if ([_wheel.layer containsPoint:wheelPoint]) {
            return;
        }
        
        NSLog(@"移动的点是：%@", NSStringFromCGPoint(point));
        CGFloat pixelWidthMax = (CGFloat)kPixelWidthMax;
        CGFloat pixelHeightMax = (CGFloat)kPixelHeightMax;
        CGFloat _x_p = point.x / _v_size.width * pixelWidthMax;
        CGFloat _y_p = point.y / _v_size.height * pixelHeightMax;
        
        _x_p = ceil(_x_p);
        _y_p = ceil(_y_p);
        if (_x_p > pixelWidthMax) {
            _x_p = pixelWidthMax;
        }
        if (_y_p > pixelHeightMax) {
            _y_p = pixelHeightMax;
        }
        
        [self moveTargetViewToPixelX:_x_p Y:_y_p];
        
        NSLog(@"实际像素点：%@", NSStringFromCGPoint(CGPointMake(_x_p, _y_p)));
    }
    
}

// MARK:- Make move by touching steering wheel's button

- (void)moveTargetViewWithDirection:(SteeringWheelButtonDirection)direc {
    
    CGFloat pointx = _selected_pixel_point.x;
    CGFloat pointy = _selected_pixel_point.y;
    
    CGFloat pixelWidthMax = (CGFloat)kPixelWidthMax;
    CGFloat pixelHeightMax = (CGFloat)kPixelHeightMax;
    
    switch (direc) {
        case SteeringWheelButtonDirectionUp:
        {
            pointy = pointy - 1;
            if (pointy < 0) {
                pointy = 0;
            }
        }
            break;
        
        case SteeringWheelButtonDirectionLeft:
        {
            pointx = pointx - 1;
            if (pointx < 0) {
                pointx = 0;
            }
        }
            break;
            
        case SteeringWheelButtonDirectionRight:
        {
            pointx = pointx + 1;
            if (pointx > pixelWidthMax) {
                pointx = pixelWidthMax;
            }
        }
            break;
        
        case SteeringWheelButtonDirectionDown:
        {
            pointy = pointy + 1;
            if (pointy > pixelHeightMax) {
                pointy = pixelHeightMax;
            }
        }
            break;
            
        default:
            break;
    }
    
    [self moveTargetViewToPixelX:pointx Y:pointy];
}

- (void)moveTargetViewToPixelX:(CGFloat)x Y:(CGFloat)y {
    
    _selected_pixel_point = CGPointMake(x, y);
    NSLog(@"new point x:%.3f y:%.3f", x, y);
    
    CGFloat targetScreenPointX = x * _v_size.width / (CGFloat)kPixelWidthMax;
    CGFloat targetScreenPointY = y * _v_size.height / (CGFloat)kPixelHeightMax;
    
    _selected_screen_point = CGPointMake(targetScreenPointX, targetScreenPointY);
    _touchPoint.center = CGPointMake(targetScreenPointX, targetScreenPointY);
    
    NSString *text =  [NSString stringWithFormat:@"{x:%.3f,y:%.3f}", x, y];
    
    CGRect txtRect = [text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 60) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName:[UIFont systemFontOfSize:20 weight:UIFontWeightHeavy] } context:NULL];
    
    CGRect newFrame = CGRectMake(100, 100, ceil(CGRectGetWidth(txtRect)), 60);
    
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.2 animations:^{
        weakSelf.showInfo.frame = newFrame;
        weakSelf.showInfo.text = text;
    }];
}

// MARK:- Draw lines

- (void)drawDottedLine {
    CAShapeLayer *dotteShapeLayer = [CAShapeLayer layer];
    CGMutablePathRef dotteShapePath = CGPathCreateMutable();
    // 设置虚线颜色为 blackColor
    [dotteShapeLayer setStrokeColor:UIColor.orangeColor.CGColor];
    // 设置虚线宽度
    dotteShapeLayer.lineWidth = 2.0f ;
    // 10=线的宽度 5=每条线的间距
    NSArray<NSNumber *> *dotteShapeArr = @[ @(10), @(5) ];
    [dotteShapeLayer setLineDashPattern:dotteShapeArr];
    CGPathMoveToPoint(dotteShapePath, NULL, 50, 50);
    CGPathAddLineToPoint(dotteShapePath, NULL, 100, 100);
    [dotteShapeLayer setPath:dotteShapePath];
    CGPathRelease(dotteShapePath);
    // 把绘制好的虚线添加上来
    [self.videoView.layer addSublayer:dotteShapeLayer];
}

- (void)viewDrawLine {
    
    CGFloat h1_ratio = 300.0 / 720.0;
    CGFloat h2_ratio = 420.0 / 720.0;
    CGFloat hcenter_ratio = 0.5;
    CGFloat vcenter_ratio = 0.5;
    
    CGFloat width = _v_size.width;
    CGFloat height = _v_size.height;
    
    CGPoint h1_start = CGPointMake(0, height * h1_ratio);
    CGPoint h1_end = CGPointMake(width, height * h1_ratio);
    CGPoint h2_start = CGPointMake(0, height * h2_ratio);
    CGPoint h2_end = CGPointMake(width, height * h2_ratio);
    
    CGPoint hcenter_start = CGPointMake(0, hcenter_ratio * height);
    CGPoint hcenter_end = CGPointMake(width, hcenter_ratio * height);
    CGPoint vcenter_start = CGPointMake(vcenter_ratio * width, 0);
    CGPoint vcenter_end = CGPointMake(vcenter_ratio * width, height);
    
    // 线的路径
    UIBezierPath *linePath = [UIBezierPath bezierPath];
    [linePath moveToPoint:h1_start];
    [linePath addLineToPoint:h1_end];
    
    CAShapeLayer *lineLayer = [CAShapeLayer layer];
    lineLayer.lineWidth = 1.0;
    lineLayer.strokeColor = [UIColor orangeColor].CGColor;
    lineLayer.path = linePath.CGPath;
    lineLayer.fillColor = nil;
    [_videoView.layer addSublayer:lineLayer];
    
    // 线的路径
    UIBezierPath *linePath2 = [UIBezierPath bezierPath];
    [linePath2 moveToPoint:h2_start];
    [linePath2 addLineToPoint:h2_end];
    
    CAShapeLayer *lineLayer2 = [CAShapeLayer layer];
    lineLayer2.lineWidth = 1.0;
    lineLayer2.strokeColor = [UIColor orangeColor].CGColor;
    lineLayer2.path = linePath2.CGPath;
    // lineLayer2.lineDashPattern = @[ @(5), @(2) ];
    lineLayer2.fillColor = nil;
    [_videoView.layer addSublayer:lineLayer2];
    
    // 线的路径
    UIBezierPath *linePath3 = [UIBezierPath bezierPath];
    [linePath3 moveToPoint:hcenter_start];
    [linePath3 addLineToPoint:hcenter_end];
    
    CAShapeLayer *lineLayer3 = [CAShapeLayer layer];
    lineLayer3.lineWidth = 1.0;
    lineLayer3.strokeColor = [UIColor redColor].CGColor;
    lineLayer3.path = linePath3.CGPath;
    lineLayer3.lineDashPattern = @[ @(5), @(2) ];
    lineLayer3.fillColor = nil;
    [_videoView.layer addSublayer:lineLayer3];
    
    // 线的路径
    UIBezierPath *linePath4 = [UIBezierPath bezierPath];
    [linePath4 moveToPoint:vcenter_start];
    [linePath4 addLineToPoint:vcenter_end];
    
    CAShapeLayer *lineLayer4 = [CAShapeLayer layer];
    lineLayer4.lineWidth = 1.0;
    lineLayer4.strokeColor = [UIColor redColor].CGColor;
    lineLayer4.path = linePath4.CGPath;
    lineLayer4.lineDashPattern = @[ @(5), @(2) ];
    lineLayer4.fillColor = nil;
    [_videoView.layer addSublayer:lineLayer4];
    
    
}


- (void)keyboardWillShow:(NSNotification *)notif {
    NSDictionary *userInfo = notif.userInfo;
    BOOL isMyKeyboard = [userInfo[UIKeyboardIsLocalUserInfoKey] boolValue];
    if (isMyKeyboard) {
        CGRect keyboardEndFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
        _keyboardAnimDuration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        
        CGFloat kScreenHeight = UIScreen.mainScreen.bounds.size.height;
        
        CGFloat keyboardH = CGRectGetHeight(keyboardEndFrame);
        CGFloat targetHeight = kScreenHeight - keyboardH;
        
        _input_size = CGSizeMake(_input_size.width, targetHeight);
        
        __weak typeof(self) weakSelf = self;
        CGRect newFrame = CGRectMakeEx(_input_origin, _input_size);

        [UIView animateWithDuration:_keyboardAnimDuration animations:^{
            weakSelf.inputView.frame = newFrame;
        }];
    }
}

- (void)keyboardWillHide:(NSNotification *)notif {
    
}

/// Add all the observers of the current view controller.
/// @param isAdd If YES, do add operation, NO, remove.
- (void)addViewControllerObservers:(BOOL)isAdd {
    
    if (isAdd) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    } else {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}


@end
