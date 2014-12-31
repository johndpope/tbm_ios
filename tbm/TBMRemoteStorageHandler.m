//
//  TBMRemoteStorageHandler.m
//  tbm
//
//  Created by Sani Elfishawy on 7/29/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "TBMRemoteStorageHandler.h"
#import "TBMFriend.h"
#import "TBMUser.h"
#import "TBMStringUtils.h"
#import "TBMHttpClient.h"
#import "OBLogger.h"
#import "TBMConfig.h"

@implementation TBMRemoteStorageHandler


//------------------------
// Keys for remote storage
//------------------------
+ (NSString *) incomingVideoRemoteFilename:(TBMVideo *)video{
    return [TBMRemoteStorageHandler incomingVideoRemoteFilenameWithFriend:video.friend videoId:video.videoId];
}

+ (NSString *) incomingVideoRemoteFilenameWithFriend:(TBMFriend *)friend videoId:(NSString *)videoId{
    return [NSString stringWithFormat:@"%@-%@-%@", [TBMRemoteStorageHandler incomingConnectionKey:friend], videoId, @"filename"];
}

+ (NSString *) outgoingVideoRemoteFilename:(TBMFriend *)friend{
    return [NSString stringWithFormat:@"%@-%@-%@", [TBMRemoteStorageHandler outgoingConnectionKey:friend], friend.outgoingVideoId, @"filename"];
}

+ (NSString *) incomingVideoIDRemoteKVKey:(TBMFriend *)friend{
    return [NSString stringWithFormat:@"%@-%@", [TBMRemoteStorageHandler incomingConnectionKey:friend], @"VideoIdKVKey"];
}

+ (NSString *) outgoingVideoIDRemoteKVKey:(TBMFriend *)friend{
    return [NSString stringWithFormat:@"%@-%@", [TBMRemoteStorageHandler outgoingConnectionKey:friend], @"VideoIdKVKey"];
}

+ (NSString *) incomingVideoStatusRemoteKVKey:(TBMFriend *)friend{
    return [NSString stringWithFormat:@"%@-%@", [TBMRemoteStorageHandler incomingConnectionKey:friend], @"VideoStatusKVKey"];
}

+ (NSString *) outgoingVideoStatusRemoteKVKey:(TBMFriend *)friend{
    return [NSString stringWithFormat:@"%@-%@", [TBMRemoteStorageHandler outgoingConnectionKey:friend], @"VideoStatusKVKey"];
}

+ (NSString *) incomingConnectionKey:(TBMFriend *)friend{
    return [NSString stringWithFormat:@"%@-%@", friend.mkey, [TBMUser getUser].mkey];
}

+ (NSString *) outgoingConnectionKey:(TBMFriend *)friend{
    return [NSString stringWithFormat:@"%@-%@", [TBMUser getUser].mkey, friend.mkey];
}

//-----------------------
// URLs for file transfer
//-----------------------
+ (NSString *) fileTransferRemoteUrlBase{
    return REMOTE_STORAGE_USE_S3 ? REMOTE_STORAGE_S3_BASE_URL_STRING : CONFIG_SERVER_BASE_URL_STRING;
}

+ (NSString *) fileTransferUploadPath{
    return REMOTE_STORAGE_USE_S3 ? REMOTE_STORAGE_S3_BUCKET : REMOTE_STORAGE_SERVER_VIDEO_UPLOAD_PATH;
}

+ (NSString *) fileTransferDownloadPath{
    return REMOTE_STORAGE_USE_S3 ? REMOTE_STORAGE_S3_BUCKET : REMOTE_STORAGE_SERVER_VIDEO_DOWNLOAD_PATH;
}

+ (NSString *) fileTransferDeletePath{
    return REMOTE_STORAGE_S3_BUCKET;
}

//-------------------------
// Simple http get and post
//-------------------------

+ (void) simpleGet:(NSString *)path params:(NSDictionary *)params{
    NSURLSessionDataTask *task = [[TBMHttpClient sharedClient]
        GET:path
        parameters:params
        success:^(NSURLSessionDataTask *task, id responseObject) {
         }
        failure:^(NSURLSessionDataTask *task, NSError *error) {
         }];
    [task resume];
}

+ (void) simplePost:(NSString *)path params:(NSDictionary *)params{
    NSURLSessionDataTask *task = [[TBMHttpClient sharedClient]
        POST:path
        parameters:params
        success:^(NSURLSessionDataTask *task, id responseObject) {
         }
        failure:^(NSURLSessionDataTask *task, NSError *error) {
         }];
    [task resume];
}


