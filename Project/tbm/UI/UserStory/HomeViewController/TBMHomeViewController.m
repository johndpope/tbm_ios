//
//  TBMHomeViewController.m
//  tbm
//
//  Created by Sani Elfishawy on 4/24/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//
#import "TBMHomeViewController.h"
#import "TBMHomeViewController+VersionController.h"
#import "TBMHomeViewController+Invite.h"

#import "TBMAppDelegate+AppSync.h"
#import "ANEmailWireframe.h"
#import "HexColors.h"
#import "TBMSecretScreenPresenter.h"
#import "TBMSecretGestureRecognizer.h"
#import "TBMEventsFlowModulePresenter.h"
#import "ZZEditFriendListWireframe.h"
#import "ANMessageDomainModel.h"
#import "DeviceUtil.h"
#import "TBMUser.h"
#import "TBMDependencies.h"

typedef NS_ENUM(NSInteger, ZZEditMenuButtonType)
{
    ZZEditMenuButtonTypeEditFriends = 0,
    ZZEditMenuButtonTypeSendFeedback = 1,
    ZZEditMenuButtonTypeCancel = 2,
};

@interface TBMHomeViewController () <UIActionSheetDelegate>
@property (nonatomic) TBMAppDelegate *appDelegate;
@property (nonatomic) TBMBenchViewController *benchViewController;
@property (nonatomic) UIView *overlayBackgroundView;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIView *logoView;
@property (nonatomic, strong) UIButton *editFriendsButton;
@property(nonatomic, strong) UIView *menuButton;
@property(nonatomic) BOOL isPlaying;
@property (nonatomic, strong) ANEmailWireframe* emailWireframe;
@property (nonatomic, strong) ZZEditFriendListWireframe* editFriendsWireframe;

@property(nonatomic) BOOL isSMSProcessActive;
// Modules
@property(nonatomic, strong) TBMSecretScreenPresenter *secretScreen;
@property(nonatomic, strong) id <TBMEventsFlowModuleInterface> eventsFlowModule;

@property(nonatomic, strong) TBMDependencies *dependencies;
@end

@implementation TBMHomeViewController

#pragma mark Interface

- (void)showBench {
    if (!self.benchViewController.isShowing) {
        [self.benchViewController toggle];
    }
}

#pragma mark - Instantiation
static TBMHomeViewController *hvcInstance;

+ (TBMHomeViewController *)existingInstance {
    return hvcInstance;
}

//TODO:Move to module presenter after refactoring
- (void)setupEvensFlowModule:(id <TBMEventsFlowModuleInterface>)eventsFlowModule {
    self.eventsFlowModule = eventsFlowModule;
}

- (UIView *)headerView {
    if (!_headerView) {
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), kLayoutHeaderheight)];
        _headerView.backgroundColor = [UIColor colorWithHexString:@"1B1B19" alpha:1];

        [_headerView addSubview:self.logoView];
        [_headerView bringSubviewToFront:self.logoView];

        [_headerView addSubview:self.menuButton];
        [_headerView bringSubviewToFront:self.menuButton];
        
        [_headerView addSubview:self.editFriendsButton];
        [_headerView bringSubviewToFront:self.editFriendsButton];

        [self.view addSubview:_headerView];
    }
    return _headerView;
}

- (UIView *)logoView {
    if (!_logoView) {
        UIImage *logoImage = [UIImage imageNamed:@"zazo-type"];
        CGFloat logoAspect = logoImage.size.width / logoImage.size.height;
        CGFloat top = (kLayoutHeaderheight - kLayoutLogoHeight) / 2;
        CGRect frame = CGRectMake(kLayoutGutter, top, logoAspect * kLayoutLogoHeight, kLayoutLogoHeight);
        _logoView = [[UIView alloc] initWithFrame:frame];

        UIImageView *logoImageView = [[UIImageView alloc] initWithImage:logoImage];
        logoImageView.frame = _logoView.bounds;
        [_logoView addSubview:logoImageView];
        _logoView.userInteractionEnabled = YES;
    }
    return _logoView;
}

- (UIView *)menuButton {
    if (!_menuButton) {

        //Prepare menu button
        CGFloat buttonSize = CGRectGetHeight(self.headerView.bounds);
        CGFloat x = CGRectGetMaxX(self.headerView.bounds) - (buttonSize * 3);
        CGFloat y = CGRectGetMinY(self.headerView.bounds);

        CGRect frame = CGRectMake(x, y, buttonSize * 2, buttonSize);
        _menuButton = [[UIView alloc] initWithFrame:frame];

        //Prepare image
        UIImage *image = [UIImage imageNamed:@"icon-drawer"];
        UIImageView *icon = [[UIImageView alloc] initWithImage:image];

        CGFloat imageAspectRatio = image.size.width / image.size.height;
        CGFloat iconSize = imageAspectRatio * kLayoutBenchIconHeight;
        CGFloat iconX = CGRectGetMaxX(_menuButton.bounds) - (iconSize) - kLayoutGutter;
        CGFloat iconY = (CGRectGetHeight(_menuButton.bounds) / 2) - (kLayoutBenchIconHeight / 2);
        CGRect iconFrame = CGRectMake(iconX, iconY, iconSize, kLayoutBenchIconHeight);
        icon.frame = iconFrame;
        [_menuButton addSubview:icon];

        _menuButton.userInteractionEnabled = YES;
        [_menuButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(menuButtonTaped:)]];
    }
    return _menuButton;
}

