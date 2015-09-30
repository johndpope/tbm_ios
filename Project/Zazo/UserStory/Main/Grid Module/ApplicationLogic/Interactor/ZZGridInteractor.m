//
//  ZZGridInteractor.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZGridInteractor.h"
#import "ZZContactDomainModel.h"
#import "ZZFriendDomainModel.h"
#import "ZZGridDomainModel.h"
#import "ZZGridDataProvider.h"
#import "ZZFriendDataProvider.h"
#import "ZZPhoneHelper.h"
#import "ZZUserDataProvider.h"
#import "ZZFriendsTransportService.h"
#import "ZZUserFriendshipStatusHandler.h"
#import "TBMFriend.h"
#import "ZZCommonModelsGenerator.h"
#import "ZZGridTransportService.h"
#import "ZZCommunicationDomainModel.h"
#import "ZZGridUIConstants.h"
#import "NSObject+ANRACAdditions.h"
#import "ZZGridDataUpdater.h"
#import "ZZFriendDataUpdater.h"

static NSInteger const kGridFriendsCellCount = 8;

@interface ZZGridInteractor () <TBMVideoStatusNotificationProtocol>

@end

@implementation ZZGridInteractor

- (void)loadData
{
    NSArray* gridModels = [self _generateGridModels];
    [self.output dataLoadedWithArray:gridModels];
    
    [TBMFriend addVideoStatusNotificationDelegate:self];
}

- (NSArray*)_gridModels
{
    NSArray* gridModels = [ZZGridDataProvider loadAllGridsSortByIndex:NO];
    NSSortDescriptor* sort = [NSSortDescriptor sortDescriptorWithKey:@"indexPathIndexForItem" ascending:YES];
    return [gridModels sortedArrayUsingDescriptors:@[sort]];
}

#pragma mark - Grid Updates

- (void)addUserToGrid:(id)friendModel
{
    if (!ANIsEmpty(friendModel))
    {
        if ([friendModel isKindOfClass:[ZZFriendDomainModel class]])
        {
            [self _addUserAsFriendToGrid:(ZZFriendDomainModel*)friendModel fromNotification:NO];
        }
        else if ([friendModel isKindOfClass:[ZZContactDomainModel class]])
        {
            [self _addUserAsContactToGrid:(ZZContactDomainModel*)friendModel];
        }
    }
}

- (void)removeUserFromContacts:(ZZFriendDomainModel*)model
{
    BOOL isContainedOnGrid = [ZZGridDataProvider isRelatedUserOnGridWithID:model.idTbm];
    if (isContainedOnGrid)
    {
        ZZGridDomainModel* gridModel = [ZZGridDataProvider modelWithRelatedUserID:model.idTbm];
        gridModel = [ZZGridDataUpdater updateRelatedUserOnItemID:gridModel.itemID toValue:nil];
        [self updateLastActionForFriend:model];
        [self.output updateGridWithModel:gridModel];
        
        ZZFriendDomainModel *fillHoleOnGrid = [self _loadFirstFriendFromMenu:[ZZFriendDataProvider loadAllFriends]];
        if (!ANIsEmpty(fillHoleOnGrid))
        {
            [self addUserToGrid:fillHoleOnGrid];
        }
    }
}

