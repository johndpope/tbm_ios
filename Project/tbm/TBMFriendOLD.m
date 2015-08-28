//
//  Friend.m
//  tbm
//
//  Created by Sani Elfishawy on 4/26/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "AVFoundation/AVFoundation.h"

#import "TBMFriend.h"
#import "TBMAppDelegate.h"
#import "TBMAppDelegate+PushNotification.h"
#import "TBMConfig.h"
#import "TBMUser.h"
#import "TBMStringUtils.h"
//#import "TBMDownloadManagerDeprecated.h"
#import "TBMVideoIdUtils.h"
#import "TBMHomeViewController.h"
#import "OBLogger.h"

@implementation TBMFriend

@dynamic firstName;
@dynamic lastName;
@dynamic outgoingVideoId;
@dynamic outgoingVideoStatus;
@dynamic lastVideoStatusEventType;
@dynamic lastIncomingVideoStatus;
@dynamic viewIndex;
@dynamic uploadRetryCount;
@dynamic idTbm;
@dynamic mkey;
@dynamic videos;

static NSMutableArray * videoStatusNotificationDelegates;

//==============
// Class methods
//==============
+ (TBMAppDelegate *)appDelegate{
    return [[UIApplication sharedApplication] delegate];
}

+ (NSManagedObjectContext *)managedObjectContext{
    return [[TBMFriend appDelegate] managedObjectContext];
}

+ (NSEntityDescription *)entityDescription{
    return [NSEntityDescription entityForName:@"TBMFriend" inManagedObjectContext:[TBMFriend managedObjectContext]];
}


//--------
// Finders
//--------
+ (NSFetchRequest *)fetchRequest{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[TBMFriend entityDescription]];
    return request;
}

+ (NSArray *)all{
    NSError *error;
    return [[TBMFriend managedObjectContext] executeFetchRequest:[TBMFriend fetchRequest] error:&error];
}

+ (instancetype)findWithOutgoingVideoId:(NSString *)videoId{
    return [self findWithAttributeKey:@"outgoingVideoId" value:videoId];
}

+ (instancetype)findWithId:(NSString *)idTbm{
    return [self findWithAttributeKey:@"idTbm" value:idTbm];
}

+ (instancetype)findWithViewIndex:(NSNumber *)viewIndex{
    return [self findWithAttributeKey:@"viewIndex" value:viewIndex];
}

+ (instancetype)findWithMkey:(NSString *)mkey{
    return [self findWithAttributeKey:@"mkey" value:mkey];
}

+ (instancetype)findWithAttributeKey:(NSString *)key value:(id)value{
    return [[self findAllWithAttributeKey:key value:value] lastObject];
}

+ (NSArray *)findAllWithAttributeKey:(NSString *)key value:(id)value{
    NSFetchRequest *request = [TBMFriend fetchRequest];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", key, value];
    [request setPredicate:predicate];
    NSError *error = nil;
    return [[TBMFriend managedObjectContext] executeFetchRequest:request error:&error];
}

+ (NSUInteger)count{
    return [[TBMFriend all] count];
}


//-------------------
// Create and destroy
//-------------------
+ (id)newWithId:(NSString *)idTbm
{
    TBMFriend *friend = (TBMFriend *)[[NSManagedObject alloc] initWithEntity:[TBMFriend entityDescription] insertIntoManagedObjectContext:[TBMFriend managedObjectContext]];
    friend.idTbm = idTbm;
    [TBMFriend saveAll];
    return friend;
}

+ (NSUInteger)destroyAll
{
    NSArray *allFriends = [TBMFriend all];
    NSUInteger count = [allFriends count];
    for (TBMFriend *friend in allFriends) {
        [[TBMFriend managedObjectContext] deleteObject:friend];
    }
    return count;
}

+ (void)destroyWithId:(NSString *)idTbm
{
    TBMFriend *friend = [TBMFriend findWithId:idTbm];
    if ( friend != nil ){
        [[TBMFriend managedObjectContext] deleteObject:friend];
    }
}

+ (void)saveAll{
    [[self appDelegate] saveContext];
}

//=================
// Instance methods
//=================

//----------------
// Incoming Videos
//----------------
- (NSSet *) incomingVideos{
    return self.videos;
}

- (NSArray *) sortedIncomingVideos{
//    NSSortDescriptor *d = [[NSSortDescriptor alloc] initWithKey:@"videoId" ascending:YES];
//    return [self.videos sortedArrayUsingDescriptors:@[d]];
    return [self.videos allObjects];
}

- (TBMVideo *) oldestIncomingVideo{
    return [[self sortedIncomingVideos] firstObject];
}

- (TBMVideo *) newestIncomingVideo{
    return [[self sortedIncomingVideos] lastObject];
}

- (BOOL) hasIncomingVideoId:(NSString *)videoId{
    for (TBMVideo *v in [self incomingVideos]) {
        if ([v.videoId isEqual: videoId])
            return true;
    }
    return false;
}

- (BOOL) isNewestIncomingVideo:(TBMVideo *)video{
    return [video isEqual:[self newestIncomingVideo]];
}

