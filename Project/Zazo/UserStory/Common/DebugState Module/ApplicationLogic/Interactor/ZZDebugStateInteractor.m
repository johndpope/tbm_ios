//
//  ZZDebugStateInteractor.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZDebugStateInteractor.h"
#import "TBMFriend.h"
#import "TBMFriendVideosInformation.h"
#import "TBMVideoObject.h"
#import "ZZDebugStateEnumHelper.h"
#import "ZZDebugStateDomainModel.h"
#import "ZZDebugStateItemDomainModel.h"
#import "NSObject+ANSafeValues.h"

@implementation ZZDebugStateInteractor

- (void)loadData
{
    //Dummy Data:
    
//    ZZDebugStateDomainModel* model = [ZZDebugStateDomainModel new];
//    model.userID = @"123456789";
//    model.username = @"test";
//    
//    model.incomingVideoItems =
//    @[[ZZDebugStateItemDomainModel itemWithItemID:@"1111111"
//                                           status:ZZVideoOutgoingStatusStringFromEnumValue(ZZVideoOutgoingStatusNew)],
//      [ZZDebugStateItemDomainModel itemWithItemID:@"1111112"
//                                           status:ZZVideoOutgoingStatusStringFromEnumValue(ZZVideoOutgoingStatusNone)],
//      [ZZDebugStateItemDomainModel itemWithItemID:@"1111113"
//                                           status:ZZVideoOutgoingStatusStringFromEnumValue(ZZVideoOutgoingStatusQueued)],
//      [ZZDebugStateItemDomainModel itemWithItemID:@"1111114"
//                                           status:ZZVideoOutgoingStatusStringFromEnumValue(ZZVideoOutgoingStatusViewed)],
//      [ZZDebugStateItemDomainModel itemWithItemID:@"1111115"
//                                           status:ZZVideoOutgoingStatusStringFromEnumValue(ZZVideoOutgoingStatusUploaded)],
//      [ZZDebugStateItemDomainModel itemWithItemID:@"1111116"
//                                           status:ZZVideoOutgoingStatusStringFromEnumValue(ZZVideoOutgoingStatusUploading)],
//      [ZZDebugStateItemDomainModel itemWithItemID:@"1111117"
//                                           status:ZZVideoOutgoingStatusStringFromEnumValue(ZZVideoOutgoingStatusDownloaded)]];
//    
//    NSArray* stateModels = @[model];
//    
//    NSArray* incomeDandling = @[@"123", @"234", @"345"];
//    NSArray* outcomeDandling = @[@"444", @"555", @"666"];
    
    NSArray* stateModels = [self _loadVideoData];

    NSArray* incomeDandling = [self _loadIncomeDandlingItemsFromDataBaseData:stateModels];
    NSArray* outcomeDandling = [self _loadOutgoingDandlingItemsFromDataBaseData:stateModels];
    
    [self.output dataLoadedWithAllVideos:stateModels incomeDandling:incomeDandling outcomeDandling:outcomeDandling];
}


#pragma mark - Private

- (NSArray*)_loadVideoData
{
    NSArray* friends = [TBMFriend all];
    
    NSArray* videoStateModels = [[friends.rac_sequence map:^id(TBMFriend* value) {
        return [self _debugModelFromUserEntity:value];
    }] array];
    
    return videoStateModels;
}

//TODO: copy-paste check it later
- (NSArray*)_loadIncomeDandlingItemsFromDataBaseData:(NSArray*)stateModels
{
    NSPredicate* incomingPredicate = [NSPredicate predicateWithFormat:@"pathExtension == 'mp4'"]; // TODO: constant
    NSArray* diskFileNamesIncoming = [self _loadVideoFilesWithPredicate:incomingPredicate];
    NSMutableSet* diskFileNamesIncomingSet = [NSMutableSet setWithArray:diskFileNamesIncoming];
    
    NSArray* dataBaseFileNamesIncoming = [stateModels valueForKeyPath:@"incomingVideoItems"]; // TODO: enum
    NSSet* databaseFileNamesIncomingSet = [NSSet setWithArray:dataBaseFileNamesIncoming];
    
    [diskFileNamesIncomingSet minusSet:databaseFileNamesIncomingSet];
    
    return [diskFileNamesIncomingSet allObjects];
}

- (NSArray*)_loadOutgoingDandlingItemsFromDataBaseData:(NSArray*)stateModels
{
    NSPredicate* incomingPredicate = [NSPredicate predicateWithFormat:@"pathExtension == 'mov'"];
    NSArray* diskFileNamesIncoming = [self _loadVideoFilesWithPredicate:incomingPredicate];
    NSMutableSet* diskFileNamesIncomingSet = [NSMutableSet setWithArray:diskFileNamesIncoming];
    
    NSArray* dataBaseFileNamesIncoming = [stateModels valueForKeyPath:@"outgoingVideoItems"];
    NSSet* databaseFileNamesIncomingSet = [NSSet setWithArray:dataBaseFileNamesIncoming];
    
    [diskFileNamesIncomingSet minusSet:databaseFileNamesIncomingSet];
    
    return [diskFileNamesIncomingSet allObjects];
}


- (ZZDebugStateDomainModel*)_debugModelFromUserEntity:(TBMFriend*)value
{
    ZZDebugStateDomainModel* model = [ZZDebugStateDomainModel new];
    
    model.username = value.fullName;
    model.incomingVideoItems = [[value.videos.rac_sequence map:^id(TBMVideo* videoEntity) {
        
        NSString* status = ZZVideoIncomingStatusStringFromEnumValue(videoEntity.statusValue);
        ZZDebugStateItemDomainModel* itemModel = [ZZDebugStateItemDomainModel itemWithItemID:videoEntity.videoId
                                                                                      status:status];
        return itemModel;
        
    }] array];
    
    NSString* status = ZZVideoOutgoingStatusStringFromEnumValue(value.outgoingVideoStatusValue);
    ZZDebugStateItemDomainModel* outgoing = [ZZDebugStateItemDomainModel itemWithItemID:value.outgoingVideoId
                                                                                 status:status];
    model.outgoingVideoItems = @[outgoing];
    
    return model;
}

- (NSArray*)_loadVideoFilesWithPredicate:(NSPredicate*)predicate
{
    NSURL *videoDirURL = [self _videosDirectoryUrl];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *contents = [fileManager contentsOfDirectoryAtURL:videoDirURL
                                   includingPropertiesForKeys:@[]
                                                      options:NSDirectoryEnumerationSkipsHiddenFiles
                                                        error:nil];
    
    contents = [contents filteredArrayUsingPredicate:predicate];
    
    return [[contents.rac_sequence map:^id(NSURL* value) {
        NSString* path = [value lastPathComponent];
        if (!ANIsEmpty(path))
        {
            return [NSObject an_safeString:path];
        }
        return nil;
    }] array];
}


#pragma mark - Private

- (NSURL*)_videosDirectoryUrl
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
}

@end
