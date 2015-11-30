//
//  ZZFriendsTransportService.m
//  Zazo
//
//  Created by ANODA on 8/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZFriendsTransportService.h"
#import "ZZFriendsTransport.h"
#import "NSObject+ANSafeValues.h"
#import "ZZEditFriendEnumsAdditions.h"
#import "ZZPhoneHelper.h"
#import "FEMObjectDeserializer.h"
#import "ZZFriendDataUpdater.h"
#import "ZZFriendDataProvider.h"

static const struct
{
    __unsafe_unretained NSString *phoneNumber;
    __unsafe_unretained NSString *firstName;
    __unsafe_unretained NSString *lastName;
    __unsafe_unretained NSString *mKey;
    __unsafe_unretained NSString *cKey;
    __unsafe_unretained NSString *itemID;
    __unsafe_unretained NSString *isUserHasApp;
    __unsafe_unretained NSString *friendMkey;
    __unsafe_unretained NSString *visibility;
} ZZFriendsServerParameters =
{
    .phoneNumber = @"mobile_number",
    .firstName = @"first_name",
    .lastName = @"last_name",
    .mKey = @"mkey",
    .cKey = @"ckey",
    .itemID = @"id",
    .isUserHasApp = @"has_app",
    .friendMkey = @"friend_mkey",
    .visibility = @"visibility",
};

static const struct
{
    __unsafe_unretained NSString *phoneNumber;
    __unsafe_unretained NSString *firstName;
    __unsafe_unretained NSString *lastName;
    
} ZZInvitationsServerParameters =
{
    .phoneNumber = @"mobile_number",
    .firstName = @"first_name",
    .lastName = @"last_name",
};


@implementation ZZFriendsTransportService

+ (RACSignal*)loadFriendList
{
    return [[ZZFriendsTransport loadFriendList] map:^id(NSArray* friendsData) {
        friendsData = [[friendsData.rac_sequence map:^id(id obj) {
            
            if ([obj isKindOfClass:[NSDictionary class]])
            {
                FEMObjectMapping* mapping = [ZZFriendDomainModel mapping];
                ZZFriendDomainModel* model = [FEMObjectDeserializer deserializeObjectExternalRepresentation:obj
                                                                                               usingMapping:mapping];
                obj = [ZZFriendDataUpdater upsertFriend:model];
                return obj;
            }
            return nil;
        }] array];
//        
//        
//        NSArray *sorted = [self sortedFriendsByCreatedOn:friendsdat];
//        if (sorted)
//        {
//            NSDictionary *firstFriend = sorted.firstObject;
//            NSString *firstFriendCreatorMkey = firstFriend[@"connection_creator_mkey"];
//            ZZUserDomainModel* user = [ZZUserDataProvider authenticatedUser];
//            NSString *myMkey = user.mkey;
//            user.isInvitee = ![firstFriendCreatorMkey isEqualToString:myMkey];
//            ANDispatchBlockToBackgroundQueue(^{
//                [ZZUserDataProvider upsertUserWithModel:user];
//            });
//        }
//        
        return friendsData;
    }];
}

+ (RACSignal*)changeModelContactStatusForUser:(NSString *)userKey toVisible:(BOOL)visible
{
    NSParameterAssert(userKey);
    
    NSString* isVisible = visible ? @"visible" : @"hidden";
    
    NSDictionary* parameters = @{ZZFriendsServerParameters.friendMkey : [NSObject an_safeString:userKey],
                                 ZZFriendsServerParameters.visibility : isVisible};
    
    return [ZZFriendsTransport changeContactVisibilityStatusWithParameters:parameters];
}


#pragma mark - Invitations

+ (RACSignal*)checkIsUserHasProfileWithPhoneNumber:(NSString*)phoneNumber
{
    NSParameterAssert(phoneNumber);
    
    NSString *formattedNumber = [ZZPhoneHelper formatMobileNumberToE164AndServerFormat:phoneNumber];
    NSDictionary* parameters = @{ZZFriendsServerParameters.phoneNumber : [NSObject an_safeString:formattedNumber]};
    return [ZZFriendsTransport checkIsUserHasProfileWithParameters:parameters];
}

+ (RACSignal*)updateUser:(NSString*)mKey withEmails:(NSArray*)emails
{
    NSParameterAssert(mKey);

    NSDictionary* parameters = @{@"mkey"    : [NSObject an_safeString:mKey],
                                 @"emails"  : emails ? : @[]};
    return [ZZFriendsTransport updateUserWithParameters:parameters];
}

+ (RACSignal*)inviteUserWithPhoneNumber:(NSString*)phoneNumber
                              firstName:(NSString*)firstName
                            andLastName:(NSString*)lastName
{
    NSParameterAssert(phoneNumber);
    NSParameterAssert(firstName);
    NSParameterAssert(lastName);
    
    NSString* formattedNumber = [ZZPhoneHelper formatMobileNumberToE164AndServerFormat:phoneNumber];
    
    firstName = [NSObject an_safeString:firstName];
    lastName = [NSObject an_safeString:lastName];
    
    firstName = [firstName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    lastName = [lastName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    NSDictionary* parameters = @{ZZInvitationsServerParameters.phoneNumber : [NSObject an_safeString:formattedNumber],
                                 ZZInvitationsServerParameters.firstName   : firstName,
                                 ZZInvitationsServerParameters.lastName    : lastName};
    
    return [ZZFriendsTransport inviteUserWithParameters:parameters];
}


//TODO: figure out for what we need invitee field in User Class

//- (NSArray *)sortedFriendsByCreatedOn:(NSArray *)friends
//{
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
//    [dateFormatter setLocale:enUSPOSIXLocale];
//    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
//
//    return [friends sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2)
//            {
//
//                NSComparisonResult result = NSOrderedSame;
//                NSDictionary *dict1 = (NSDictionary *) obj1;
//                NSDictionary *dict2 = (NSDictionary *) obj2;
//                NSDate *date1;
//                NSDate *date2;
//
//                if ([dict1 isKindOfClass:[NSDictionary class]] && [dict2 isKindOfClass:[NSDictionary class]])
//                {
//
//                    date1 = [dateFormatter dateFromString:dict1[@"connection_created_on"]];
//                    date2 = [dateFormatter dateFromString:dict2[@"connection_created_on"]];
//                }
//
//                if (date1 && date2)
//                {
//                    result = [date1 timeIntervalSinceDate:date2] > 0 ? NSOrderedDescending : NSOrderedAscending;
//                }
//                return result;
//            }];
//}


@end
