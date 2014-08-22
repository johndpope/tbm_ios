//
//  TBMVersionHandler.m
//  tbm
//
//  Created by Sani Elfishawy on 8/20/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//
#import "TBMVersionHandler.h"
#import "TBMHttpClient.h"
#import "TBMConfig.h"
#import "TBMStringUtils.h"
#import "OBLogger.h"

static const NSString *VH_RESULT_KEY = @"result";
static const NSString *VH_UPDATE_SCHEMA_REQUIRED = @"update_schema_required";
static const NSString *VH_UPDATE_REQUIRED = @"update_required";
static const NSString *VH_UPDATE_OPTIONAL = @"update_optional";
static const NSString *VH_CURRENT = @"current";

@interface TBMVersionHandler()
@property (nonatomic, retain) id<TBMVersionHandlerDelegate> delegate;
@end

@implementation TBMVersionHandler

- (instancetype) initWithDelegate:(id<TBMVersionHandlerDelegate>)delegate{
    self = [super init];
    if (self){
        _delegate = delegate;
    }
    return self;
}

+ (BOOL) updateSchemaRequired:(NSString *)result{
    return [result isEqual:VH_UPDATE_SCHEMA_REQUIRED];
}
+ (BOOL) updateRequired:(NSString *)result{
    return [result isEqual:VH_UPDATE_REQUIRED];
}
+ (BOOL) updateOptional:(NSString *)result{
    return [result isEqual:VH_UPDATE_OPTIONAL];
}
+ (BOOL) current:(NSString *)result{
    return [result isEqual:VH_CURRENT];
}

+ (void) goToStore{
    
}

- (void) checkVersionCompatibility{
    NSURLSessionDataTask *task = [[TBMHttpClient sharedClient]
      GET:@"version/check_compatibility"
      parameters:@{@"device_platform": @"ios", @"version": CONFIG_VERSION_NUMBER}
      success:^(NSURLSessionDataTask *task, NSDictionary *responseObject) {
          OB_INFO(@"checkVersionCompatibility: success: %@", [responseObject objectForKey:@"result"]);
          if (_delegate)
              [_delegate versionCheckCallback:[responseObject objectForKey:VH_RESULT_KEY]];
      }
      failure:^(NSURLSessionDataTask *task, NSError *error) {
          OB_ERROR(@"checkVersionCompatibility: %@", error);
      }];
    [task resume];
}

@end
