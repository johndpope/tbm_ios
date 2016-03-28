//
//  ZZTabbarVC.m
//  Zazo
//

#import "ZZTabbarVC.h"
#import "ZZMain.h"
#import "ZZTabbarView.h"
#import <OAStackView.h>

@interface ZZTabbarVC () <ZZTabbarViewDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) OAStackView *stackView;
@property (nonatomic, strong) ZZTabbarView *tabbarView;

@end

@implementation ZZTabbarVC

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)loadView
{
    self.view = [UIView new];
    self.view.backgroundColor = [ZZColorTheme shared].gridBackgroundColor;
    
    CALayer *statusBarBackground = [CALayer layer];
    statusBarBackground.backgroundColor = [ZZColorTheme shared].tintColor.CGColor;
    statusBarBackground.frame = [UIApplication sharedApplication].statusBarFrame;
    [self.view.layer addSublayer:statusBarBackground];
    
    [self scrollView];
}

- (void)viewDidLayoutSubviews
{
    [self _scrollToActivePageIfNeededAnimated:NO];
}

@synthesize activePageIndex = _activePageIndex;

- (void)setActivePageIndex:(NSUInteger)activePageIndex
{
    if (_activePageIndex == activePageIndex)
    {
        return;
    }

    _activePageIndex = activePageIndex;
    self.tabbarView.activeItemIndex = activePageIndex;

    [self _scrollToActivePageIfNeededAnimated:YES];
    
    [self.viewControllers[activePageIndex] viewDidAppear:YES];
}

- (void)_scrollToActivePageIfNeededAnimated:(BOOL)animated
{
    CGPoint offset = CGPointMake(self.scrollView.bounds.size.width * self.activePageIndex, 0);

    if (CGPointEqualToPoint(self.scrollView.contentOffset, offset))
    {
        return;
    }

    ANCodeBlock changes = ^{
        self.scrollView.contentOffset = offset;
    };

    if (!animated)
    {
        changes();
        return;
    }

    [UIView animateWithDuration:.5
                          delay:0
         usingSpringWithDamping:1
          initialSpringVelocity:1
                        options:0
                     animations:changes
                     completion:nil];

}

- (UIScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [UIScrollView new];
        _scrollView.pagingEnabled = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.delegate = self;
        [self.view addSubview:_scrollView];
        [_scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.view);
            make.top.equalTo(self.mas_topLayoutGuideBottom);
            make.bottom.equalTo(self.tabbarView.mas_top);
        }];
    }
    return _scrollView;
}

- (ZZTabbarView *)tabbarView
{
    if (!_tabbarView) {
        _tabbarView = [[ZZTabbarView alloc] init];
        _tabbarView.delegate = self;

        [self.view addSubview:_tabbarView];
        [_tabbarView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.left.right.equalTo(self.view);
        }];
    }
    return _tabbarView;
}


- (OAStackView *)stackView
{
    if (!_stackView)
    {
        NSArray <UIView *> *views = [self.viewControllers.rac_sequence map:^id(id value) {
            return [value view];
        }].array;
        
        _stackView = [[OAStackView alloc] initWithArrangedSubviews:views];

        [self.scrollView addSubview:_stackView];

        [views mas_updateConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(self.scrollView);
        }];

        [_stackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.scrollView);
        }];
    }
    return _stackView;
}

- (void)setViewControllers:(NSArray <UIViewController<ZZTabbarViewItem> *> *)viewControllers
{
    [_viewControllers enumerateObjectsUsingBlock:^(UIViewController *controller, NSUInteger idx, BOOL *stop) {
        [controller willMoveToParentViewController:nil];
    }];

    [self.stackView removeFromSuperview];
    self.stackView = nil;

    [_viewControllers enumerateObjectsUsingBlock:^(UIViewController *controller, NSUInteger idx, BOOL *stop) {
        [controller removeFromParentViewController];
    }];

    _viewControllers = viewControllers;

    [_viewControllers enumerateObjectsUsingBlock:^(UIViewController *controller, NSUInteger idx, BOOL *stop) {
        [controller willMoveToParentViewController:self];
    }];

    [self stackView];

    [_viewControllers enumerateObjectsUsingBlock:^(UIViewController *controller, NSUInteger idx, BOOL *stop) {
        [self addChildViewController:controller];
    }];

    self.tabbarView.items = viewControllers;
}

#pragma mark ZZTabbarViewDelegate

- (void)tabbarView:(ZZTabbarView *)tabbarView didTapOnItemWithIndex:(NSUInteger)index
{
    self.activePageIndex = index;
}

#pragma mark Scrollview Delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.viewControllers[self.activePageIndex] viewWillDisappear:YES];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (decelerate)
    {
        return;
    }

    self.activePageIndex = scrollView.contentOffset.x / scrollView.frame.size.width;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self scrollViewDidEndDragging:scrollView willDecelerate:NO];
}


@end