- (UIButton *)editFriendsButton
{
    if (!_editFriendsButton)
    {
        _editFriendsButton = [UIButton new];
        [_editFriendsButton setImage:[UIImage imageNamed:@"icon_menu_dots"] forState:UIControlStateNormal];
        [_editFriendsButton addTarget:self action:@selector(editFriendButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.headerView addSubview:_editFriendsButton];
        
        [_editFriendsButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.right.equalTo(self.headerView);
            make.width.equalTo(@55);
        }];
    }
    
    return _editFriendsButton;
}

#pragma mark - Lifecycle

- (void)viewDidLoad {
    OB_INFO(@"TBMHomeViewController: viewDidLoad");

    [self.dependencies setupDependenciesWithHomeViewController:self];
    [super viewDidLoad];
    self.isSMSProcessActive = NO;

    [self registerToNotifications];
    hvcInstance = self;
    [self addHomeViews];
    [self setupSecretGestureRecognizer];
    [[[TBMVersionHandler alloc] initWithDelegate:self] checkVersionCompatibility];
}

- (void)registerToNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)applicationDidEnterBackground {
    [self.benchViewController hide];
    if (!self.isSMSProcessActive) {
        [self.eventsFlowModule throwEvent:TBMEventFlowEventApplicationDidEnterBackground];
        [self.eventsFlowModule resetSession];
    }
}

- (void)applicationDidEnterForeground {
    if (!self.isSMSProcessActive) {
        [self.eventsFlowModule throwEvent:TBMEventFlowEventApplicationDidLaunch];
    }

    self.isSMSProcessActive = NO;

}

- (void)viewWillAppear:(BOOL)animated {
    OB_INFO(@"TBMHomeViewController: viewWillAppear");
    [super viewWillAppear:animated];

}

- (void)viewDidAppear:(BOOL)animated {
    OB_INFO(@"TBMHomeViewController: viewDidAppear");
    [super viewDidAppear:animated];
    [self performSelectorInBackground:@selector(prefetchContactsManager) withObject:NULL];
}

#pragma mark - Secret screen

- (void)setupSecretGestureRecognizer {
    TBMSecretGestureRecognizer *secretGestureRecognizer;
    secretGestureRecognizer = [[TBMSecretGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(secretGestureAction:)];
    secretGestureRecognizer.container = self.headerView;
    secretGestureRecognizer.logoView = self.logoView;
    secretGestureRecognizer.menuView = self.menuButton;
    [self.view addGestureRecognizer:secretGestureRecognizer];
}

- (void)secretGestureAction:(id)sender {
    TBMSecretGestureRecognizer *recognizer = sender;
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        OB_INFO(@"TBMHomeViewController#showSecretScreen");
        [self.secretScreen presentSecretScreenFromController:self];
    }
}


- (void)prefetchContactsManager {
//    [[TBMContactsManager sharedInstance] prefetchOnlyIfHasAccess];
}


- (void)didReceiveMemoryWarning {
    OB_ERROR(@"TBMHomeViewController: didReceiveMemoryWarning");
    [super didReceiveMemoryWarning];
}

#pragma mark - SetupViews

static const float kLayoutHeaderheight = 55;
static const float kLayoutLogoHeight = kLayoutHeaderheight * 0.4;
static const float kLayoutGutter = 10;
static const float kLayoutBenchIconHeight = kLayoutHeaderheight * 0.4;

- (void)addHomeViews {
    [self headerView];
    [self addContentView];
    [self addGridViewController];
    [self addOverlayBackgroundView];
    [self addBenchViewController];
}

- (void)menuButtonTaped:(id)sender {
    [self.benchViewController toggle];
}

- (void)editFriendButtonTapped:(UIButton *)sender
{
    NSString *editFriendsButtonTitle = NSLocalizedString(@"grid-controller.menu.edit-friends.button.title", nil);
    NSString *sendFeedbackButtonTitle = NSLocalizedString(@"grid-controller.menu.send-feedback.button.title", nil);
    [[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:editFriendsButtonTitle, sendFeedbackButtonTitle, nil] showInView:self.view];
}

#pragma mark - ContentView

- (void)addContentView {
    UIView *cv = [[UIView alloc] initWithFrame:CGRectMake(0, kLayoutHeaderheight, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - kLayoutHeaderheight)];
    cv.backgroundColor = [UIColor colorWithHexString:@"2E2D28" alpha:1];
    [self.view addSubview:cv];
    self.contentView = cv;
}

- (void)addGridViewController {
    self.gridViewController = [[TBMGridViewController alloc] init];
    self.gridViewController.frame = self.contentView.bounds;
    self.gridViewController.homeView = self.view;
    self.gridViewController.delegate = self;
    [self addChildViewController:self.gridViewController];
    [self.contentView addSubview:self.gridViewController.view];
    [self.eventsFlowModule setupGridModule:self.gridViewController];
}

