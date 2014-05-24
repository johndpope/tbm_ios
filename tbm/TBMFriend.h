//
//  Friend.h
//  tbm
//
//  Created by Sani Elfishawy on 4/26/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
@protocol TBMVideoStatusNotoficationProtocol <NSObject>
- (void)videoStatusDidChange:(id)object;
@end


@interface TBMFriend : NSManagedObject

// Note order matters. The first enum is chosen intentionally since that is what the
// property initializes to.
typedef NS_ENUM (NSInteger, TBMOutgoingVideoStatus) {
    OUTGOING_VIDEO_STATUS_NEW,
    OUTGOING_VIDEO_STATUS_UPLOADING,
    OUTGOING_VIDEO_STATUS_UPLOADED,
    OUTGOING_VIDEO_STATUS_DOWNLOADED,
    OUTGOING_VIDEO_STATUS_VIEWED,
};

// Note order matters. The first enum is chosen intentionally since that is what the
// property initializes to.
typedef NS_ENUM (NSInteger, TBMIncomingVideoStatus) {
    INCOMING_VIDEO_STATUS_VIEWED,
    INCOMING_VIDEO_STATUS_DOWNLOADING,
    INCOMING_VIDEO_STATUS_DOWNLOADED,
};

typedef NS_ENUM(NSInteger, TBMVideoStatusEventType){
    INCOMING_VIDEO_STATUS_EVENT_TYPE,
    OUTGOING_VIDEO_STATUS_EVENT_TYPE
};

@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * outgoingVideoId;
@property (nonatomic, retain) NSString * incomingVideoId;
@property (nonatomic) TBMOutgoingVideoStatus outgoingVideoStatus;
@property (nonatomic) TBMIncomingVideoStatus incomingVideoStatus;
@property (nonatomic) TBMVideoStatusEventType lastVideoStatusEventType;
@property (nonatomic, retain) NSNumber * viewIndex;
@property (nonatomic, retain) NSNumber * uploadRetryCount;
@property (nonatomic, retain) NSNumber * downloadRetryCount;
@property (nonatomic, retain) NSString * idTbm;

// Finders
+ (NSArray *)all;
+ (instancetype)findWithId:(NSString *)idTbm;
+ (instancetype)findWithViewIndex:(NSNumber *)viewIndex;
+ (NSUInteger)count;
+ (NSMutableArray *)whereUploadPendingRetry;
+ (NSMutableArray *)whereDownloadPendingRetry;

// Create and destroy
+ (instancetype)newWithId:(NSNumber *)idTbm;
+ (NSUInteger)destroyAll;
+ (void)destroyWithId:(NSNumber *)idTbm;
+ (void)saveAll;

// VideoStatusNotification
+ (void)addVideoStatusNotificationDelegate:(id)delegate;
+ (void)removeVideoStatusNotificationDelegate:(id)delegate;

// Instance methods
- (BOOL) hasValidIncomingVideoFile;
- (void)loadIncomingVideoWithUrl:(NSURL *)location;

- (NSURL *)incomingVideoUrl;
- (UIImage *)thumbImageOrThumbMissingImage;

- (void)setUploadRetryCountWithInteger:(NSInteger)count;
- (void)setDownloadRetryCountWithInteger:(NSInteger)count;

- (NSInteger)getUploadRetryCount;
- (NSInteger)getDownloadRetryCount;

- (void)incrementUploadRetryCount;
- (void)incrementDownloadRetryCount;

- (BOOL)hasUploadPendingRetry;
- (BOOL)hasDownloadPendingRetry;

- (NSString *)videoStatusString;
// Probably should not expose this and rather have setters for various states.
- (void)setAndNotifyOutgoingVideoStatus:(TBMOutgoingVideoStatus)newStatus;
- (void)setAndNotifyIncomingVideoStatus:(TBMIncomingVideoStatus)newStatus;
- (void)setAndNotifyUploadRetryCount:(NSNumber *)newRetryCount;
- (void)setIncomingViewed;
@end

