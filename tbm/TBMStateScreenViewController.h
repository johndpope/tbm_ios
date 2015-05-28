//
// Created by Maksim Bazarov on 22.05.15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TBMSecretScreenPresenter;
@class TBMStateScreenDataSource;

@interface TBMStateScreenViewController : UIViewController

- (void)updateUserInterfaceWithData:(TBMStateScreenDataSource *)data;
@end