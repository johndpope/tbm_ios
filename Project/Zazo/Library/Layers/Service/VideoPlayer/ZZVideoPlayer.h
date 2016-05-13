//
//  ZZVideoPlayer.h
//  Zazo
//
//  Created by ANODA on 18/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//


@class ZZFriendDomainModel, ZZVideoDomainModel;

@protocol ZZVideoPlayerDelegate <NSObject>

- (void)videoPlayerDidStartVideoModel:(ZZVideoDomainModel *)videoModel;

- (void)videoPlayerDidFinishPlayingWithModel:(ZZFriendDomainModel *)playedFriendModel;

- (void)didStartPlayingVideoWithIndex:(NSUInteger)startedVideoIndex totalVideos:(NSUInteger)videos;

- (void)videoPlayingProgress:(CGFloat)progress; // zero if no progress

@end

@interface ZZVideoPlayer : NSObject

@property (nonatomic, weak) id <ZZVideoPlayerDelegate> delegate;
@property (nonatomic, assign) BOOL isPlayingVideo;

@property (nonatomic, weak) UIView *superview;

- (ZZFriendDomainModel *)playedFriendModel;

- (void)updateWithFriendModel:(ZZFriendDomainModel *)friendModel;

- (void)playOnView:(UIView *)view withVideoModels:(NSArray *)videoModels;

- (void)stop;

- (void)toggle;

- (BOOL)isPlaying;

- (BOOL)isVideoPlayingWithFriendModel:(ZZFriendDomainModel *)friendModel;

@end
