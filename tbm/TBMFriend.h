//
//  Friend.h
//  tbm
//
//  Created by Sani Elfishawy on 4/26/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface TBMFriend : NSManagedObject

typedef NS_ENUM (NSInteger, TBMOutgoingVideoStatus) {
OUTGOING_VIDEO_STATUS_NEW,
OUTGOING_VIDEO_STATUS_UPLOADING,
OUTGOING_VIDEO_STATUS_UPLOADED,
OUTGOING_VIDEO_STATUS_DOWNLOADED,
OUTGOING_VIDEO_STATUS_VIEWED
};

typedef NS_ENUM (NSInteger, TBMIncomingVideoStatus) {
INCOMING_VIDEO_STATUS_DOWNLOADING,
INCOMING_VIDEO_STATUS_DOWNLOADED,
INCOMING_VIDEO_STATUS_VIEWED,
};

@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic) TBMOutgoingVideoStatus outgoingVideoStatus;
@property (nonatomic) TBMIncomingVideoStatus incomingVideoStatus;
@property (nonatomic, retain) NSNumber * viewIndex;
@property (nonatomic, retain) NSNumber * uploadRetryCount;
@property (nonatomic, retain) NSString * idTbm;

// Finders
+ (NSArray *)all;
+ (instancetype)findWithId:(NSString *)idTbm;
+ (instancetype)findWithViewIndex:(NSNumber *)viewIndex;
+ (NSUInteger)count;

// Create and destroy
+ (instancetype)newWithId:(NSNumber *)idTbm;
+ (NSUInteger)destroyAll;
+ (void)destroyWithId:(NSNumber *)idTbm;
+ (void)saveAll;

// Instance methods
- (NSURL *)incomingVideoUrl;
- (UIImage *)thumbImageOrThumbMissingImage;
- (void)setRetryCountWithInteger:(NSInteger)count;
- (NSInteger)getRetryCount;
- (void)incrementRetryCount;

@end
