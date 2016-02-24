//
//  ZZStartInteractorIO.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 1/12/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZApplicationVersionEnumHelper.h"

@protocol ZZStartInteractorInput <NSObject>

- (void)checkVersionStateAndSession;
- (void)checkVersionStateForUserLoggedInState:(BOOL)loggedIn;

@end


@protocol ZZStartInteractorOutput <NSObject>

- (void)userRequiresAuthentication;

- (void)userVersionStateLoadingDidFailWithError:(NSError*)error;
- (void)needUpdateAndCanSkip:(BOOL)canBeSkipped logged:(BOOL)isLoggedIn;
- (void)applicationIsUpToDateAndUserLogged:(BOOL)isUserLoggedIn;
- (void)presentNetworkTestController;

@end