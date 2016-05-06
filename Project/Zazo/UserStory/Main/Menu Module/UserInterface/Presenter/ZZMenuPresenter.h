//
//  ZZMenuPresenter.h
//  Zazo
//

#import "ZZMenuInteractorIO.h"
#import "ZZMenuWireframe.h"
#import "ZZMenuViewInterface.h"
#import "ZZMenuModuleDelegate.h"
#import "ZZMenuModuleInterface.h"

@interface ZZMenuPresenter : NSObject <ZZMenuInteractorOutput, ZZMenuModuleInterface>

@property (nonatomic, strong) id <ZZMenuInteractorInput> interactor;
@property (nonatomic, strong) ZZMenuWireframe *wireframe;

@property (nonatomic, weak) UIViewController <ZZMenuViewInterface> *userInterface;
@property (nonatomic, weak) id <ZZMenuModuleDelegate> menuModuleDelegate;

- (void)configurePresenterWithUserInterface:(UIViewController <ZZMenuViewInterface> *)userInterface;

@end