- (ZZFriendDomainModel*)_loadFirstFriendFromMenu:(NSArray *)array
{
    NSMutableArray* friendsHasAppArray = [NSMutableArray new];
    NSMutableArray* otherFriendsArray = [NSMutableArray new];
    
    NSArray* gridUsers = [ZZFriendDataProvider friendsOnGrid];
    if (!gridUsers)
    {
        gridUsers = @[];
    }
    
    [array enumerateObjectsUsingBlock:^(ZZFriendDomainModel* friend, NSUInteger idx, BOOL *stop) {
        
        //check if user is on grid - do not add him
        if (![gridUsers containsObject:friend])
        {
            if (friend.hasApp)
            {
                [friendsHasAppArray addObject:friend];
            }
            else
            {
                [otherFriendsArray addObject:friend];
            }
        }
    }];
    
    NSArray *filteredFriendsHasAppArray = [self _filterFriendByConnectionStatus:friendsHasAppArray];
    NSArray *filteredOtherFriendsArray = [self _filterFriendByConnectionStatus:otherFriendsArray];
    
    NSArray* allFilteredFriendsArray = [filteredFriendsHasAppArray arrayByAddingObjectsFromArray:filteredOtherFriendsArray];
    NSArray* sortedByFirstNameArray = [self _sortByFirstName:allFilteredFriendsArray];
    
    if (!ANIsEmpty(sortedByFirstNameArray))
    {
        return [sortedByFirstNameArray firstObject];
    }
    else
    {
        return nil;
    }
}

- (NSArray*)_filterFriendByConnectionStatus:(NSMutableArray*)friendsArray
{
    NSMutableArray* filteredFriends = [NSMutableArray new];
    
    [friendsArray enumerateObjectsUsingBlock:^(ZZFriendDomainModel* friendModel, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([friendModel isCreator])
        {
            if (friendModel.friendshipStatusValue == ZZFriendshipStatusTypeEstablished ||
                friendModel.friendshipStatusValue == ZZFriendshipStatusTypeHiddenByCreator)
            {
                [filteredFriends addObject:friendModel];
            }
        }
        else
        {
            if (friendModel.friendshipStatusValue == ZZFriendshipStatusTypeEstablished ||
                friendModel.friendshipStatusValue == ZZFriendshipStatusTypeHiddenByTarget)
            {
                [filteredFriends addObject:friendModel];
            }
        }
    }];
    
    return filteredFriends;
}

- (NSArray *)_sortByFirstName:(NSArray *)array
{
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES]; // TODO: constant
    NSArray* sortedArray = [array sortedArrayUsingDescriptors:@[sort]];
    
    return sortedArray;
}



#pragma mark - User Invitation

- (void)userSelectedPrimaryPhoneNumber:(ZZContactDomainModel*)phoneNumber
{
    [self _checkIsContactHasApp:phoneNumber];
}

- (void)inviteUserInApplication:(ZZContactDomainModel*)contact
{
    [self _loadFriendModelFromContact:contact];
}

- (void)updateLastActionForFriend:(ZZFriendDomainModel*)friendModel
{
    [ZZFriendDataUpdater updateLastTimeActionFriendWithID:friendModel.idTbm];
}



#pragma mark - Update after stoppedVideo

- (void)updateFriendAfterVideoStopped:(ZZFriendDomainModel *)model
{
    [self updateLastActionForFriend:model];
    [self.output reloadGridWithData:[self _generateGridModels]];
}


#pragma mark - Notifications

- (void)handleNotificationForFriend:(TBMFriend*)friendEntity
{
    ZZFriendDomainModel* model = [ZZFriendDataProvider modelFromEntity:friendEntity];
    [self _addUserAsFriendToGrid:model fromNotification:YES];
}

- (void)showDownloadAniamtionForFriend:(TBMFriend *)friend
{
    // TODO:
}


#pragma mark - Feedback

- (void)loadFeedbackModel
{
    ZZUserDomainModel* user = [ZZUserDataProvider authenticatedUser];
    [self.output feedbackModelLoadedSuccessfully:[ZZCommonModelsGenerator feedbackModelWithUser:user]];
}


#pragma mark - Private

