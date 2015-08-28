//
//  ZZGridPresenter.h
//  Zazo
//
//  Created by ANODA on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZGridInteractorIO.h"
#import "ZZGridViewInterface.h"
#import "ZZGridModuleDelegate.h"
#import "ZZGridModuleInterface.h"
#import "ZZMenuModuleDelegate.h"
#import "ZZGridWireframe.h"

@class ZZGridWireframe;
@interface ZZGridPresenter : NSObject
<
 ZZGridInteractorOutput,
 ZZGridModuleInterface,
 ZZMenuModuleDelegate
>

@property (nonatomic, strong) id<ZZGridInteractorInput> interactor;
@property (nonatomic, strong) ZZGridWireframe* wireframe;

@property (nonatomic, weak) UIViewController<ZZGridViewInterface>* userInterface;
@property (nonatomic, weak) id<ZZGridModuleDelegate> gridModuleDelegate;

- (void)configurePresenterWithUserInterface:(UIViewController<ZZGridViewInterface>*)userInterface;

@end