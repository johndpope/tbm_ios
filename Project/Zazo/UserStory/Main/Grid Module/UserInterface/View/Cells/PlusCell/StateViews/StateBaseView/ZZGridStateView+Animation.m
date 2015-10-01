//
//  ZZGridCollectionCellBaseStateView+Animation.m
//  Zazo
//
//  Created by ANODA on 02/09/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZGridStateView+Animation.h"
#import "ZZGridUIConstants.h"
#import "ANAnimator.h"

@implementation ZZGridStateView (Animation)

#pragma mark - Upload Animation

- (void)_showUploadAnimationWithCompletionBlock:(void(^)())completionBlock;
{
    [self hideAllAnimationViews];
    
    [self _updateUploadViewsToDefaultState];
    
    CGFloat animValue = CGRectGetWidth(self.frame) - [self _indicatorCalculatedWidth];
    [UIView animateWithDuration:0.4 animations:^{
   
        self.leftUploadIndicatorConstraint.offset = animValue;
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.uploadBarView.hidden = YES;
        [self.model reloadDebugVideoStatus];
        if (completionBlock)
        {
            completionBlock();
        }
    }];
}


#pragma mark - Upload Views Show / Hide state

- (void)_updateUploadViewsToDefaultState
{
    [self _hideUploadViews];
    self.leftUploadIndicatorConstraint.offset = 0.0;
    [self layoutIfNeeded];
    [self _showUploadViews];
    [self.model reloadDebugVideoStatus];
}

- (void)_showUploadViews
{
    self.leftUploadIndicatorConstraint.offset = 0;
//    self.uploadingIndicator.image = [UIImage imageNamed:@"icon-uploading-1x"];
    self.uploadBarView.hidden = NO;
    self.uploadingIndicator.hidden = NO;
}

- (void)_hideUploadViews
{
    self.uploadingIndicator.hidden = YES;
    self.uploadBarView.hidden = YES;
    self.leftUploadIndicatorConstraint.offset = 0;
}


- (void)_showUploadIconWithoutAnimation
{
    self.uploadingIndicator.hidden = NO;
    CGFloat animValue = CGRectGetWidth(self.presentedView.frame) - [self _indicatorCalculatedWidth];
    self.leftUploadIndicatorConstraint.offset = animValue;
    [self.model reloadDebugVideoStatus];
}

- (CGFloat)_indicatorCalculatedWidth
{
    return fminf(kLayoutConstIndicatorMaxWidth, kLayoutConstIndicatorFractionalWidth * CGRectGetWidth(self.presentedView.frame));
}


#pragma mark - Download Animation part

- (void)_updateDownloadViewsToDefaultState
{
    [self hideAllAnimationViews];
    [self layoutIfNeeded];
    [self _showDownloadViews];
}


- (void)_showDownloadAnimationWithCompletionBlock:(void (^)())completionBlock
{
    ANDispatchBlockToMainQueue(^{
        CGFloat animationDuration = 1.6;
        [self _hideAllAnimationViews];
        
        CGFloat animValue = CGRectGetWidth(self.presentedView.frame) - [self _indicatorCalculatedWidth];
        self.rightDownloadIndicatorConstraint.offset = 0.0;
        [self _showDownloadViews];
        
        [ANAnimator animateConstraint:self.rightDownloadIndicatorConstraint newOffset:-animValue key:@"download" delay:animationDuration bouncingRate:0];
        [self.model reloadDebugVideoStatus];
        ANDispatchBlockAfter(animationDuration, ^{
            if (completionBlock)
            {
                completionBlock();
                [self.model reloadDebugVideoStatus];
            }
        });
    });
}

#pragma mark - Download Views Show/Hide

- (void)_showDownloadViews
{
    self.downloadIndicator.hidden = NO;
    self.downloadBarView.hidden = NO;
}

- (void)_hideDownloadViews
{
    self.downloadIndicator.hidden = YES;
    self.downloadBarView.hidden = YES;
}

- (void)_hideAllDownloadViews
{
    self.rightDownloadIndicatorConstraint.offset = 0;
    self.downloadBarView.hidden = YES;
    self.downloadIndicator.hidden = YES;
    self.backgroundColor = [ZZColorTheme shared].gridCellGrayColor;
    self.videoCountLabel.hidden = YES;
}

- (void)_showVideoCountLabelWithCount:(NSInteger)count
{
    [self _hideAllAnimationViews];
    self.videoCountLabel.hidden = NO;
    self.videoCountLabel.text = [NSString stringWithFormat:@"%li",(long)count];
    self.backgroundColor = [ZZColorTheme shared].gridCellLayoutGreenColor;
}

- (void)_hideVideoCountLabel
{
    self.videoCountLabel.hidden = YES;
}

- (void)_hideAllAnimationViews
{
    [self _hideAllDownloadViews];
    [self _hideUploadViews];
    [self _hideVideoCountLabel];
    self.videoViewedView.hidden = YES;
}

@end
