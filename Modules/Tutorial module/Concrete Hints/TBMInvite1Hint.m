//
// Created by Maksim Bazarov on 15/06/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMInvite1Hint.h"

@implementation TBMInvite1Hint {

}

- (void)configureHint {
    CGRect highlightFrame = [self.gridModule gridGetFrameForFriend:0 inView:self.superview];
    self.dismissAfterAction = YES;
    self.framesToCutOut = @[
            [UIBezierPath bezierPathWithRect:highlightFrame],
    ];
    self.showGotItButton = YES;
    NSMutableArray *arrows = [NSMutableArray array];
    [arrows addObject:[TBMHintArrow arrowWithText:@"Send a Zazo"
                                        curveKind:TBMTutorialArrowCurveKindRight
                                       arrowPoint:CGPointMake(
                                               CGRectGetMinX(highlightFrame),
                                               CGRectGetMidY(highlightFrame))
                                            angle:-40.f
                                           hidden:NO
                                            frame:self.frame]];

    self.arrows = arrows;
}

@end