//
// Created by Maksim Bazarov on 16/06/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMViewedHintView.h"

@implementation TBMViewedHintView
{

}
- (void)configureHint
{
    CGRect highlightFrame = [self.gridModule gridGetFrameForFriend:0 inView:self.superview];
    self.dismissAfterAction = YES;
    self.framesToCutOut = @[
            [UIBezierPath bezierPathWithRect:highlightFrame],
    ];
    self.showGotItButton = YES;
    NSMutableArray *arrows = [NSMutableArray array];
    [arrows addObject:[TBMHintArrow arrowWithText:@"Your Zazo was Viewed!"
                                        curveKind:TBMTutorialArrowCurveKindRight
                                       arrowPoint:CGPointMake(
                                               CGRectGetMaxX(highlightFrame) - 20.f,
                                               CGRectGetMinY(highlightFrame))
                                            angle:-45.f
                                           hidden:NO
                                            frame:self.frame]];

    self.arrows = arrows;
}

@end