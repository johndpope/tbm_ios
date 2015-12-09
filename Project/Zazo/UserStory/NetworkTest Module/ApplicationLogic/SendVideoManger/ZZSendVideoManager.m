//
//  ZZSendVideoManager.m
//  Zazo
//
//  Created by ANODA on 12/8/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZSendVideoManager.h"

#import "TBMFriend.h"
#import "MagicalRecord.h"
#import "TBMVideoIdUtils.h"
#import "TBMVideoProcessor.h"
#import "ZZFileHelper.h"

static CGFloat const kUploadFileInterval = 3.0f;
static NSString* const kUploadFileName = @"IMG_0762";
static NSString* const kUploadFileType = @"MOV";

@interface ZZSendVideoManager ()

@property (nonatomic, strong) NSTimer* timer;

@end

@implementation ZZSendVideoManager

- (void)start
{
    if (!self.timer)
    {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:kUploadFileInterval
                                                      target:self
                                                    selector:@selector(_sendVideo)
                                                    userInfo:nil repeats:YES];
    }
}

- (void)stop
{
    if ([self.timer isValid])
    {
        [self.timer invalidate];
    }
    self.timer = nil;
}

- (void)_sendVideo
{
    TBMFriend* friend = [[TBMFriend MR_findAll] firstObject];
    if (!ANIsEmpty(friend))
    {
        NSURL* fromUrl = [ZZFileHelper fileURlWithFileName:kUploadFileName withType:kUploadFileType];
        NSURL* toUrl = [TBMVideoIdUtils generateOutgoingVideoUrlWithFriendID:friend.idTbm];
        
        NSError* copyError = nil;
        if([ZZFileHelper copyFileWithUrl:fromUrl toUrl:toUrl error:&copyError])
        {
            [[[TBMVideoProcessor alloc] init] processVideoWithUrl:toUrl];
        }
        else
        {
            NSLog(@"Copy error!!!");
        }
    }
}

@end
