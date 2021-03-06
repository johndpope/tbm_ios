//
//  ZZDownloadAnimationView.m
//  Animation
//
//  Created by Rinat on 26/02/16.
//  Copyright © 2016 No plan B. All rights reserved.
//

#import "ZZLoadingAnimationView.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import <QuartzCore/QuartzCore.h>

static NSMutableDictionary <NSNumber *, NSArray <UIImage *> *> *AnimationsFramesCache; // to avoid frames loading each time

CGFloat ZZLoadingAnimationDuration = 2.0f;

@interface ZZLoadingAnimationView ()

@property (nonatomic, weak) UIImageView *imageView;
@property (nonatomic, copy) ANCodeBlock completion;
@property (nonatomic, strong) DownloadingView *downloadingView;

@end

@implementation ZZLoadingAnimationView

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self _setupView];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self _setupView];
}

- (void)_setupView
{
    self.userInteractionEnabled = NO;

    _downloadingView = [[DownloadingView alloc] initWithFrame:CGRectMake(0, 0, 62, 62)];
    _downloadingView.alpha = 0;
    [self addSubview:_downloadingView];

    if (!AnimationsFramesCache)
    {
        AnimationsFramesCache = [NSMutableDictionary new];
    }

    UIImageView *imageView = [UIImageView new];
    imageView.animationDuration = ZZLoadingAnimationDuration;
    imageView.animationRepeatCount = 1;
    [self addSubview:imageView];

    self.imageView = imageView;
}

- (void)startDownloading
{
    [self _prepareBeginState];

    self.downloadingView.alpha = 0;
    self.downloadingView.transform = CGAffineTransformMakeScale(0.1, 0.1);
    [self.downloadingView startAnimating];

    [UIView animateWithDuration:0.5f animations:^{

        self.backgroundColor = [self.tintColor colorWithAlphaComponent:0.75];
        self.downloadingView.transform = CGAffineTransformIdentity;
        self.downloadingView.alpha = 1;

    }                completion:^(BOOL finished) {

    }];
}

- (void)finishDownloadingToView:(UIView *)targetView
                     completion:(ANCodeBlock)completion
{
    self.completion = completion ?: ^{};

    [self.downloadingView finishAnimating:^{
        [UIView animateWithDuration:0.4
                              delay:0
                            options:UIViewAnimationOptionAllowAnimatedContent
                         animations:^{

                             self.downloadingView.transform = CGAffineTransformMakeScale(0.3, 0.3);

                             [self.downloadingView mas_remakeConstraints:^(MASConstraintMaker *make) {
                                 make.centerX.equalTo(targetView.mas_centerX);
                                 make.centerY.equalTo(targetView.mas_centerY);
                             }];

                             [self layoutIfNeeded];
                             self.backgroundColor = [UIColor clearColor];

                         } completion:^(BOOL finished) {


                    [self _endAnimation];

                    [UIView animateWithDuration:finished ? 0.25 : 0
                                     animations:^{
                                         self.downloadingView.alpha = 0;
                                     }];

                }];

    }];


}

- (void)setDownloadProgress:(CGFloat)downloadProgress
{
    _downloadProgress = downloadProgress;

    self.downloadingView.done = downloadProgress;
}

#pragma mark Animations

- (void)animateWithType:(ZZLoadingAnimationType)type
                 toView:(UIView *)targetView
             completion:(ANCodeBlock)completion
{
    if (self.completion) // this means animation in progress
    {
        [self.layer removeAllAnimations];
        [self.imageView.layer removeAllAnimations];

        [self _endAnimation];
    }

    self.completion = [completion copy];

    self.imageView.animationImages = [self _framesForAnimationType:type];
    self.imageView.animationDuration = ZZLoadingAnimationDuration;
    [self _animateToView:targetView];
}

- (void)_animateToView:(UIView *)targetView
{
    [self _prepareBeginState];

    self.imageView.alpha = 1;
    [self.imageView startAnimating];
    [self.imageView sizeToFit];

    __block CGFloat timing = ZZLoadingAnimationDuration;
    CGFloat inAnimationDuration = 0.5f;
    timing -= inAnimationDuration;

    [UIView animateWithDuration:inAnimationDuration animations:^{

        self.backgroundColor = [self.tintColor colorWithAlphaComponent:0.75];

    }                completion:^(BOOL finished) {

        CGFloat outAnimationDuration = 0.25f;
        timing -= outAnimationDuration;

        [UIView animateWithDuration:finished ? outAnimationDuration : 0
                              delay:finished ? timing : 0
                            options:UIViewAnimationOptionAllowAnimatedContent
                         animations:^{

                             [self.imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
                                 make.centerX.equalTo(targetView.mas_centerX);
                                 make.centerY.equalTo(targetView.mas_centerY);
                             }];

                             [self layoutIfNeeded];
                             self.backgroundColor = [UIColor clearColor];

                         } completion:^(BOOL finished) {

                    self.imageView.image = self.imageView.animationImages.lastObject;

                    [self _endAnimation];

                    [UIView animateWithDuration:finished ? 0.25 : 0
                                     animations:^{
                                         self.imageView.alpha = 0;
                                     }];

                }];
    }];
}

- (void)_prepareBeginState
{
    self.backgroundColor = [UIColor clearColor];

    [self.imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
    }];

    [self.downloadingView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
    }];

}

- (void)_endAnimation
{

    if (self.completion)
    {
        ANCodeBlock completion = [self.completion copy];
        completion();
        self.completion = nil;

    }

}

#pragma mark Frame loading and cache

- (NSArray <UIImage *> *)_framesForAnimationType:(ZZLoadingAnimationType)type
{
    [self _loadFramesToCacheIfNeededForAnimationType:type];
    return AnimationsFramesCache[@(type)];
}

- (NSArray <UIImage *> *)_framesWithFileTemplate:(NSString *)template frameCount:(NSUInteger)count
{
    NSMutableArray <UIImage *> *images = [NSMutableArray new];

    for (NSUInteger index = 0; index < count; index++)
    {
        NSString *fileName = [NSString stringWithFormat:template, (unsigned long)index];
        UIImage *image = [UIImage imageNamed:fileName];
        [images addObject:image];
    }

    return [images copy];
}

- (void)_loadFramesToCacheIfNeededForAnimationType:(ZZLoadingAnimationType)type
{
    if (AnimationsFramesCache[@(type)])
    {
        return;
    }

    AnimationsFramesCache[@(type)] = [self _loadFramesForAnimationType:type];
}

- (NSArray <UIImage *> *)_loadFramesForAnimationType:(ZZLoadingAnimationType)type
{
    switch (type)
    {
        case ZZLoadingAnimationTypeUploading:
            return [self _framesWithFileTemplate:@"send_%02lu" frameCount:51];
            break;
        case ZZLoadingAnimationTypeDownloading:
            return [self _framesWithFileTemplate:@"download_%02lu" frameCount:51];
            break;

        default:
            break;
    }
    return nil;
}


@end
