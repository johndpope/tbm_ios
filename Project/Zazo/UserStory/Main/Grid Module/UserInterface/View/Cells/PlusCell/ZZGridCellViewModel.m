//
//  ZZGridCellViewModel.m
//  Zazo
//
//  Created by ANODA on 01/09/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

@import AVFoundation;

#import "ZZGridCellViewModel.h"
#import "ZZVideoDomainModel.h"
#import "ZZThumbnailGenerator.h"
#import "ZZStoredSettingsManager.h"
#import "ZZGridActionStoredSettings.h"
#import "ZZFriendDataHelper.h"


@interface ZZGridCellViewModel ()

@property (nonatomic, strong) UILongPressGestureRecognizer *recordRecognizer;
@property (nonatomic, assign) CGPoint initialRecordPoint;

@end

@implementation ZZGridCellViewModel

@dynamic isRecording;

- (void)setUsernameLabel:(UILabel *)usernameLabel
{
    _usernameLabel = usernameLabel;
    ANDispatchBlockToMainQueue(^{
        
       _usernameLabel.text = [self videoStatusString];
    });
}

- (NSString *)_stubUserNameForIndex:(NSUInteger)index
{
    NSArray *stubNames = @[
                           @"Leila",
                           @"Nia",
                           @"Shani",
                           @"Gabby",
                           @"Mary",
                           @"Sachi",
                           @"Alexis",
                           @"Veronika"                           
                           ];
    
    return stubNames[index];
}

- (NSString *)videoStatusString
{
    
#ifdef MAKING_SCREENSHOTS
    return [self _stubUserNameForIndex:self.item.index];
#endif

    
    ZZFriendDomainModel* friendModel = self.item.relatedUser;

    NSString* videoStatusString = nil;

    if ([ZZStoredSettingsManager shared].debugModeEnabled)
    {
        videoStatusString = ZZVideoStatusStringWithFriendModel(friendModel);
    }
    else
    {
        videoStatusString = [friendModel displayName];
    }
  
    return videoStatusString;
}

- (void)itemSelected
{
    if (![self.delegate isGridRotate])
    {
        [self.delegate addUserToItem:self];
    }
}

- (void)reloadDebugVideoStatus
{
    ANDispatchBlockToMainQueue(^{
       self.usernameLabel.text = [self videoStatusString];
    });
}

- (BOOL)isRecording
{
    return !CGPointEqualToPoint(self.initialRecordPoint, CGPointZero);
}

- (void)updateRecordingStateTo:(BOOL)isRecording
           withCompletionBlock:(void(^)(BOOL isRecordingSuccess))completionBlock
{
    [self.delegate recordingStateUpdatedToState:isRecording
                                      viewModel:self
                            withCompletionBlock:completionBlock];
    
    [self reloadDebugVideoStatus];
}

- (ZZGridCellViewModelState)state
{
    ZZGridCellViewModelState modelState = ZZGridCellViewModelStateNone;
    
    if (!self.item.relatedUser)
    {
        modelState = ZZGridCellViewModelStateAdd;
    }
    else if (!ANIsEmpty(self.item.relatedUser) &&
             self.item.relatedUser.lastIncomingVideoStatus == ZZVideoIncomingStatusFailedPermanently)
    {
        if (self.hasDownloadedVideo)
        {
            modelState = ZZGridCellViewModelStatePreview | ZZGridCellViewModelStateVideoFailedPermanently;
        }
        else
        {
            modelState = ZZGridCellViewModelStateFriendHasApp | ZZGridCellViewModelStateVideoFailedPermanently;
        }
    }
    else if (self.hasDownloadedVideo)
    {
        modelState = ZZGridCellViewModelStatePreview;
    }
    else if (self.item.relatedUser.hasApp)
    {
        modelState = ZZGridCellViewModelStateFriendHasApp;
    }
    else if (!ANIsEmpty(self.item.relatedUser) && !self.item.relatedUser.hasApp)
    {
        modelState = ZZGridCellViewModelStateFriendHasNoApp;
    }

    modelState = [self _additionalModelStateWithState:modelState];    
    
    return modelState;
}

