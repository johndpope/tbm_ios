//
//  ZZAPIRoutes.h
//  Zazo
//
//  Created by ANODA on 8/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZStoredSettingsManager.h"

#pragma mark - API Routes settings

static const struct {
    __unsafe_unretained NSString *production;
    __unsafe_unretained NSString *staging;
} ZZApiBaseURLsList = {
    .production = @"http://prod.zazoapp.com",
    .staging = @"http://staging.zazoapp.com",
};


//TODO: not a good place for it
static inline NSString* const apiBaseURL()
{
    ZZConfigServerState state = [ZZStoredSettingsManager shared].serverEndpointState;
    NSString* apiURLString;
    switch (state)
    {
        case ZZConfigServerStateDeveloper:
        {
            apiURLString = ZZApiBaseURLsList.staging;
        } break;
        case ZZConfigServerStateCustom:
        {
            apiURLString = [ZZStoredSettingsManager shared].serverURLString;
        } break;
        default:
        {
            apiURLString = ZZApiBaseURLsList.production;
        } break;
    }
    if (ANIsEmpty(apiURLString)) // TODO: check is URL valid
    {
        apiURLString = ZZApiBaseURLsList.production;
    }
    return apiURLString;
}


#pragma mark - Authorization

static NSString* const kApiAuthRegistration = @"reg/reg";
static NSString* const kApiAuthVerifyCode = @"reg/verify_code";
static NSString* const kApiAuthDebugUser = @"reg/debug_get_user"; //TODO: debugUser?


#pragma mark - Push Notifications

static NSString* const kApiSavePushToken = @"notification/set_push_token";


#pragma mark - Videos

static NSString* const kApiDeleteVideo = @"videos/delete";
static NSString* const kApiNotificationVideoReceived = @"notification/send_video_received";
static NSString* const kApiNotificationVideoStatusUpdate = @"notification/send_video_status_update";


#pragma mark - Friends

static NSString* const kApiCheckIsFriendHasApp = @"invitation/has_app";

static NSString* const kApiLoadFriends = @"reg/get_friends";
static NSString* const kApiLoadFriendProfile = @"invitation/invite";
static NSString* const kApiChangeFriendVisibilityStatus = @"connection/set_visibility";

#pragma mark - Remote Logging

static NSString* const kApiLogMessage = @"dispatch/post_dispatch";

static NSString* const kApiCheckApplicationVersion = @"version/check_compatibility";
static NSString* const kApiS3Credentials = @"s3_credentials/info";