//
//  TBMVideoRecorder.h
//  tbm
//
//  Created by Sani Elfishawy on 4/27/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AVFoundation/AVFoundation.h"
#import "TBMPreviewView.h"
#import "AVAudioSession+TBMAudioSession.h"

extern NSString* const TBMVideoRecorderDidFinishRecording;
extern NSString* const TBMVideoRecorderShouldStartRecording;
extern NSString* const TBMVideoRecorderDidCancelRecording;
extern NSString* const TBMVideoRecorderDidFail;

@protocol TBMVideoRecorderDelegate <NSObject>
- (void)videoRecorderDidStartRunning;
- (void)videoRecorderRuntimeErrorWithRetryCount:(int)videoRecorderRetryCount;
@end

@interface TBMVideoRecorder : NSObject <TBMAudioSessionDelegate>
@property (nonatomic) id <TBMVideoRecorderDelegate> delegate;
- (instancetype)initWithPreviewView:(TBMPreviewView *)previewView delegate:(id)delegate;
- (void)startRunning;
- (void)startRecordingWithVideoUrl:(NSURL *)videoUrl;
- (void)stopRecording;
- (BOOL)cancelRecording;
- (void)dispose;
- (BOOL)isRecording;
@end