- (ZZFriendDomainModel*)_friendOnGridMatchedToContact:(ZZContactDomainModel*)contactModel
{
    __block ZZFriendDomainModel* containtedUser = nil;
    
    [[self _gridModels] enumerateObjectsUsingBlock:^(ZZGridDomainModel* obj, NSUInteger idx, BOOL *stop) {
        if ([[obj.relatedUser fullName] isEqualToString:[contactModel fullName]])
        {
            containtedUser = obj.relatedUser;
            *stop = YES;
        }
    }];
    
    if (!containtedUser)
    {
        NSArray* validNumbers = [ZZPhoneHelper validatePhonesFromContactModel:contactModel];
        if (!ANIsEmpty(validNumbers))
        {
            [validNumbers enumerateObjectsUsingBlock:^(ZZCommunicationDomainModel* communicationModel, NSUInteger idx, BOOL *stop) {
                
                NSString *trimmedNumber = [communicationModel.contact stringByReplacingOccurrencesOfString:@" " withString:@""];
                
                [[self _gridModels] enumerateObjectsUsingBlock:^(ZZGridDomainModel* obj, NSUInteger idx, BOOL *stop) {
                    if ([[obj.relatedUser mobileNumber] isEqualToString:trimmedNumber])
                    {
                        containtedUser = obj.relatedUser;
                        *stop = YES;
                    }
                }];
            }];
        }
    }
    return containtedUser;
}



#pragma mark - Private

- (ZZGridDomainModel*)_loadGridModelWithLatestAction
{
    NSArray *sortingByLastAction = [self _gridModels];
    
    NSSortDescriptor* secriptor = [NSSortDescriptor sortDescriptorWithKey:@"relatedUser.lastActionTimestamp" ascending:YES];
    sortingByLastAction = [sortingByLastAction sortedArrayUsingDescriptors:@[secriptor]];
    
    return [sortingByLastAction firstObject];
}

- (void)_addUserAsFriendToGrid:(ZZFriendDomainModel*)friendModel fromNotification:(BOOL)isFromNotification
{
    BOOL isUserAlreadyOnGrid = [ZZGridDataProvider isRelatedUserOnGridWithID:friendModel.idTbm];
   
    if (!isUserAlreadyOnGrid)
    {
        BOOL shouldBeVisible = [ZZUserFriendshipStatusHandler shouldFriendBeVisible:friendModel];
        if (!shouldBeVisible)
        {
            ZZFriendshipStatusType status = [ZZUserFriendshipStatusHandler switchedContactStatusTypeForFriend:friendModel];
            friendModel = [ZZFriendDataUpdater updateConnectionStatusForUserWithID:friendModel.idTbm toValue:status];
            
            [[ZZFriendsTransportService changeModelContactStatusForUser:friendModel.mKey
                                                              toVisible:!shouldBeVisible] subscribeNext:^(NSDictionary* response) {
            }];
        }
        
        ZZGridDomainModel* model = [ZZGridDataProvider loadFirstEmptyGridElement];
        
        if (ANIsEmpty(model))
        {
            model = [self _loadGridModelWithLatestAction];
        }
        
        model = [ZZGridDataUpdater updateRelatedUserOnItemID:model.itemID toValue:friendModel];
        
        [self updateLastActionForFriend:model.relatedUser];
        if (isFromNotification)
        {
            [self.output updateGridWithModelFromNotification:model isNewFriend:!isUserAlreadyOnGrid];
        }
        else
        {
            [self.output updateGridWithModel:model];
        }
    }
    else
    {
        if (isFromNotification)
        {
            ZZGridDomainModel* gridModel = [ZZGridDataProvider modelWithRelatedUserID:friendModel.idTbm];
            [self.output updateGridWithModelFromNotification:gridModel isNewFriend:!isUserAlreadyOnGrid];
        }
        else
        {
            [self.output gridAlreadyContainsFriend:friendModel];
        }
    }
}

- (void)_addUserAsContactToGrid:(ZZContactDomainModel*)model
{
    ZZFriendDomainModel* containedUser = [self _friendOnGridMatchedToContact:model];
    if (!ANIsEmpty(containedUser))
    {
        [self.output gridAlreadyContainsFriend:containedUser];
    }
    else
    {
        model.phones = [ZZPhoneHelper validatePhonesFromContactModel:model];
        if (!ANIsEmpty(model.phones))
        {
            if (ANIsEmpty(model.primaryPhone))
            {
                [self.output userNeedsToPickPrimaryPhone:model];
            }
            else
            {
                [self _checkIsContactHasApp:model];
            }
        }
        else
        {
            [self.output userHasNoValidNumbers:model];
        }
    }
}


