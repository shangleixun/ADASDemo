//
//  SteeringWheel.m
//  iOSDrawPath
//
//  Created by 尚雷勋 on 2020/6/9.
//  Copyright © 2020 Tongli Inc. All rights reserved.
//

#import "SteeringWheel.h"
#import "Masonry.h"
#import "NSArray+MEME.h"

@interface SteeringWheel ()

@property (nonatomic, strong) UIButton *up, *left, *right, *down;

@property (nonatomic, assign) BOOL needRepeat;
@property (nonatomic, assign) DispatchSourceTimerState timerState;
@property (nonatomic, strong) dispatch_source_t long_press_timer;
@property (nonatomic, strong) UIImpactFeedbackGenerator *haptics;

@end

@implementation SteeringWheel

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addCustomViews];
        
        _long_press_timer = NULL;
        _timerState = DispatchSourceTimerStateNull;
    }
    return self;
}

- (void)addCustomViews {
    
    CGFloat width = CGRectGetWidth(self.frame);
    CGFloat height = CGRectGetHeight(self.frame);
    
    NSArray<NSString *> *normalImageNames = @[ @"arrow_up_c", @"arrow_left_c", @"arrow_right_c", @"arrow_down_c" ];
    NSArray<NSString *> *highlightedImageNames = @[ @"arrow_up_selected", @"arrow_left_selected", @"arrow_right_selected", @"arrow_down_selected" ];
    
    SEL sel = @selector(touchButtonEvent:);
    _up = [self gimmeButtonWithDirection:SteeringWheelButtonDirectionUp image:normalImageNames.firstObject highlightedImage:highlightedImageNames.firstObject action:sel];
    _left = [self gimmeButtonWithDirection:SteeringWheelButtonDirectionLeft image:normalImageNames.secondObject highlightedImage:highlightedImageNames.secondObject action:sel];
    _right = [self gimmeButtonWithDirection:SteeringWheelButtonDirectionRight image:normalImageNames.thirdObject highlightedImage:highlightedImageNames.thirdObject action:sel];
    _down = [self gimmeButtonWithDirection:SteeringWheelButtonDirectionDown image:normalImageNames.lastObject highlightedImage:highlightedImageNames.lastObject action:sel];
    
    [self addSubview:_up];
    [self addSubview:_left];
    [self addSubview:_right];
    [self addSubview:_down];
    
    CGFloat btn_width = width / 3.0;
    CGFloat btn_height = height / 3.0;
    
    [_up mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top);
        make.left.equalTo(self.mas_left).offset(width/3.0);
        make.width.mas_equalTo(btn_width);
        make.height.mas_equalTo(btn_height);
    }];
    
    [_left mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(height/3.0);
        make.left.equalTo(self.mas_left);
        make.width.mas_equalTo(btn_width);
        make.height.mas_equalTo(btn_height);
    }];
    
    [_right mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(height/3.0);
        make.right.equalTo(self.mas_right);
        make.width.mas_equalTo(btn_width);
        make.height.mas_equalTo(btn_height);
    }];
    
    [_down mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.mas_bottom);
        make.left.equalTo(self.mas_left).offset(width/3.0);
        make.width.mas_equalTo(btn_width);
        make.height.mas_equalTo(btn_height);
    }];
    
}

- (UIButton *)gimmeButtonWithDirection:(SteeringWheelButtonDirection)direction
                                 image:(NSString *)normal
                      highlightedImage:(NSString *)highlighted
                                action:(SEL)selector {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.tag = (NSInteger)direction;
    [btn setImage:[UIImage imageNamed:normal] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:highlighted] forState:UIControlStateHighlighted];
    [btn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressButtonEvent:)];
    [btn addGestureRecognizer:longPress];

    return btn;
}

- (void)touchButtonEvent:(UIButton *)sender {
    if (self.btnTouchEvent != nil) {
        self.btnTouchEvent(sender);
    }
    
    if (_haptics == nil) {
        _haptics = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium];
    }
    [_haptics prepare];
    
    if (@available(iOS 13.0, *)) {
        [_haptics impactOccurredWithIntensity:1.0];
    } else {
        [_haptics impactOccurred];
    }
    [_haptics prepare];
}

- (void)longPressButtonEvent:(UILongPressGestureRecognizer *)gesture {
    
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan: {
            if (_haptics == nil) {
                _haptics = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium];
            }
            [_haptics prepare];
            
            _needRepeat = YES;
            [self engineStartTimerWithView:gesture.view];
        }
            break;
        
        case UIGestureRecognizerStateEnded: {
            _needRepeat = NO;
            _haptics = nil;
        }
            break;
            
        default:
            break;
    }
}

- (void)engineStartTimerWithView:(__kindof UIView *)view {
    
    if (_long_press_timer == NULL) {
        
        _long_press_timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
        // 0.1 second is a little slow, so we use 0.05
        dispatch_source_set_timer(_long_press_timer, DISPATCH_TIME_NOW, 0.05 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
        
        __weak typeof(self) weakSelf = self;
        dispatch_source_set_event_handler(_long_press_timer, ^{
            
            if (weakSelf.needRepeat == NO) {
                // cancel the timer and set it to NULL
                dispatch_source_cancel(weakSelf.long_press_timer);
                weakSelf.long_press_timer = NULL;
                // cancelled == null
                weakSelf.timerState = DispatchSourceTimerStateCancelled;
            } else {
                if (@available(iOS 13.0, *)) {
                    [weakSelf.haptics impactOccurredWithIntensity:1.0];
                } else {
                    [weakSelf.haptics impactOccurred];
                }
                [weakSelf.haptics prepare];
                
                if (weakSelf.btnTouchEvent != nil) {
                    weakSelf.btnTouchEvent(view);
                }
            }
        });
        
        _timerState = DispatchSourceTimerStateNull;
    }
    
    // start the timer and change its state to started
    if (_timerState == DispatchSourceTimerStateNull) {
        dispatch_resume(_long_press_timer);
        _timerState = DispatchSourceTimerStateStarted;
    }
    
}

- (void)dealloc {
    
    if (_long_press_timer != NULL) {
        dispatch_source_cancel(_long_press_timer);
        _long_press_timer = NULL;
    }
}


@end
