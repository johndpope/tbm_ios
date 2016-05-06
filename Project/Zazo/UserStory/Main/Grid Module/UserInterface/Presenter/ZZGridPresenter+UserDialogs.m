//
//  ZZGridPresenter+UserDialogs.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 9/29/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZGridPresenter+UserDialogs.h"
#import "ZZGridAlertBuilder.h"
#import "ZZUserDataProvider.h"
#import "ZZFriendDomainModel.h"
#import "ZZContactDomainModel.h"
#import "ZZAPIRoutes.h"
#import "ZZAlertController.h"
#import "ZZTableModal.h"
#import "ZZGridPresenter+ActionHandler.h"
#import "ZZGridDataSource.h"
#import "ZZPhoneHelper.h"
#import "ZZContentDataAccessor.h"
#import "ZZFriendDataProvider.h"
#import "ZZCommunicationDomainModel.h"
#import "ZZUserDataProvider.h"

@implementation ZZGridPresenter (UserDialogs)

- (void)_showSendInvitationDialogForUser:(ZZContactDomainModel *)user
{
    if ([self _isNeedToShowDialogForUser:user])
    {
        [ZZGridAlertBuilder showSendInvitationDialogForUser:user.firstName completion:^{
            [self.interactor inviteUserInApplication:user];
        }];
    }
    else
    {
        [self.interactor inviteUserInApplication:user];
    }
}

- (BOOL)_isNeedToShowDialogForUser:(ZZContactDomainModel *)user
{
    __block BOOL isNeedShow = YES;
    NSArray *friends = [ZZFriendDataProvider allFriendsModels];
    NSString *userPhoneNumber = [user.primaryPhone.contact stringByReplacingOccurrencesOfString:@" " withString:@""];
    [friends enumerateObjectsUsingBlock:^(ZZFriendDomainModel *_Nonnull friendModel, NSUInteger idx, BOOL *_Nonnull stop) {
        if ([userPhoneNumber isEqualToString:friendModel.mobileNumber])
        {
            isNeedShow = NO;
            *stop = YES;
        }
    }];

    return isNeedShow;
}


- (void)_showConnectedDialogForModel:(ZZFriendDomainModel *)friendModel
{
    [self.interactor updateLastActionForFriend:friendModel];

    [ZZGridAlertBuilder showConnectedDialogForUser:friendModel.firstName completion:^{
        [self.interactor addUserToGrid:friendModel];

        if ([[self dataSource] frindsOnGridNumber] == 1)
        {
            [self _handleRecordHintWithCellViewModel:friendModel];
        }
        else //if ([[self dataSource] frindsOnGridNumber] == 2)
        {
            [self _handleSentWelcomeHintWithFriendDomainModel:friendModel];
        }
    }];
}

- (void)_showInvitationFormForModel:(ZZFriendDomainModel *)friendModel isNudge:(BOOL)isNudge
{
    NSString *text = [self _defaultInvitationMessageForModel:friendModel];

    [ZZGridAlertBuilder showInvitationMethodDialogWithText:text completion:^(ZZInviteType selectedType, NSString *text) {

        if (ANIsEmpty(text))
        {
            text = [self _defaultInvitationMessageForModel:friendModel];
        }

        switch (selectedType)
        {
            case ZZInviteTypeSharing:
                [self _showInvitationDialogType:ZZInviteTypeSharing
                                 forFriendModel:friendModel
                                  isNudgeAction:isNudge
                                 invitationText:text];
                break;

            case ZZInviteTypeSMS:
                [self _showInvitationDialogType:ZZInviteTypeSMS
                                 forFriendModel:friendModel
                                  isNudgeAction:isNudge
                                 invitationText:text];
                break;


            default:
                break;
        }
    }];
}