- (ZZGridCellViewModelState)_additionalModelStateWithState:(ZZGridCellViewModelState)state
{
    ZZGridCellViewModelState stateWithAdditionalState = state;
    
    if (self.hasUploadedVideo &&
       !self.isUploadedVideoViewed &&
        self.item.relatedUser.lastVideoStatusEventType != ZZVideoStatusEventTypeIncoming &&
        self.item.relatedUser.lastOutgoingVideoStatus >= ZZVideoOutgoingStatusUploaded)
    {
        stateWithAdditionalState = (stateWithAdditionalState | ZZGridCellViewModelStateVideoWasUploaded);
    }
    else if (self.isUploadedVideoViewed &&
        self.item.relatedUser.lastVideoStatusEventType != ZZVideoStatusEventTypeIncoming)
    {
        stateWithAdditionalState = (stateWithAdditionalState | ZZGridCellViewModelStateVideoWasViewed);
    }
    else if (self.item.relatedUser.lastVideoStatusEventType == ZZVideoStatusEventTypeIncoming &&
             self.item.relatedUser.lastIncomingVideoStatus == ZZVideoIncomingStatusDownloading &&
            [ZZFriendDataHelper unviewedVideoCountWithFriendID:self.item.relatedUser.idTbm] > 0)
    {
        stateWithAdditionalState = (stateWithAdditionalState | ZZGridCellViewModelStateVideoDownloading);
    }
    else if (self.item.relatedUser.lastVideoStatusEventType == ZZVideoStatusEventTypeIncoming &&
             self.item.relatedUser.lastIncomingVideoStatus == ZZVideoIncomingStatusDownloaded &&
             !self.item.isDownloadAnimationViewed)
    {
        stateWithAdditionalState = (stateWithAdditionalState | ZZGridCellViewModelStateVideoDownloaded);
    }

    // green border state
    if (self.badgeNumber > 0)
    {
        stateWithAdditionalState = (stateWithAdditionalState | ZZGridCellViewModelStateNeedToShowBorder);
    }
    else if (self.badgeNumber == 0 &&
             self.item.relatedUser.lastIncomingVideoStatus == ZZVideoIncomingStatusDownloading)
    {
        stateWithAdditionalState = (stateWithAdditionalState | ZZGridCellViewModelStateVideoFirstVideoDownloading);
    }

    // badge state
    if (self.badgeNumber == 1
        && self.item.relatedUser.lastIncomingVideoStatus == ZZVideoIncomingStatusDownloaded)
    {
        stateWithAdditionalState = (stateWithAdditionalState | ZZGridCellViewModelStateVideoDownloadedAndVideoCountOne);
    }
    else if (self.badgeNumber > 1)
    {
        stateWithAdditionalState = (stateWithAdditionalState | ZZGridCellViewModelStateVideoCountMoreThatOne);
    }
    
    return stateWithAdditionalState;
}


- (void)updateVideoPlayingStateTo:(BOOL)isPlaying
{
    [self.delegate playingStateUpdatedToState:isPlaying viewModel:self];
    [self reloadDebugVideoStatus];
}

- (NSString*)firstName
{
    return [NSObject an_safeString:self.item.relatedUser.firstName];
}

- (NSArray*)playerVideoURLs
{
    return self.item.relatedUser.videos;
}

#pragma mark - Video Thumbnail

- (UIImage *)videoThumbnailImage
{
    
#ifdef MAKING_SCREENSHOTS
    return [UIImage imageNamed:[NSString stringWithFormat:@"prethumb%ld", (long)self.item.index + 1]];
#endif
    
    return [self _videoThumbnail];
}

- (void)setupRecorderRecognizerOnView:(UIView*)view
                withAnimationDelegate:(id <ZZGridCellViewModelAnimationDelegate>)animationDelegate
{
    self.animationDelegate = animationDelegate;
    [self _removeActionRecognizerFromView:view];
    [view addGestureRecognizer:self.recordRecognizer];
}

