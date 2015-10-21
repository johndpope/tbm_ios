//
//  ZZVideoFileHandler.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 10/20/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

@class TBMFriend;

@protocol ZZVideoFileHandlerDelegate <NSObject>

- (void)requestBackground;
- (void)videoReceivedFromFriendWithItemID:(NSString*)friendItemID videoID:(NSString*)videoID;

- (void)sendNotificationForVideoReceived:(TBMFriend *)friend videoId:(NSString *)videoId;
- (void)sendNotificationForVideoStatusUpdate:(TBMFriend *)friend videoId:(NSString *)videoId status:(NSString *)status;
- (void)setBadgeNumberUnviewed;

@end

@interface ZZVideoFileHandler : NSObject

@property (nonatomic, weak) id<ZZVideoFileHandlerDelegate> delegate;


- (void)handleBackgroundSessionWithIdentifier:(NSString*)identifier completionHandler:(ANCodeBlock)completionHandler;
- (void)queueDownloadWithFriendID:(NSString*)friendID videoId:(NSString *)videoId;



#pragma mark - Upload

- (void)uploadWithVideoUrl:(NSURL*)videoUrl friendCKey:(NSString*)friendCKey;



@end
