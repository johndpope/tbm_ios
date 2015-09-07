//
//  ZZGridView.m
//  Zazo
//
//  Created by ANODA on 11/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZGridView.h"
#import "ZZGridUIConstants.h"

@interface ZZGridView () <UIGestureRecognizerDelegate>

@property (nonatomic, weak) id <ZZGridViewDelegate> delegate;

@end

@implementation ZZGridView

- (instancetype)init
{
    if (self = [super init])
    {
        [self headerView];
        [self collectionView];
        [self configureRecognizers];
        
        self.isRotationEnabled = YES;
    }
    
    return self;
}


#pragma mark - Header  View

- (ZZGridViewHeader *)headerView
{
    if (!_headerView)
    {
        _headerView = [ZZGridViewHeader new];
        _headerView.backgroundColor = [ZZColorTheme shared].gridHeaderBackgroundColor;
        [self addSubview:_headerView];
        
        [_headerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(self);
            make.height.equalTo(@(kGridHeaderViewHeight)).priorityHigh();
        }];
    }
    return _headerView;
}

- (UICollectionView *)collectionView
{
    if (!_collectionView)
    {
        UICollectionViewFlowLayout* collectionLayout = [UICollectionViewFlowLayout new];
        collectionLayout.sectionInset = kGridSectionInsets;
        collectionLayout.itemSize = kGridItemSize();
        collectionLayout.minimumInteritemSpacing = kGridItemSpacing();
        collectionLayout.minimumLineSpacing = kGridItemSpacing();
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:collectionLayout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.scrollEnabled = NO;
        [self addSubview:_collectionView];
        
        [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.headerView.mas_bottom);
            make.left.right.equalTo(self);
            make.height.equalTo(@(kGridHeight()));
        }];
    }
    return _collectionView;
}

- (void)updateWithDelegate:(id<ZZGridViewDelegate>)delegate
{
    if (delegate)
    {
        self.delegate = delegate;
        [self configureRecognizers];
    }
}

- (void)configureRecognizers
{
    self.rotationRecognizer = [[ZZRotationGestureRecognizer alloc] initWithTarget:self.delegate
                                                                         action:@selector(handleRotationGesture:)];
  
    self.rotationRecognizer.delegate = self.delegate;
    [self addGestureRecognizer:self.rotationRecognizer];
}

@end
