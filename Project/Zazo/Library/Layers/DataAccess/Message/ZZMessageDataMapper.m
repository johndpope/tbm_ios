//
//  ZZMessageDataMapper.m
//  Zazo
//
//  Created by Server on 28/07/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

#import "ZZMessageDataMapper.h"
#import "TBMFriend.h"
#import "ZZFriendDataProvider+Entities.h"

@implementation ZZMessageDataMapper

+ (void)fillModel:(ZZMessageDomainModel *)model fromEntity:(TBMMessage *)entity
{
    model.body = [entity.body copy];
    model.messageID = [entity.messageID copy];
    model.friendID = entity.friend.idTbm;
    model.type = entity.typeValue;
}

+ (void)fillEntity:(TBMMessage *)entity fromModel:(ZZMessageDomainModel *)model
{
    if (!entity)
    {
        return;
    }
    
    @try
    {
        entity.body = [model.body copy];
        entity.messageID = [model.messageID copy];
        entity.friend = [ZZFriendDataProvider friendEntityWithItemID:model.friendID];
        entity.type = @(model.type);
    }
    
    @catch (NSException *exception)
    {
        ZZLogError(@"Exception: %@", exception);
    }
}

@end