- (void)_removeActionRecognizerFromView:(UIView*)view
{
    [view.gestureRecognizers enumerateObjectsUsingBlock:^(__kindof UIGestureRecognizer * _Nonnull recognizer, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([recognizer isKindOfClass:[UILongPressGestureRecognizer class]])
        {
            [view removeGestureRecognizer:recognizer];
        }
    }];
}

- (UILongPressGestureRecognizer *)recordRecognizer
{
    if (!_recordRecognizer)
    {
        _recordRecognizer =
        [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_recordPressed:)];
        _recordRecognizer.minimumPressDuration = 0.2;
    }
    return _recordRecognizer;
}

#pragma mark  - Recording recognizer handle

- (void)_recordPressed:(UILongPressGestureRecognizer *)recognizer
{
    if (![self.delegate isGridRotate])
    {
        if (recognizer.state == UIGestureRecognizerStateBegan)
        {
            self.initialRecordPoint = [recognizer locationInView:recognizer.view];
            
            [self updateRecordingStateTo:YES withCompletionBlock:^(BOOL isRecordingSuccess) {
                if (isRecordingSuccess)
                {
                    self.hasUploadedVideo = YES;
                    [self.animationDelegate showUploadAnimation];
                    self.usernameLabel.text = [self videoStatusString];
                }
            }];
        }
        else if (recognizer.state == UIGestureRecognizerStateEnded)
        {
            self.initialRecordPoint = CGPointZero;
            [self _stopVideoRecording];
        }
        else
        {
            [self _checkIsCancelRecordingWithRecognizer:recognizer];
        }
    }

}

- (void)_stopVideoRecording
{
    [self updateRecordingStateTo:NO withCompletionBlock:^(BOOL isRecordingSuccess) {
        if (isRecordingSuccess)
        {
            self.hasUploadedVideo = YES;
            [self.animationDelegate showUploadAnimation];
            self.usernameLabel.text = [self videoStatusString];
        }
    }];
}

- (void)_checkIsCancelRecordingWithRecognizer:(UILongPressGestureRecognizer*)recognizer
{
    if ([ZZGridActionStoredSettings shared].abortRecordHintWasShown)
    {
        CGFloat addTouchBounds = 80;
        if (IS_IPAD)
        {
            addTouchBounds *= 2;
        }
        
        UIView* recordView = recognizer.view;
        
        CGPoint location = [recognizer locationInView:recordView];
        
        CGRect observeFrame = CGRectMake(self.initialRecordPoint.x - addTouchBounds,
                                         self.initialRecordPoint.y - addTouchBounds,
                                         (addTouchBounds * 2),
                                         (addTouchBounds * 2));
        if (!CGRectContainsPoint(observeFrame,location))
        {
            [self.delegate cancelRecordingWithReason:NSLocalizedString(@"record-dragged-finger-away", nil)];
        }
    }
}

#pragma mark - Generate Thumbnail

- (UIImage*)_videoThumbnail
{
    NSSortDescriptor *sortDescriptor =
        [[NSSortDescriptor alloc] initWithKey:@"videoID" ascending:YES];
    
    NSPredicate *predicate =
        [NSPredicate predicateWithFormat:@"%K = %@", ZZVideoDomainModelAttributes.status, @(ZZVideoIncomingStatusDownloaded)];
    
    NSArray *videoModels = self.item.relatedUser.videos;
    
    videoModels = [videoModels filteredArrayUsingPredicate:predicate];
    videoModels = [videoModels sortedArrayUsingDescriptors:@[sortDescriptor]];
    
    ZZVideoDomainModel *lastModel = [videoModels lastObject];
    
    if (![ZZThumbnailGenerator hasThumbForVideo:lastModel])
    {
        [ZZThumbnailGenerator generateThumbVideo:lastModel];
    }
    
    return [ZZThumbnailGenerator lastThumbImageForUser:self.item.relatedUser];
}


#pragma mark  - Video Play Validation

- (BOOL)isEnablePlayingVideo
{
    return [self.delegate isGridCellEnablePlayingVideo:self];
}

- (BOOL)isVideoPlayed
{
    return [self.delegate isVideoPlayingWithModel:self];
}

@end