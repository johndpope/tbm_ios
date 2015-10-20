//
//  TBMHttpClient.h
//  tbm
//
//  Created by Sani Elfishawy on 5/3/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "AFNetworking.h"

extern NSString * const SERVER_PARAMS_STATUS_KEY;
extern NSString * const SERVER_PARAMS_ERROR_TITLE_KEY;
extern NSString * const SERVER_PARAMS_ERROR_MSG_KEY;

extern NSString * const SERVER_STATUS_VALUE_SUCCESS;
extern NSString * const SERVER_STATUS_VALUE_FAILURE;
extern NSString * const SERVER_STATUS_TRUE_VALUE;

extern NSString * const SERVER_PARAMS_USER_FIRST_NAME_KEY;
extern NSString * const SERVER_PARAMS_USER_LAST_NAME_KEY;
extern NSString * const SERVER_PARAMS_USER_MOBILE_NUMBER_KEY;
extern NSString * const SERVER_PARAMS_USER_ID_KEY;
extern NSString * const SERVER_PARAMS_USER_MKEY_KEY;
extern NSString * const SERVER_PARAMS_USER_AUTH_KEY;
extern NSString * const SERVER_PARAMS_USER_DEVICE_PLATFORM_KEY;
extern NSString * const SERVER_PARAMS_USER_VERIFICATION_CODE_KEY;
extern NSString * const SERVER_PARAMS_USER_VERIFICATION_CODE_VIA_KEY;
extern NSString * const SERVER_PARAMS_USER_VERIFICATION_CODE_VIA_SMS;
extern NSString * const SERVER_PARAMS_USER_VERIFICATION_CODE_VIA_CALL;

extern NSString * const SERVER_PARAMS_FRIEND_FIRST_NAME_KEY;
extern NSString * const SERVER_PARAMS_FRIEND_LAST_NAME_KEY;
extern NSString * const SERVER_PARAMS_FRIEND_MOBILE_NUMBER_KEY;
extern NSString * const SERVER_PARAMS_FRIEND_ID_KEY;
extern NSString * const SERVER_PARAMS_FRIEND_MKEY_KEY;
extern NSString * const SERVER_PARAMS_FRIEND_CKEY_KEY;
extern NSString * const SERVER_PARAMS_FRIEND_HAS_APP_KEY;

extern NSString * const SERVER_PARAMS_S3_REGION_KEY;
extern NSString * const SERVER_PARAMS_S3_BUCKET_KEY;
extern NSString * const SERVER_PARAMS_S3_ACCESS_KEY;
extern NSString * const SERVER_PARAMS_S3_SECRET_KEY;

extern NSString * const SERVER_PARAMS_DISPATCH_MSG_KEY;
extern NSString * const SERVER_PARAMS_DISPATCH_DEVICE_MODEL_KEY;
extern NSString * const SERVER_PARAMS_DISPATCH_OS_VERSION_KEY;
extern NSString * const SERVER_PARAMS_DISPATCH_ZAZO_VERSION_KEY;
extern NSString * const SERVER_PARAMS_DISPATCH_ZAZO_VERSION_NUMBER_KEY;

@interface TBMHttpManager : NSObject

+ (AFHTTPRequestOperationManager *)manager;
+ (AFHTTPRequestOperationManager *)managerWithCredential:(NSURLCredential *)credential;
+ (BOOL)isSuccess:(NSDictionary *)responseObject;
+ (BOOL)isFailure:(NSDictionary *)responseObject;
+ (BOOL) hasAppWithServerValue:(NSString *)value;

@end