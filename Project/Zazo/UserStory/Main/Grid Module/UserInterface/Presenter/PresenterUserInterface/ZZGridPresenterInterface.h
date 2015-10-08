//
//  ZZGridPresenterInterface.h
//  Zazo
//
//  Created by ANODA on 10/7/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

@class ZZGridDataSource;
@class ZZGridActionHandler;

@protocol ZZGridPresenterInterface <NSObject>

- (ZZGridDataSource*)dataSource;
- (ZZGridActionHandler*)actionHandler;

@end
