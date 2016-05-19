//
//  ZZPlayerVC.m
//  Zazo
//

@import AVKit;
@import AVFoundation;

#import "ZZPlayerVC.h"
#import "ZZPlayer.h"
#import "ZZPlayerBackgroundView.h"
#import "ZZTabbarView.h"

@interface ZZPlayerVC () <PlaybackSegmentIndicatorDelegate>

@property (nonatomic, strong) ZZPlayerBackgroundView *contentView;
@property (nonatomic, strong) UIButton* tapButton;
@property (nonatomic, strong, readonly) UIView *baseView;
@property (nonatomic, strong) UIView *dimView;
@property (nonatomic, strong) PlaybackSegmentIndicator *segmentIndicator;
@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) VideoPlayerFullscreenHelper *fullscreenHelper;

@end

@implementation ZZPlayerVC

@synthesize playerController = _playerController;
@synthesize initialPlayerFrame = _initialPlayerFrame;

- (void)loadView
{
    self.contentView = [ZZPlayerBackgroundView new];
    self.view = self.contentView;
    self.view.userInteractionEnabled = YES;
    
    [self dimView];
    [self _makeSegmentIndicator];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self _makeBaseView];

    self.contentView.presentingView = self.presentingViewController.view;
}

- (UIButton *)tapButton
{
    if (!_tapButton)
    {
        _tapButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [_tapButton addTarget:self.eventHandler
                       action:@selector(didTapVideo)
             forControlEvents:UIControlEventTouchUpInside];
        
        [self.playerController.view addSubview:_tapButton];
        
        [_tapButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.playerController.view);
        }];
    }
    return _tapButton;
}

- (UIView *)dimView
{
    if (!_dimView)
    {
        _dimView = [UIView new];
        
        _dimView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        
        [self.view addSubview:_dimView];
        
        [_dimView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(0, 0, ZZTabbarViewHeight, 0));
        }];
        
        UITapGestureRecognizer *recognizer =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(_didTapToDimView)];
        
        //        _dimTapRecognizer = recognizer;
        
        [_dimView addGestureRecognizer:recognizer];
    }
    
    return _dimView;
}

- (void)_makeSegmentIndicator
{
    if (!_segmentIndicator)
    {
        _segmentIndicator = [PlaybackSegmentIndicator new];
        
        [self.view addSubview:_segmentIndicator];
        
        [_segmentIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.view);
            make.centerY.equalTo(self.dimView.mas_bottom).offset(-1);
            make.height.equalTo(@22);
        }];
        
        _segmentIndicator.segmentCount = 3;
        _segmentIndicator.delegate = self;
    }
}

- (void)_makeBaseView
{
    if (!self.playerController.view)
    {
        return;
    }
    
    if (!self.baseView)
    {
        _baseView = [UIView new];
        _baseView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_baseView];
        
        [self.view bringSubviewToFront:self.playerController.view];
        
        _baseView.layer.cornerRadius = 4;
        _baseView.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.75].CGColor;
        _baseView.layer.borderWidth = 4;
    }
    
    self.baseView.frame = CGRectMake(self.initialPlayerFrame.origin.x - 4,
                                     self.initialPlayerFrame.origin.y - 4,
                                     self.initialPlayerFrame.size.width + 8,
                                     self.initialPlayerFrame.size.height + 8);

}

- (void)viewDidLayoutSubviews
{
    [self.fullscreenHelper updateFrameAndAppearance];
}

- (void)viewDidLoad
{
    self.view.userInteractionEnabled = YES;
    
    self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;

    [super viewDidLoad];
    
}

#pragma mark Properties


- (BOOL)isPlayerOnTop
{
    return self.initialPlayerFrame.origin.y < 50; // it may be ~0.00123
}

- (void)updateTextLabel
{
    [self.textLabel sizeToFit];
    
    CGPoint origin = self.initialPlayerFrame.origin;
    
    if ([self isPlayerOnTop])
    {
        origin.y += self.initialPlayerFrame.size.height + 12; // move label to cell's bottom
    }
    else
    {
        origin.y -= self.textLabel.height + 6; // move label to cell's top
    }
    
    origin.x -= 4; // move little bit left
    
    self.textLabel.origin = origin;
}

- (UILabel *)textLabel
{
    if (!_textLabel)
    {
        UILabel *label = [UILabel new];
        label.textColor = [UIColor whiteColor];
        
        [_dimView addSubview:label];
        
        _textLabel = label;
    }
    
    return _textLabel;
}

#pragma mark Input

- (void)setInitialPlayerFrame:(CGRect)initialPlayerFrame
{    
    _initialPlayerFrame = initialPlayerFrame;

    [self updateTextLabel];

    self.fullscreenHelper.initialFrame = initialPlayerFrame;
}

- (void)updatePlayerText:(NSString *)text
{
    self.textLabel.text = text;
}

- (void)updateVideoCount:(NSInteger)count
{
    self.segmentIndicator.segmentCount = count;
}

- (void)updateCurrentVideoIndex:(NSInteger)index
{
    self.segmentIndicator.currentSegment = index;
}

- (void)updatePlaybackProgress:(CGFloat)progress
{
    self.segmentIndicator.segmentProgress = progress;
}

- (void)setPlayerController:(AVPlayerViewController *)playerController
{
    [_playerController.view removeFromSuperview];
    
    _playerController = playerController;
    
    [self.view addSubview:playerController.view];
    [_playerController.view addSubview:self.tapButton];

    _playerController.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _playerController.view.backgroundColor = [UIColor clearColor];
    _playerController.showsPlaybackControls = NO;
    
    self.fullscreenHelper = [[VideoPlayerFullscreenHelper alloc] initWithView:_playerController.view];

}

- (void)_didTapToDimView
{
    [self.eventHandler didTapBackground];
}

#pragma mark PlaybackSegmentIndicatorDelegate

- (void)didTapOnSegmentWithIndex:(NSInteger)segmentIndex
{
    [self.eventHandler didTapSegmentAtIndex:segmentIndex];
}

@end