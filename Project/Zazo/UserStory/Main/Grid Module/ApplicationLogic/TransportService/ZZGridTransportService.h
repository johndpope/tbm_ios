//
//  ZZGridTransportService.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 9/23/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

@class ZZContactDomainModel;

@interface ZZGridTransportService : NSObject

+ (RACSignal*)inviteUserToApp:(ZZContactDomainModel*)contact;
+ (RACSignal*)checkIsUserHasApp:(ZZContactDomainModel*)contact;


@end
