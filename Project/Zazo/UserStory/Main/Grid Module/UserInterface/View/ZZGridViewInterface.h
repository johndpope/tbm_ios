//
//  ZZGridViewInterface.h
//  Zazo
//
//  Created by ANODA on 1/12/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@class ZZGridDataSource;

@protocol ZZGridViewInterface <NSObject>

- (void)udpateWithDataSource:(ZZGridDataSource *)dataSource;
- (id)cellAtIndexPath:(NSIndexPath*)indexPath;

@end