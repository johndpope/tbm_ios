//
//  ZZFriendDataUpdater.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 9/30/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZFriendDataUpdater.h"
#import "MagicalRecord.h"
#import "TBMFriend.h"
#import "ZZFriendModelsMapper.h"
#import "ZZFriendDomainModel.h"

@implementation ZZFriendDataUpdater

+ (ZZFriendDomainModel*)updateLastTimeActionFriendWithID:(NSString*)itemID
{
    TBMFriend* item = [self _userWithID:itemID];
    item.timeOfLastAction = [NSDate new];
    [item.managedObjectContext MR_saveToPersistentStoreAndWait];
    return [ZZFriendModelsMapper fillModel:[ZZFriendDomainModel new] fromEntity:item];
}

+ (ZZFriendDomainModel*)updateConnectionStatusForUserWithID:(NSString *)itemID toValue:(ZZFriendshipStatusType)value
{
    TBMFriend* item = [self _userWithID:itemID];
    item.friendshipStatus = ZZFriendshipStatusTypeStringFromValue(value);
    [item.managedObjectContext MR_saveToPersistentStoreAndWait];
    return [ZZFriendModelsMapper fillModel:[ZZFriendDomainModel new] fromEntity:item];
}


#pragma mark - Private

+ (TBMFriend*)_userWithID:(NSString*)itemID
{
    TBMFriend* item = nil;
    if (!ANIsEmpty(itemID))
    {
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K == %@", TBMFriendAttributes.idTbm,itemID];
        NSArray* items = [TBMFriend MR_findAllWithPredicate:predicate inContext:[self _context]];
        if (items.count > 1)
        {
            ANLogWarning(@"TBMFriend contains dupples for tbmID = %@", itemID);
        }
        item = [items firstObject];
    }
    return item;
}

+ (NSManagedObjectContext*)_context
{
    return [NSManagedObjectContext MR_rootSavingContext];
}

@end
