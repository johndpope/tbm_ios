//
//  ZZGridCollectionCellPreviewView.m
//  Zazo
//
//  Created by ANODA on 02/09/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZGridStateViewPreview.h"
#import "ZZGridUIConstants.h"
#import "ZZDateLabel.h"
#import "ZZGridCell.h"
#import "NSDate+ZZAdditions.h"

@interface ZZGridStateViewPreview ()

@property (nonatomic, assign) BOOL isVideoPlaying;

@end

@implementation ZZGridStateViewPreview


- (instancetype)initWithPresentedView:(ZZGridCell *)presentedView
{
    self = [super initWithPresentedView:presentedView];
    if (self)
    {
        [self makeOverflowButton];
        
        [self thumbnailImageView];
        [self userNameLabel];
        [self dateLabel];
        [self animationView];
//        [self holdIndicatorView];
        [self effectView];
        [self sentBadge];
        [self numberBadge];
        
        [self bringSubviewToFront:self.overflowButton];

    }

    return self;
}

- (void)updateWithModel:(ZZGridCellViewModel *)model
{
    ANDispatchBlockToMainQueue(^{
        [super updateWithModel:model];
        [self _setupThumbnailWithModel:model];
        self.userNameLabel.hidden = NO;
        [self _handleFailedVideoDownloadWithModel:model];
        [self _updateVideoSentDate:model.lastMessageDate];
    });
}

#pragma mark - Private

- (void)_updateVideoSentDate:(NSDate *)date
{
    self.dateLabel.text = [date zz_formattedDate];
}

- (void)_handleFailedVideoDownloadWithModel:(ZZGridCellViewModel *)model
{
//    if (model.badgeNumber == 0 && (model.videoState == ZZCellStateVideoFailed))
//    {
//        [self.presentedView hideActiveBorder];
//    }
}

- (void)_setupThumbnailWithModel:(ZZGridCellViewModel *)model
{
    UIImage *thumbImage = [model videoThumbnailImage];

    if (thumbImage)
    {
        self.thumbnailImageView.contentMode = UIViewContentModeScaleAspectFill;

        [UIView transitionWithView:self.thumbnailImageView
                          duration:0.5f
                           options:UIViewAnimationOptionTransitionCrossDissolve | UIViewAnimationOptionAllowUserInteraction
                        animations:^{
                            self.thumbnailImageView.image = thumbImage;
                        } completion:NULL];
    }

}

#pragma mark - Lazy Load

- (UIImageView *)thumbnailImageView
{
    if (!_thumbnailImageView)
    {
        _thumbnailImageView = [UIImageView new];
        _thumbnailImageView.backgroundColor = [ZZColorTheme shared].gridCellGrayColor;
        _thumbnailImageView.userInteractionEnabled = YES;
        _thumbnailImageView.clipsToBounds = YES;
        
        [self insertSubview:_thumbnailImageView belowSubview:self.backGradientView];

        [_thumbnailImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.bottom.equalTo(self);
        }];
    }
    return _thumbnailImageView;
}

- (UILabel *)dateLabel
{
    if (!_dateLabel)
    {
        UILabel *label = [ZZDateLabel new];

        label.font = [UIFont zz_mediumFontWithSize:kLayoutConstDateLabelFontSize];
        label.text = @"";
        label.textColor = [ZZColorTheme shared].gridCellTextColor;

        [self addSubview:label];

        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(self);
            make.height.equalTo(@(label.font.pointSize * 1.5));
        }];

        _dateLabel = label;
    }

    return _dateLabel;
}

- (void)makeOverflowButton
{
    UIButton *button = [UIButton new];
    
    [self addSubview:button];
    
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.height.equalTo(@(kLayoutConstNameLabelHeight));
    }];
    
    [button addTarget:self
               action:@selector(didTapOverflowButton:)
     forControlEvents:UIControlEventTouchUpInside];
    
    UIImage *overflowIcon = [UIImage imageNamed:@"overflow-icon"];
    
    UIImageView *overflowImageView = [[UIImageView alloc] initWithImage:overflowIcon];
    overflowImageView.tintColor = [UIColor whiteColor];
    
    [button addSubview:overflowImageView];
    [overflowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(button);
        make.right.equalTo(button);
    }];

    self.overflowButton = button;
}

- (void)didTapOverflowButton:(UIButton *)button
{
    [self.model didTapOverflowButton:(UIButton *)button];
}

@end