- (TBMVideo *)createIncomingVideoWithVideoId:(NSString *)videoId{
    TBMVideo *video = [TBMVideo newWithVideoId:videoId];
    [self addVideosObject:video];
    return video;
}

- (void) deleteAllVideos{
    for (TBMVideo *v in [self incomingVideos]){
        [self deleteVideo:v];
    }
}

- (void) deleteAllViewedVideos{
    OB_INFO(@"deleteAllViewedVideos");
    NSArray *all = [self sortedIncomingVideos];
    for (TBMVideo * v in all){
        OB_INFO(@"deleteAllViewedVideos count before delete %ld", (unsigned long)[TBMVideo count]);
        if (v.status == INCOMING_VIDEO_STATUS_VIEWED)
            [self deleteVideo:v];
        OB_INFO(@"deleteAllViewedVideos count after delete %ld", (unsigned long)[TBMVideo count]);
    }
}

- (void) deleteVideo:(TBMVideo *)video{
    [video deleteFiles];
    [self removeVideosObject:video];
}

- (TBMVideo *) firstPlayableVideo{
    TBMVideo *video = nil;
    for (TBMVideo *v in [self sortedIncomingVideos]){
        if ([v videoFileExists]){
            video = v;
            break;
        }
    }
    return video;
}

- (TBMVideo *) nextPlayableVideoAfterVideo:(TBMVideo *)video{
    BOOL found = NO;
    for (TBMVideo *v in [self sortedIncomingVideos]){
        if (found && [v videoFileExists])
            return v;
        
        if ([video isEqual:v])
            found = YES;
    }
    return nil;
}

- (BOOL)incomingVideoNotViewed{
    //Return true if any of the videos are status DOWNLOADED
    OB_INFO(@"incomingVideoNotViewed looking for status=%ld", (long)INCOMING_VIDEO_STATUS_DOWNLOADED);
    [TBMVideo printAll];
    BOOL r = NO;
    for (TBMVideo *v in [self sortedIncomingVideos]){
        OB_INFO(@"incomingVideoNotViewed %@ status=%d", self.firstName, v.statusValue);
        if (v.status == INCOMING_VIDEO_STATUS_DOWNLOADED){
            OB_INFO(@"incomingVideoNotViewed  NOT_VIEWED %@ status=%d", self.firstName, v.statusValue);
            r = YES;
            break;
        }
    }
    return r;
}

- (void)setViewedWithIncomingVideo:(TBMVideo *)video{
    [self setAndNotifyIncomingVideoStatus:INCOMING_VIDEO_STATUS_VIEWED video:video];
    [[TBMFriend appDelegate] sendNotificationForVideoStatusUpdate:self videoId:video.videoId status:NOTIFICATION_STATUS_VIEWED];
}

//------
// Thumb
//------
- (NSURL *)thumbUrlOrThumbMissingUrl{
    OB_INFO(@"thumbUrlOrThumbMissingUrl: for %@ videoCount=%lu", self.firstName, (unsigned long)[[self sortedIncomingVideos] count]);
    NSURL *thumb = [TBMConfig thumbMissingUrl];
    for (TBMVideo *v in [self sortedIncomingVideos]){
        if ([v hasThumb]){
            OB_INFO(@"videoId %@ has thumb", v.videoId);
            thumb = [v thumbUrl];
        }
    }
    return thumb;
}

- (UIImage *)thumbImageOrThumbMissingImage{
    return [UIImage imageWithContentsOfFile:[self thumbUrlOrThumbMissingUrl].path];
}

//-------------------------------------
// VideoStatus Delegates and UI Strings
//-------------------------------------
// I just could not get KVO to work reliably on attributes of a managedModel.
// So I rolled my own notification registry.
// In hindsight I should have probably used the NSNotificationCenter for this rather than rolling my own.

+ (void)addVideoStatusNotificationDelegate:(id)delegate{
    if (!videoStatusNotificationDelegates) {
        videoStatusNotificationDelegates = [[NSMutableArray alloc] init];
    }
    [TBMFriend removeVideoStatusNotificationDelegate:delegate];
    [videoStatusNotificationDelegates addObject:delegate];
}

+ (void)removeVideoStatusNotificationDelegate:(id)delegate{
    [videoStatusNotificationDelegates removeObject:delegate];
}

- (void)notifyVideoStatusChangeOnMainThread{
    DebugLog(@"notifyVideoStatusChangeOnMainThread");
    [self performSelectorOnMainThread:@selector(notifyVideoStatusChange) withObject:nil waitUntilDone:YES];
}

- (void)notifyVideoStatusChange{
    DebugLog(@"notifyVideoStatusChange for %@ on %lu delegates", self.firstName, (unsigned long)[videoStatusNotificationDelegates count]);
    for (id<TBMVideoStatusNotoficationProtocol> delegate in videoStatusNotificationDelegates){
        [delegate videoStatusDidChange:self];
    }
}

- (NSString *)videoStatusString{
    if (self.lastVideoStatusEventType == OUTGOING_VIDEO_STATUS_EVENT_TYPE) {
        return [self outgoingVideoStatusString];
    } else {
        return [self incomingVideoStatusString];
    }
}

