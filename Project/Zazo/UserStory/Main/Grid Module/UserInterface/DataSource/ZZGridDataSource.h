//
//  ZZGridDataSource.h
//  Zazo
//
//  Created by ANODA.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@class ANMemoryStorage, ZZGridDomainModel;

@interface ZZGridDataSource : NSObject

@property (nonatomic, strong) ANMemoryStorage* storage;

- (void)updateModel:(ZZGridDomainModel *)model;

@end