- (void)addBenchViewController {
    self.benchViewController = [[TBMBenchViewController alloc] initWithContainerView:self.contentView
                                                                  gridViewController:self.gridViewController];
    self.benchViewController.delegate = self;
    [self addChildViewController:self.benchViewController];
    [self.contentView addSubview:self.benchViewController.view];
}

- (void)addOverlayBackgroundView {
    self.overlayBackgroundView = [[UIView alloc] initWithFrame:self.view.frame];
    self.overlayBackgroundView.backgroundColor = [UIColor colorWithRed:0.16f green:0.16f blue:0.16f alpha:0.8f];
    [self.contentView addSubview:self.overlayBackgroundView];
    self.overlayBackgroundView.alpha = 0;
    self.overlayBackgroundView.hidden = YES;
}

#pragma mark - TBMBenchViewControllerDelegate

- (void)TBMBenchViewController:(TBMBenchViewController *)vc toggledHidden:(BOOL)isHidden {
    if (isHidden) {
        [UIView animateWithDuration:0.33f animations:^{
            self.overlayBackgroundView.alpha = 0;
        }                completion:^(BOOL finished) {
            self.overlayBackgroundView.hidden = YES;
        }];
    } else {
        self.overlayBackgroundView.hidden = NO;
        [UIView animateWithDuration:0.33f animations:^{
            self.overlayBackgroundView.alpha = 0.8;
        }];
    }
}

#pragma mark - TBMGridDelegate

- (void)gridDidAppear:(TBMGridViewController *)gridViewController {
    if (!self.isSMSProcessActive) {
        [self.eventsFlowModule throwEvent:TBMEventFlowEventApplicationDidLaunch];

    }
}

- (void)videoPlayerDidStartPlaying:(TBMVideoPlayer *)player {
    self.isPlaying = YES;
    [self.eventsFlowModule throwEvent:TBMEventFlowEventMessageDidStartPlaying];
}

- (void)videoPlayerDidStopPlaying:(TBMVideoPlayer *)player {
    if (self.isPlaying) {
        self.isPlaying = NO;
        [self.eventsFlowModule throwEvent:TBMEventFlowEventMessageDidStopPlaying];
    }
}

- (void)messageDidUpload {
    [self.eventsFlowModule throwEvent:TBMEventFlowEventMessageDidSend];
}

- (void)messageDidViewed {
    [self.eventsFlowModule throwEvent:TBMEventFlowEventMessageDidViewed];
}

- (void)friendDidAdd {
    [self.eventsFlowModule throwEvent:TBMEventFlowEventFriendDidAdd];
}

- (void)friendDidAddWithoutApp
{
    [self.eventsFlowModule throwEvent:TBMEventFlowEventFriendDidAddWithoutApp];
}

- (void)messageDidReceive {
    [self.eventsFlowModule throwEvent:TBMEventFlowEventMessageDidReceive];
}


- (void)applicationWillSwitchToSMS {
    self.isSMSProcessActive = YES;
}

#pragma mark - DEPENDENCIES PART
//TODO: move to dependencies class


- (TBMSecretScreenPresenter *)secretScreen {
    if (!_secretScreen) {
        _secretScreen = [[TBMSecretScreenPresenter alloc] init];
        [_secretScreen assignTutorialModule:self.eventsFlowModule];
    }
    return _secretScreen;
}

- (TBMDependencies *)dependencies
{
    if (!_dependencies)
    {
        _dependencies = [TBMDependencies new];
    }
    return _dependencies;
}


#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
            
        case ZZEditMenuButtonTypeEditFriends:
        {
            self.editFriendsWireframe = [ZZEditFriendListWireframe new];
            self.benchViewController.view.hidden = YES;
            [self.editFriendsWireframe presentEditFriendListControllerFromViewController:self withCompletion:^{
                self.benchViewController.view.hidden = NO;
            }];
            
        } break;
            
        case ZZEditMenuButtonTypeSendFeedback:
        {
            ANMessageDomainModel *model = [ANMessageDomainModel new];
            model.title = emailSubject;
            model.recipients = @[emailAddress];
            model.isHTMLMessage = YES;
            model.message = [NSString stringWithFormat:@"<font color = \"000000\"></br></br></br>---------------------------------</br>iOS: %@</br>Model: %@</br>User mKey: %@</br>App Version: %@</br>Build Version: %@ </font>", [[UIDevice currentDevice] systemVersion], [DeviceUtil hardwareDescription], [TBMUser getUser].mkey, [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"], [NSBundle mainBundle].infoDictionary[(NSString*)kCFBundleVersionKey]];
            
            self.emailWireframe = [ANEmailWireframe new];
            [self.emailWireframe presentEmailControllerFromViewController:self withModel:model completion:nil];
            
        } break;
            
        case ZZEditMenuButtonTypeCancel:
        {
            
        } break;
            
        default:
            break;
    }
}



@end