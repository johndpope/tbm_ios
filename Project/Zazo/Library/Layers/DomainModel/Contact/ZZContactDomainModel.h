//
//  ZZContactDomainModel.h
//  Zazo
//
//  Created by ANODA on 8/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ANBaseDomainModel.h"
#import "ZZUserInterface.h"

@interface ZZContactDomainModel : ANBaseDomainModel <ZZUserInterface>

@property (nonatomic, copy) NSString* firstName;
@property (nonatomic, copy) NSString* lastName;
@property (nonatomic, strong) NSSet* phones;
@property (nonatomic, strong) UIImage* photoImage; // TODO: hanle photo URL string


@end