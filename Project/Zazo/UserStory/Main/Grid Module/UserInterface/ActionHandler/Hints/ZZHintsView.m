//
//  ZZHintsView.m
//  Zazo
//
//  Created by ANODA on 9/21/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

@import QuartzCore;
#import "ZZHintsView.h"
#import "TBMHintArrow.h"
#import "ZZHintsViewModel.h"
#import "ZZHintsGotItView.h"

@interface ZZHintsView ()

@property (nonatomic, strong) ZZHintsGotItView *gotItView;
@property (nonatomic, assign) ZZHintsBottomImageType currentBottomImageType;

@end

@implementation ZZHintsView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tutorialViewDidTap:)];
        [self addGestureRecognizer:tapRecognizer];
    }
    
    return self;
}


- (void)updateWithHintsViewModel:(ZZHintsViewModel*)viewModel
{
    //TODO: remove from superview
    
    [self showFocusOnFrame:[viewModel focusFrame]];

    TBMHintArrow *hintView = [TBMHintArrow arrowWithText:[viewModel text]
                                               curveKind:(NSInteger)[viewModel arrowDirection]
                                              arrowPoint:[viewModel generateArrowFocusPoint]
                                                   angle:[viewModel arrowAngle]
                                                  hidden:[viewModel hidesArrow]
                                                   frame:[UIScreen mainScreen].bounds];
    [self addSubview:hintView];


    if ([viewModel bottomImageType] != ZZHintsBottomImageTypeNone)
    {
        self.currentBottomImageType = [viewModel bottomImageType];
        [self.gotItView updateWithType:[viewModel bottomImageType]];
    }
}


//- (void)updateWithHintsViewModel:(ZZHintsViewModel*)viewModel andIndex:(NSInteger)index
//{
//    [self showFocusOnFrame:[viewModel focusFrame]];
//
//    TBMHintArrow *hintView = [TBMHintArrow arrowWithText:[viewModel text]
//                                               curveKind:(NSInteger)[viewModel arrowDirectionForIndex:index]
//                                              arrowPoint:[viewModel generateArrowFocusPointForIndex:index]
//                                                   angle:[viewModel arrowAngleForIndex:index]
//                                                  hidden:[viewModel hidesArrow]
//                                                   frame:[UIScreen mainScreen].bounds];
//    [self addSubview:hintView];
//
//
//}

- (void)showFocusOnFrame:(CGRect)focusFrame
{
    UIBezierPath *overlayPath = [UIBezierPath bezierPathWithRect:self.frame];
    
    CGRect highlightFrame = focusFrame;
    
    UIBezierPath *transparentPath = [UIBezierPath bezierPathWithRect:highlightFrame];
    [overlayPath appendPath:transparentPath];
    [overlayPath setUsesEvenOddFillRule:YES];
    
    CAShapeLayer *fillLayer = [CAShapeLayer layer];
    fillLayer.path = overlayPath.CGPath;
    fillLayer.fillRule = kCAFillRuleEvenOdd;
    fillLayer.fillColor = [[UIColor blackColor] colorWithAlphaComponent:0.65].CGColor;
    
    [self.layer addSublayer:fillLayer];
}

- (void)tutorialViewDidTap:(UITapGestureRecognizer *)sender
{
    [self dismissHintsView];
}

- (void)dismissHintsView
{
    [self removeFromSuperview];
}

#pragma mark - Lazy Load

- (ZZHintsGotItView*)gotItView
{
    if (!_gotItView)
    {
        _gotItView = [ZZHintsGotItView new];
        
        UIImage* gotItImage;
        CGFloat width;
        
        if (self.currentBottomImageType == ZZHintsBottomImageTypePresent)
        {
            gotItImage = [UIImage imageNamed:@"present-icon"];
            width = [UIScreen mainScreen].bounds.size.width / 4;
        }
        else
        {
            gotItImage = [UIImage imageNamed:@"circle-white"];
            width = [UIScreen mainScreen].bounds.size.width / 2.5;
        }
        CGFloat aspectRatio = gotItImage.size.height / gotItImage.size.width;
        CGFloat height = width * aspectRatio;
        [self addSubview:_gotItView];
        
        [_gotItView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@(width));
            make.height.equalTo(@(height));
            make.bottom.equalTo(self.mas_bottom).with.offset(-50);
            make.centerX.equalTo(self.mas_centerX);
        }];
    }
    
    return _gotItView;
}


@end