- (NSString *)incomingVideoStatusString{
    TBMVideo *v = [self newestIncomingVideo];
    if (v == NULL)
        return self.firstName;
    
    if (v.status == INCOMING_VIDEO_STATUS_DOWNLOADING){
        if ([v.downloadRetryCount intValue] == 0){
            return @"Downloading...";
        } else {
            return [NSString stringWithFormat:@"Downloading r%@", v.downloadRetryCount];
        }
    } else if (v.status == INCOMING_VIDEO_STATUS_FAILED_PERMANENTLY){
        return @"Downloading e!";
    } else {
        return self.firstName;
    }
}

- (NSString *)outgoingVideoStatusString{
    NSString *statusString;
    switch (self.outgoingVideoStatus) {
        case OUTGOING_VIDEO_STATUS_NEW:
            statusString = @"q...";
            break;
        case OUTGOING_VIDEO_STATUS_UPLOADING:
            if (self.uploadRetryCount == 0) {
                statusString = @"p...";
            } else {
                statusString = [NSString stringWithFormat:@"r%ld...", (long)[self.uploadRetryCount integerValue]];
            }
            break;
        case OUTGOING_VIDEO_STATUS_UPLOADED:
            statusString = @".s..";
            break;
        case OUTGOING_VIDEO_STATUS_DOWNLOADED:
            statusString = @"..p.";
            break;
        case OUTGOING_VIDEO_STATUS_VIEWED:
            statusString = @"v!";
            break;
        case OUTGOING_VIDEO_STATUS_FAILED_PERMANENTLY:
            statusString = @"e!";
        default:
            statusString = nil;
    }
    
    NSString *fn = (statusString == nil || self.outgoingVideoStatus == OUTGOING_VIDEO_STATUS_VIEWED) ? self.firstName : [self shortFirstName];
    return [NSString stringWithFormat:@"%@ %@", fn, statusString];
}

- (NSString *)shortFirstName{
    return [self.firstName substringWithRange:NSMakeRange(0, MIN(6, [self.firstName length]))];
}

//---------------
// Setting status
//---------------
- (void)setAndNotifyOutgoingVideoStatus:(TBMOutgoingVideoStatus)status videoId:(NSString *)videoId{
    OB_INFO(@"setAndNotifyOutgoingVideoStatus");

    if (![videoId isEqual: self.outgoingVideoId]){
        OB_WARN(@"setAndNotifyOutgoingVideoStatus: Unrecognized vidoeId:%@. != ougtoingVid:%@. friendId:%@ Ignoring.", videoId, self.outgoingVideoId, self.idTbm);
        return;
    }
    
    if (status == self.outgoingVideoStatus){
        OB_WARN(@"setAndNotifyOutgoingVideoStatusWithVideo: Identical status. Ignoring.");
        return;
    }
    
    self.lastVideoStatusEventType = OUTGOING_VIDEO_STATUS_EVENT_TYPE;
    self.outgoingVideoStatus = status;
    [self notifyVideoStatusChangeOnMainThread];
}

- (void)setAndNotifyIncomingVideoStatus:(TBMIncomingVideoStatus)status video:(TBMVideo *)video{
    OB_INFO(@"setAndNotifyIncomingVideoStatus");
    if (video.status == status){
        OB_WARN(@"setAndNotifyIncomingVideoStatusWithVideo: Identical status. Ignoring.");
        return;
    }
    
    video.status = status;
    self.lastIncomingVideoStatus = status;
    self.lastVideoStatusEventType = INCOMING_VIDEO_STATUS_EVENT_TYPE;
    [self notifyVideoStatusChangeOnMainThread];
}

// --------------------
// Setting Retry Counts
// --------------------
- (void)setAndNotifyUploadRetryCount:(NSNumber *)retryCount videoId:(NSString *)videoId{
    if (![videoId isEqual:self.outgoingVideoId]){
        OB_WARN(@"setAndNotifyUploadRetryCount: Unrecognized vidoeId. Ignoring.");
        return;
    }
    
    if (retryCount != self.uploadRetryCount){
        self.uploadRetryCount = retryCount;
        [self notifyVideoStatusChangeOnMainThread];
    }
}

- (void)setAndNotifyDownloadRetryCount:(NSNumber *)retryCount video:(TBMVideo *)video{
    if (video.downloadRetryCount == retryCount)
        return;
    
    video.downloadRetryCount = retryCount;
    
    if ([self isNewestIncomingVideo:video]) {
        [self notifyVideoStatusChangeOnMainThread];
    }
}

//--------------------
// Init outgoing video
//--------------------
- (void)handleAfterOutgoingVideoCreated{
    self.uploadRetryCount = 0;
    self.outgoingVideoId = [TBMVideoIdUtils generateId];
    OB_INFO(@"handleAfterOutgoingVideoCreated: set outgoingVideoId = %@", self.outgoingVideoId);
    [self setAndNotifyOutgoingVideoStatus:OUTGOING_VIDEO_STATUS_NEW videoId:self.outgoingVideoId];
}

@end