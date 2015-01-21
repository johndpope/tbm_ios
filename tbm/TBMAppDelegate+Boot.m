//
//  TBMHomeViewController+Boot.m
//  tbm
//
//  Created by Sani Elfishawy on 5/3/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "TBMAppDelegate+Boot.h"
#import "TBMAppDelegate+PushNotification.h"
#import "TBMAppDelegate+AppSync.h"
#import "TBMS3CredentialsManager.h"
#import "TBMUser.h"
#import "TBMFriend.h"
#import "OBLogger.h"
#import "TBMDispatch.h"

@implementation TBMAppDelegate (Boot)

- (void) boot{
    OB_INFO(@"Boot");
    
    [OBLogger instance].writeToConsole = YES;
    if ([[OBLogger instance] logLines].count > 1000)
        [[OBLogger instance] reset];
    
    [TBMDispatch enable];
    
    if (![TBMUser getUser].isRegistered){
        self.window.rootViewController = [self registerViewController];
    } else {
        self.window.rootViewController = [self homeViewController];
        [self didCompleteRegistration];
    }
}

- (void)didCompleteRegistration{
    OB_INFO(@"didCompleteRegistration");
    [self postRegistrationBoot];
    [self performDidBecomeActiveActions];
    [[self registerViewController] presentViewController:[self homeViewController] animated:YES completion:nil];
}

- (void)postRegistrationBoot{
    [self setupPushNotificationCategory];
    [self registerForPushNotification];
    [TBMS3CredentialsManager refreshFromServer:nil];
}

- (void)performDidBecomeActiveActions{
    if (![TBMUser getUser].isRegistered)
        return;
    
    [TBMVideo printAll];
    [self handleStuckDownloadsWithCompletionHandler:^{
        [self retryPendingFileTransfers];
        [self pollAllFriends];
    }];
}


@end
