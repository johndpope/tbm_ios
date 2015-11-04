//
//  ZZVideoStatusHandler.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 11/1/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZVideoStatuses.h"
#import "TBMFriend.h"
#import "TBMVideo.h"

@protocol ZZVideoStatusHandlerDelegate <NSObject>

- (void)videoStatusChangedForFriend:(TBMFriend*)friend;

@end


@interface ZZVideoStatusHandler : NSObject

+ (instancetype)sharedInstance;
- (void)addVideoStatusHandlerObserver:(id <ZZVideoStatusHandlerDelegate>)observer;
- (void)removeVideoStatusHandlerObserver:(id <ZZVideoStatusHandlerDelegate>)observer;



- (void)deleteAllViewedOrFailedVideoForFriend:(TBMFriend*)friend;

- (void)notifyOutgoingVideoWithStatus:(ZZVideoOutgoingStatus)status
                           withFriend:(TBMFriend*)friend
                            withVideo:(TBMVideo*)video;


- (void)setAndNotifyUploadRetryCount:(NSInteger)retryCount
                          withFriend:(TBMFriend*)friend
                               video:(TBMVideo*)video;


- (void)setAndNotifyIncomingVideoStatus:(ZZVideoIncomingStatus)videoStatus
                             withFriend:(TBMFriend*)friend
                              withVideo:(TBMVideo*) video;


- (void)setAndNotifyDownloadRetryCount:(NSInteger)retryCount
                            withFriend:(TBMFriend *)friend
                                 video:(TBMVideo *)video;


- (void)notifyFriendChanged:(TBMFriend*)friend;

//TODO:

- (void)setAndNotityViewedIncomingVideoWithFriend:(TBMFriend*)friend video:(TBMVideo*)video;
- (void)handleOutgoingVideoCreatedWithVideo:(TBMVideo*)video withFriend:(TBMFriend*)friend;

@end
