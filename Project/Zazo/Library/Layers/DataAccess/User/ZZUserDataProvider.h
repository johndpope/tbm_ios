//
//  ZZUserDataProvider.h
//  Zazo
//
//  Created by ANODA on 8/10/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@class ZZUserDomainModel;
@class TBMUser;

@interface ZZUserDataProvider : NSObject

+ (TBMUser*)entityFromModel:(ZZUserDomainModel*)model;
+ (ZZUserDomainModel*)modelFromEntity:(TBMUser*)entity;
+ (void)upsertUserWithModel:(ZZUserDomainModel*)model;

@end