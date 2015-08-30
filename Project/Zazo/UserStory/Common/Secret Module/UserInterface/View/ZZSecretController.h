//
//  ZZSecretController.h
//  Zazo
//
//  Created by ANODA on 6/2/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ANTableController.h"

@class ZZSecretDataSource;

@protocol ZZSecretControllerDelegate <NSObject>

- (void)itemSelectedWithModel:(id)model;

@end

@interface ZZSecretController : ANTableController

@property (nonatomic, weak) id<ZZSecretControllerDelegate> delegate;

- (void)updateDataSource:(ZZSecretDataSource*)dataSource;

@end