#pragma mark - TBMFriend Delegate 

- (void)videoStatusDidChange:(TBMFriend*)model
{
    [self.output reloadGridWithData:[self _gridModels]];
}


#pragma mark - Transport

- (void)_checkIsContactHasApp:(ZZContactDomainModel*)contact
{
    [self.output loadedStateUpdatedTo:YES];
    [[ZZGridTransportService checkIsUserHasApp:contact] subscribeNext:^(id x) {
        if ([x boolValue])
        {
            [self _loadFriendModelFromContact:contact];
        }
        else
        {
            [self.output loadedStateUpdatedTo:NO];
            [self.output userHasNoAppInstalled:contact];
        }
    } error:^(NSError *error) {
        [self.output loadedStateUpdatedTo:NO];
        [self.output addingUserToGridDidFailWithError:error forUser:contact];
    }];
}

- (void)_loadFriendModelFromContact:(ZZContactDomainModel*)contact
{
    [[ZZGridTransportService inviteUserToApp:contact] subscribeNext:^(ZZFriendDomainModel* x) {
        [self.output friendRecievedFromServer:x];
        [self.output loadedStateUpdatedTo:NO];

    } error:^(NSError *error) {
        [self.output loadedStateUpdatedTo:NO];
        [self.output addingUserToGridDidFailWithError:error forUser:contact];
    }];
}


#pragma mark - Loading

- (NSArray*)_generateGridModels
{
    NSArray* allfriends = [ZZFriendDataProvider loadAllFriends];
    NSMutableArray* filteredFriends = [NSMutableArray new];
    
    [allfriends enumerateObjectsUsingBlock:^(ZZFriendDomainModel* friendModel, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([friendModel isCreator])
        {
            if (friendModel.friendshipStatusValue == ZZFriendshipStatusTypeEstablished ||
                friendModel.friendshipStatusValue == ZZFriendshipStatusTypeHiddenByCreator)
            {
                [filteredFriends addObject:friendModel];
            }
        }
        else
        {
            if (friendModel.friendshipStatusValue == ZZFriendshipStatusTypeEstablished ||
                friendModel.friendshipStatusValue == ZZFriendshipStatusTypeHiddenByTarget)
            {
                [filteredFriends addObject:friendModel];
            }
        }
    }];
    
    [filteredFriends sortedArrayUsingComparator:^NSComparisonResult(ZZFriendDomainModel* obj1, ZZFriendDomainModel* obj2) {
        return [obj1.lastActionTimestamp compare:obj2.lastActionTimestamp];
    }];
    
    NSArray* gridStoredModels = [ZZGridDataProvider loadAllGridsSortByIndex:YES];
    NSMutableArray* gridModels = [NSMutableArray array];
    
    if (gridStoredModels.count != kGridFriendsCellCount)
    {
        for (NSInteger count = 0; count < kGridFriendsCellCount; count++)
        {
            ZZGridDomainModel* model;
            if (gridStoredModels.count > count)
            {
                model = gridStoredModels[count];
            }
            else
            {
                model = [ZZGridDomainModel new];
            }
            model.index = count;
            if (filteredFriends.count > count)
            {
                ZZFriendDomainModel *aFriend = filteredFriends[count];
                model.relatedUser = aFriend;
            }
            
            model = [ZZGridDataUpdater upsertModel:model];
            [gridModels addObject:model];
        }
    }
    else
    {
        gridModels = [gridStoredModels mutableCopy];
    }
    
    NSSortDescriptor* sort = [NSSortDescriptor sortDescriptorWithKey:@"indexPathIndexForItem" ascending:YES];
    return [gridModels sortedArrayUsingDescriptors:@[sort]];
}


@end