- (NSString *)_defaultInvitationMessageForModel:(ZZFriendDomainModel *)friendModel
{
    NSString *appName = [[NSBundle mainBundle] infoDictionary][@"CFBundleDisplayName"];
    NSString *appURL = [@[kInviteFriendBaseURL, @(friendModel.cid)] componentsJoinedByString:@""];

    ZZUserDomainModel *userModel = [ZZUserDataProvider authenticatedUser];

    NSString *message =
            [NSString stringWithFormat:@"%@, I sent you a quick video message on %@. I use it pretty often. It's especially great when driving. To see my message download Zazo from the app store or here: %@. Yes, it's legit/safe to install. -%@", friendModel.firstName, appName, appURL, userModel.fullName];

    return message;
}

- (void)_showInvitationDialogType:(ZZInviteType)type
                   forFriendModel:(ZZFriendDomainModel *)friendModel
                    isNudgeAction:(BOOL)isNudge
                   invitationText:(NSString *)text
{
    ANMessageDomainModel *model = [ANMessageDomainModel new];
    NSString *formattedNumber = [ZZPhoneHelper phone:friendModel.mobileNumber withFormat:ZZPhoneFormatTypeE164];
    model.recipients = @[[NSObject an_safeString:formattedNumber]];

    model.message = text;

    ANCodeBlock successBlock = ^{
        if (isNudge)
        {
            [self _handleSentWelcomeHintWithFriendDomainModel:friendModel];
        }
        else
        {
            [self _showConnectedDialogForModel:friendModel];
        }
    };

    ANCodeBlock failureBlock = ^{

        [self _showCantSendSmsErrorForModel:friendModel];
    };

    switch (type)
    {
        case ZZInviteTypeSMS:
            [self.wireframe presentSMSDialogWithModel:model success:successBlock fail:failureBlock];
            break;

        case ZZInviteTypeSharing:
            [self.wireframe presentSharingDialogWithModel:model success:successBlock fail:failureBlock];
            break;

        default:
            failureBlock();
            break;
    }

}

- (void)_showCantSendSmsErrorForModel:(ZZFriendDomainModel *)friendModel
{
    [ZZGridAlertBuilder showCannotSendSmsErrorToUser:[friendModel fullName] completion:^{
        [self _handleSentWelcomeHintWithFriendDomainModel:friendModel];
    }];
}

- (void)_nudgeUser:(ZZFriendDomainModel *)userModel
{
    [ZZGridAlertBuilder showPreNudgeAlertWithFriendFirstName:userModel.firstName completion:^{
        [self _showInvitationFormForModel:userModel isNudge:YES];
    }];
}

- (void)_showNoValidPhonesDialogFromModel:(ZZContactDomainModel *)model
{
    [ZZGridAlertBuilder showNoValidPhonesDialogForUserWithFirstName:model.firstName fullName:model.fullName];
}

- (void)_addingUserToGridDidFailWithError:(NSError *)error forUser:(ZZContactDomainModel *)contact
{
    ZZAlertController *alert;

    if ([error.userInfo objectForKey:@"msg"])
    {
        alert = [ZZAlertController alertControllerWithTitle:@"Error" message:[error.userInfo objectForKey:@"msg"]];

        [alert addAction:[SDCAlertAction actionWithTitle:@"OK" style:SDCAlertActionStyleRecommended handler:^(SDCAlertAction *action) {
            [alert dismissWithCompletion:nil];
        }]];
    }
    else
    {
        alert = [ZZAlertController badConnectionAlert];

        [alert addAction:[SDCAlertAction actionWithTitle:@"Cancel" style:SDCAlertActionStyleRecommended handler:^(SDCAlertAction *action) {
            [alert dismissWithCompletion:nil];
        }]];


        [alert addAction:[SDCAlertAction actionWithTitle:@"Try Again" style:SDCAlertActionStyleDefault handler:^(SDCAlertAction *action) {
            [self.interactor addUserToGrid:contact];
        }]];
    }

    [alert presentWithCompletion:nil];
}

- (void)_showChooseNumberDialogForUser:(ZZContactDomainModel *)user
{
    ANDispatchBlockToMainQueue(^{
        [[ZZTableModal shared] setupViewWithParentView:[UIApplication sharedApplication].windows.firstObject.rootViewController.view
                                                 title:@"Choose phone number"
                                               contact:user
                                              delegate:(id <TBMTableModalDelegate>)self];
        [[ZZTableModal shared] show];
    });
}


@end
