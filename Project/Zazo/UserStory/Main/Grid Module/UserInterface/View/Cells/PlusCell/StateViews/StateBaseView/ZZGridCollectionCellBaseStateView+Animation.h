//
//  ZZGridCollectionCellBaseStateView+Animation.h
//  Zazo
//
//  Created by Dmitriy Frolow on 02/09/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZGridCollectionCellBaseStateView.h"

@interface ZZGridCollectionCellBaseStateView (Animation)

- (void)_showUploadAnimation;
- (void)_showDownloadAnimationWithNewVideoCount:(NSInteger)count;
- (void)_showVideoCountLabelWithCount:(NSInteger)count;
- (void)_hideVieoCountLabel;
- (void)_showUploadIconWithoutAnimation;

@end