//------------------
// set and delete kv
//------------------
+ (void) setRemoteKVWithKey1:(NSString *)key1 key2:(NSString *)key2 value:(NSDictionary *)value{
    NSString *jsonValue = [TBMStringUtils jsonWithDictionary:value];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:@{@"key1": key1, @"value": jsonValue}];
    if (key2 != nil)
        [params setObject:key2 forKey:@"key2"];
    [TBMRemoteStorageHandler simplePost:@"kvstore/set" params:params];
}

+ (void) deleteRemoteKVWithKey1:(NSString *)key1 key2:(NSString *)key2{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:@{@"key1": key1}];
    if (key2 != nil)
        [params setObject:key2 forKey:@"key2"];
    [TBMRemoteStorageHandler simpleGet:@"kvstore/delete" params:params];
}

// Convenience setters
+ (void) addRemoteOutgoingVideoId:(NSString *)videoId friend:(TBMFriend *)friend{
    OB_INFO(@"addRemoteOutgoingVideoId");
    NSDictionary *value = @{REMOTE_STORAGE_VIDEO_ID_KEY: videoId};
    NSString *key1 = [TBMRemoteStorageHandler outgoingVideoIDRemoteKVKey:friend];
    [TBMRemoteStorageHandler setRemoteKVWithKey1:key1 key2:videoId value: value];
}

+ (void) deleteRemoteIncomingVideoId:(NSString *)videoId friend:(TBMFriend *)friend{
    OB_INFO(@"deleteRemoteIncomingVideoId");
    NSString *key1 = [TBMRemoteStorageHandler incomingVideoIDRemoteKVKey:friend];
    [TBMRemoteStorageHandler deleteRemoteKVWithKey1:key1 key2:videoId];
}

+ (void) setRemoteIncomingVideoStatus:(NSString *)status videoId:(NSString *)videoId friend:(TBMFriend *)friend{
    OB_INFO(@"setRemoteIncomingVideoStatus");
    NSDictionary *value = @{REMOTE_STORAGE_VIDEO_ID_KEY: videoId, REMOTE_STORAGE_STATUS_KEY: status};
    NSString *key = [TBMRemoteStorageHandler incomingVideoStatusRemoteKVKey:friend];
    [TBMRemoteStorageHandler setRemoteKVWithKey1:key key2:NULL value:value];
}


// Convenience getters

+ (void) getRemoteIncomingVideoIdsWithFriend:(TBMFriend *)friend gotVideoIds:(void(^)(NSArray *videoIds))gotVideoIds{
    NSString *key1 = [TBMRemoteStorageHandler incomingVideoIDRemoteKVKey:friend];
    [TBMRemoteStorageHandler getRemoteKVsWithKey:key1 success:^(NSArray *response) {
        NSArray *vIds = [TBMRemoteStorageHandler getVideoIdsWithResponseObjects:response];
        gotVideoIds(vIds);
    } failure:^(NSError *error) {
        OB_ERROR(@"getRemoteIncomingVideoIdsWithFriend: failure: %@", error);
    }];
}

+ (NSArray *)getVideoIdsWithResponseObjects:(NSArray *)responseObjects{
    NSMutableArray *vIds = [[NSMutableArray alloc] init];
    for (NSDictionary *r in responseObjects){
        NSString *valueJson = [r objectForKey:@"value"];
        NSDictionary *valueObj = [TBMStringUtils dictionaryWithJson:valueJson];
        [vIds addObject:[valueObj objectForKey:REMOTE_STORAGE_VIDEO_ID_KEY]];
    }
    return vIds;
}

//------------
// GetRemoteKV
//------------
+ (void) getRemoteKVsWithKey:(NSString *)key1 success:(void(^)(NSArray *response))success failure:(void(^)(NSError *error))failure{
    NSURLSessionDataTask *task = [[TBMHttpClient sharedClient]
    GET:@"kvstore/get_all"
    parameters:@{@"key1": key1}
    success:^(NSURLSessionDataTask *task, NSArray *responseObject) {
        success(responseObject);
    }
    failure:^(NSURLSessionDataTask *task, NSError *error) {
        OB_ERROR(@"ERROR: getRemoteKVWithKey: %@", [error localizedDescription]);
        failure(error);
    }];
    [task resume];
}



@end
