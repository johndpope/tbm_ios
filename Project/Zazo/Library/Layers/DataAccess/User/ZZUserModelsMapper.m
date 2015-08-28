//
//  ZZUserModelsMapper.m
//  Zazo
//
//  Created by ANODA on 8/10/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZUserModelsMapper.h"
#import "TBMUser.h"
#import "ZZUserDomainModel.h"

@implementation ZZUserModelsMapper

+ (TBMUser*)fillEntity:(TBMUser*)entity fromModel:(ZZUserDomainModel*)model
{
    entity.idTbm = model.idTbm;
    entity.firstName = model.firstName;
    entity.lastName = model.lastName;
    entity.mobileNumber = model.mobileNumber;
    
    entity.auth = model.auth;
    entity.mkey = model.mkey;
    
    entity.isRegistered = @(model.isRegistered);
    
    return entity;
}

+ (ZZUserDomainModel*)fillModel:(ZZUserDomainModel*)model fromEntity:(TBMUser*)entity
{
    @try
    {
        model.idTbm = entity.idTbm;
        model.firstName = entity.firstName;
        model.lastName = entity.lastName;
        model.mobileNumber = entity.mobileNumber;
        
        model.auth = entity.auth;
        model.mkey = entity.mkey;
        
        model.isRegistered = [entity.isRegistered boolValue];
    }
    @catch (NSException *exception)
    {
        ANLogWarning(@"Exception: %@", exception);
    }
    @finally
    {
        return model;
    }
}

@end