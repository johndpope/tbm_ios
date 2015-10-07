//
//  ZZHintsController.m
//  Zazo
//
//  Created by ANODA on 9/21/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//


#import "ZZHintsController.h"
#import "ZZHintsView.h"
#import "ZZHintsModelGenerator.h"
#import "ZZHintsViewModel.h"
#import "ZZHintsDomainModel.h"
#import "ZZGridUIConstants.h"

@interface ZZHintsController () <ZZHintsViewDelegate>

@property (nonatomic, strong) ZZHintsView* hintsView;

@end

@implementation ZZHintsController

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [[[UIApplication sharedApplication] keyWindow] addSubview:self.hintsView];
    }
    return self;
}

- (void)showHintWithType:(ZZHintsType)type focusFrame:(CGRect)focusFrame withIndex:(NSInteger)index formatParameter:(NSString*)parameter
{
    ZZHintsDomainModel *model = [ZZHintsModelGenerator generateHintModelForType:type];
    if (!ANIsEmpty(parameter))
    {
        model.formatParameter = parameter;
    }
    ZZHintsViewModel *viewModel = [ZZHintsViewModel viewModelWithItem:model];
    
    if (model.type == ZZHintsTypeDeleteFriendUsageHint)
    {
        focusFrame = CGRectMake(SCREEN_WIDTH - kEditFriendsButtonWidth, 0, kEditFriendsButtonWidth,kGridHeaderViewHeight);
    }
    
    [viewModel updateFocusFrame:focusFrame];
    
//    if ((model.type == ZZHintsTypeWelcomeNudgeUser) || model.type == ZZHintsTypeSendWelcomeHint)
//    {
        [self.hintsView updateWithHintsViewModel:viewModel andIndex:index];
//    }
//    else
//    {
//        [self.hintsView updateWithHintsViewModel:viewModel];
//    }
}

#pragma mark - Lazy Load

- (ZZHintsView*)hintsView
{
    if (!_hintsView)
    {
        _hintsView = [[ZZHintsView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _hintsView.delegate = self;
    }
    return _hintsView;
}

#pragma mark - HintView Delegate

- (void)hintViewHiddenWithType:(ZZHintsType)type
{
    [self.delegate hintWasDissmissedWithType:type];
}

//
//- (void)showHintWithModel:(ZZHintsDomainModel*)model forFocusFrame:(CGRect)focusFrame
//{
//    [self _clearView];
//    ZZHintsViewModel* viewModel = [ZZHintsViewModel viewModelWithItem:model];
//    [viewModel updateFocusFrame:focusFrame];
//    self.hintModel = model;
//    [self.hintsView updateWithHintsViewModel:viewModel];
//}
//
//#pragma mark - Private
//
//- (void)_clearView
//{
//    [_hintsView removeFromSuperview];
//    _hintsView = nil;
//}
//
//#pragma mark - Lazy Load
//
//- (ZZHintsView*)hintsView
//{
//    if (!_hintsView)
//    {
//        _hintsView = [[ZZHintsView alloc] initWithFrame:[UIScreen mainScreen].bounds];
//        [[[UIApplication sharedApplication] keyWindow] addSubview:_hintsView];
//    }
//    return _hintsView;
//}

@end
