//
//  TBMVideo.m
//  tbm
//
//  Created by Sani Elfishawy on 8/5/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "AVFoundation/AVFoundation.h"

#import "TBMVideo.h"
#import "TBMFriend.h"
#import "TBMAppDelegate.h"
#import "TBMConfig.h"
#import "OBLogger.h"


@implementation TBMVideo

@dynamic status;
@dynamic videoId;
@dynamic friend;
@dynamic downloadRetryCount;


//==============
// Class methods
//==============
+ (TBMAppDelegate *)appDelegate{
    return [[UIApplication sharedApplication] delegate];
}

+ (NSManagedObjectContext *)managedObjectContext{
    return [[TBMVideo appDelegate] managedObjectContext];
}

+ (NSEntityDescription *)entityDescription{
    return [NSEntityDescription entityForName:@"TBMVideo" inManagedObjectContext:[TBMVideo managedObjectContext]];
}


//-------------------
// Create and destroy
//-------------------
+ (instancetype)new{
    TBMVideo *video = (TBMVideo *)[[NSManagedObject alloc] initWithEntity:[TBMVideo entityDescription] insertIntoManagedObjectContext:[TBMVideo managedObjectContext]];
    video.downloadRetryCount = [NSNumber numberWithInt:0];
    video.status = INCOMING_VIDEO_STATUS_NEW;
    return video;
}

+ (instancetype) newWithVideoId:(NSString *)videoId{
    TBMVideo *video = [TBMVideo new];
    video.videoId = videoId;
    return video;
}

//--------
// Finders
//--------
+ (NSFetchRequest *)fetchRequest{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[TBMVideo entityDescription]];
    return request;
}

+ (instancetype)findWithVideoId:(NSString *)videoId{
    return [self findWithAttributeKey:@"videoId" value:videoId];
}


+ (instancetype)findWithAttributeKey:(NSString *)key value:(id)value{
    return [[self findAllWithAttributeKey:key value:value] lastObject];
}

+ (NSArray *)findAllWithAttributeKey:(NSString *)key value:(id)value{
    NSFetchRequest *request = [TBMVideo fetchRequest];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", key, value];
    [request setPredicate:predicate];
    NSError *error = nil;
    return [[TBMVideo managedObjectContext] executeFetchRequest:request error:&error];
}

+ (NSUInteger)unviewedCount{
    return [[TBMVideo findAllWithAttributeKey:@"status" value:[NSNumber numberWithInt:INCOMING_VIDEO_STATUS_DOWNLOADED]] count];
}

+ (NSArray *)all{
    NSError *error;
    return [[TBMVideo managedObjectContext] executeFetchRequest:[TBMVideo fetchRequest] error:&error];
}

+ (NSUInteger)count{
    return [[TBMVideo all] count];
}

+ (void)printAll{
    OB_INFO(@"All Videos (%lu)", (unsigned long)[TBMVideo count]);
    for (TBMVideo * v in [TBMVideo all]){
        OB_INFO(@"%@ %@ status=%d", v.friend.firstName, v.videoId, v.status);
    }
}

//=================
// Instance methods
//=================

- (void) deleteFiles{
    [self deleteVideoFile];
    [self deleteThumbFile];
}

//----------------
// Video URL stuff
//----------------
- (NSURL *)videoUrl{
    NSString *filename = [NSString stringWithFormat:@"incomingVidFromFriend_%@-VideoId_%@", self.friend.idTbm, self.videoId];
    return [[TBMConfig videosDirectoryUrl] URLByAppendingPathComponent:[filename stringByAppendingPathExtension:@"mp4"]];
}

- (NSString *)videoPath{
    return [self videoUrl].path;
}

- (BOOL)videoFileExists{
    return [[NSFileManager defaultManager] fileExistsAtPath:[self videoPath]];
}

- (unsigned long long)videoFileSize{
    if (![self videoFileExists])
        return 0;
    
    NSError *error;
    NSDictionary *fa = [[NSFileManager defaultManager] attributesOfItemAtPath:[self videoPath] error:&error];
    if (error)
        return 0;
    
    return fa.fileSize;
}

- (BOOL) hasValidVideoFile{
    return [self videoFileSize] > 0;
}

- (void)deleteVideoFile{
    DebugLog(@"deleteVideoFile");
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error = nil;
    [fm removeItemAtURL:[self videoUrl] error:&error];
}


//----------------
// Thumb URL stuff
//----------------
- (NSURL *)thumbUrl{
    NSString *filename = [NSString stringWithFormat:@"thumbFromFriend_%@-VideoId_%@", self.friend.idTbm, self.videoId];
    return [[TBMConfig videosDirectoryUrl] URLByAppendingPathComponent:[filename stringByAppendingPathExtension:@"png"]];
}

- (NSString *)thumbPath{
    return [self thumbUrl].path;
}

- (BOOL)hasThumb{
    return [[NSFileManager defaultManager] fileExistsAtPath:[self thumbPath]];
}

- (void)generateThumb{
    DebugLog(@"generateThumb for %@", self.friend.firstName);
    if (![self hasValidVideoFile])
        return;
    
    AVAsset *asset = [AVAsset assetWithURL:[self videoUrl]];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
    imageGenerator.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMake(1, 1);
    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
    UIImage *thumbnail = [UIImage imageWithCGImage:imageRef scale:1.0 orientation:UIImageOrientationUp];
    CGImageRelease(imageRef);  // CGImageRef won't be released by ARC
    [UIImagePNGRepresentation(thumbnail) writeToURL:[self thumbUrl] atomically:YES];
}

- (void)deleteThumbFile{
    DebugLog(@"deleteThumbFile");
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error = nil;
    [fm removeItemAtURL:[self thumbUrl] error:&error];
}

@end