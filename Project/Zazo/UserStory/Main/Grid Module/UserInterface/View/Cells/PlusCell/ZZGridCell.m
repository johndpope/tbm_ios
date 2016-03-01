//
//  ZZGridCollectionCell.m
//  Zazo
//
//  Created by ANODA on 12/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZGridCell.h"
#import "ZZGridStateView.h"
#import "ZZGridStateViewNudge.h"
#import "ZZGridStateViewRecord.h"
#import "ZZGridStateViewPreview.h"
#import "ZZAddContactButton.h"

@class ZZAddContactButton;

static CGFloat ZZCellCornerRadius = 4.0f;
static CGFloat ZZCellBorderWidth = 4.0f;

@interface ZZGridCell () <ZZGridCellViewModelAnimationDelegate>

@property (nonatomic, strong) ZZGridCellViewModel* model;
@property (nonatomic, strong) ZZAddContactButton* plusButton;
@property (nonatomic, strong) UIGestureRecognizer* plusRecognizer;
@property (nonatomic, strong) ZZGridStateView* stateView;
@property (nonatomic, assign) ZZGridCellViewModelState currentViewState;
@property (nonatomic, strong) ZZFriendDomainModel* cellFriendModel;
@end

@implementation ZZGridCell

- (instancetype)init
{
    if (self = [super init])
    {
        self.backgroundColor = [ZZColorTheme shared].gridCellBorderColor;
        self.clipsToBounds = NO;
        self.layer.cornerRadius = ZZCellCornerRadius;
        self.layer.shadowColor = [ZZColorTheme shared].gridCellShadowColor.CGColor;
        self.layer.shadowRadius = 2.0f;
        self.layer.shadowOffset = CGSizeZero;
        self.layer.shadowOpacity = 1.0f;
        
        self.currentViewState = ZZGridCellViewModelStateNone;
        [self plusButton];
    }
    return self;
}

- (void)updateWithModel:(ZZGridCellViewModel*)model
{
    ANDispatchBlockToMainQueue(^{
        self.model = model;
        [self updateStateViewWithModel:model];
    });
}

- (void)updateStateViewWithModel:(ZZGridCellViewModel*)model
{
    ANDispatchBlockToMainQueue(^{
        
        if ([self _isNeedToChangeStateViewWithModel:model])
        {

            if (model.state & ZZGridCellViewModelStateAdd)
            {
                [self _updatePlusButtonImage];
                
                if (self.stateView)
                {
                    self.currentViewState = ZZGridCellViewModelStateNone;
                    [self.stateView removeFromSuperview];
                }
            }
            
            else if (model.state & ZZGridCellViewModelStateFriendHasApp ||
                     model.state & ZZGridCellViewModelStateFriendHasNoApp)
            {
                self.stateView = [[ZZGridStateViewRecord alloc] initWithPresentedView:self];
            }
            else if (model.state & ZZGridCellViewModelStatePreview)
            {
                self.stateView = [[ZZGridStateViewPreview alloc] initWithPresentedView:self];
            }
            else
            {
                [self.stateView removeFromSuperview];
            }
            
            [self _setupRecordRecognizerWithModel:model];
        }
        
        
        if (self.stateView)
        {
            self.currentViewState = model.state;
            [self.stateView updateWithModel:self.model];
        }
        
    });
}

- (BOOL)_isNeedToChangeStateViewWithModel:(ZZGridCellViewModel*)model
{
    BOOL isNeedChange = YES;
    if ([self.cellFriendModel isEqual:model.item.relatedUser] &&
        self.currentViewState != ZZGridCellViewModelStateNone
        && (model.state & self.currentViewState))
    {
        isNeedChange = NO;
    }
    self.cellFriendModel = model.item.relatedUser;
    
    return isNeedChange;
}

#pragma mark - Record recognizer;

- (void)_setupRecordRecognizerWithModel:(ZZGridCellViewModel *)model
{
    if ([self.stateView isKindOfClass:[ZZGridStateViewNudge class]])
    {
        ZZGridStateViewNudge* nudgeStateView = (ZZGridStateViewNudge*)self.stateView;
        [model setupRecorderRecognizerOnView:nudgeStateView.recordView withAnimationDelegate:self];
    }
    else if ([self.stateView isKindOfClass:[ZZGridStateViewRecord class]])
    {
        ZZGridStateViewRecord* recordStateView = (ZZGridStateViewRecord*)self.stateView;
        [model setupRecorderRecognizerOnView:recordStateView.recordView withAnimationDelegate:self];
    }
    else if ([self.stateView isKindOfClass:[ZZGridStateViewPreview class]])
    {
        ZZGridStateViewPreview* previewStateView = (ZZGridStateViewPreview*)self.stateView;
        [model setupRecorderRecognizerOnView:previewStateView.thumbnailImageView withAnimationDelegate:self];
//        [model removeRecordHintRecognizerFromView:self];
    }
}

#pragma mark - Delegate

- (void)setStateView:(ZZGridStateView*)stateView
{
    if (_stateView != stateView)
    {
        [_stateView removeFromSuperview];
        _stateView = stateView;
    }
    [self addSubview:stateView];
    [stateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self).with.insets([self _defaultInsets]);
    }];
}


#pragma mark - Animation part

- (void)showContainFriendAnimation
{
    [self.stateView showContainFriendAnimation];
}

- (void)showDownloadAnimationWithCompletionBlock:(void(^)())completionBlock
{
    [self.stateView showDownloadAnimationWithCompletionBlock:completionBlock];
}

- (void)_itemSelected
{
    if (self.model.hasActiveContactIcon)
    {
        [self _hidePlusButtonAnimated];
    }
    
    [self.model itemSelected];
}

- (ZZAddContactButton *)plusButton
{
    if (!_plusButton)
    {
        _plusButton = [ZZAddContactButton new];

        [_plusButton addTarget:self
                        action:@selector(_itemSelected)
              forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:_plusButton];
        [self sendSubviewToBack:_plusButton];

        [_plusButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self).with.insets([self _defaultInsets]);
        }];
    }
    return _plusButton;
}

- (void)_hidePlusButtonAnimated
{
    [self.plusButton setPlusViewHidden:YES animated:YES];
}

- (void)hideAllAnimations
{
    [self.stateView hideAllAnimationViews];
    [self.model reloadDebugVideoStatus];
}

- (void)_updatePlusButtonImage
{
    [UIView animateWithDuration:0.5 animations:^{
        self.plusButton.isActive = self.model.hasActiveContactIcon;
    }];
}

- (UIEdgeInsets)_defaultInsets
{
    return UIEdgeInsetsMake(ZZCellBorderWidth, ZZCellBorderWidth, ZZCellBorderWidth, ZZCellBorderWidth);
}

#pragma mark - Aniamtion Delegate Methods

- (void)showUploadAnimation
{
    [self.stateView showUploadAnimationWithCompletionBlock:^{
        if (self.model.badgeNumber > 0)
        {
            [self.stateView updateBadgeWithNumber:self.model.badgeNumber];
        }
        [self.model reloadDebugVideoStatus];
    }];
}

@end
