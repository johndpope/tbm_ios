//
//  TBMVideoRecorder.m
//  tbm
//
//  Created by Sani Elfishawy on 4/27/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "TBMVideoRecorder.h"
#import "TBMDeviceHandler.h"
#import "TBMSoundEffect.h"
#import "TBMConfig.h"
#import "OBLogger.h"

@interface TBMVideoRecorder () <AVCaptureFileOutputRecordingDelegate>
@property UIView *previewView;
@property AVCaptureSession *captureSession;
@property AVAudioSession *audioSession;
@property AVCaptureInput *videoInput;
@property AVCaptureInput *audioInput;
@property NSFileManager *fileManager;
@property AVCaptureMovieFileOutput *captureOutput;
@property NSURL *videosDirectoryUrl;
@property NSURL *recordingVideoUrl;
@property NSURL *recordedVideoMpeg4Url;
@property CALayer *recordingOverlay;
@property TBMSoundEffect *dingSoundEffect;
@property NSString *marker;
@end

@implementation TBMVideoRecorder

+ (NSURL *)outgoingVideoUrlWithMarker:(NSString *)marker{
    NSString *filename = [NSString stringWithFormat:@"outgoingVidToFriend%@", marker];
    return [[TBMConfig videosDirectoryUrl] URLByAppendingPathComponent:[filename stringByAppendingPathExtension:@"mov"]];
}

- (instancetype)initWithError:(NSError **)error{
    self = [super init];
    if (self){
        _fileManager = [NSFileManager defaultManager];
        _videosDirectoryUrl = [TBMConfig videosDirectoryUrl];
        _recordingVideoUrl = [_videosDirectoryUrl URLByAppendingPathComponent:[@"new" stringByAppendingPathExtension:@"mov"]];
        _recordedVideoMpeg4Url = [_videosDirectoryUrl URLByAppendingPathComponent:[@"newConverted" stringByAppendingPathExtension:@"mp4"]];
        _dingSoundEffect = [[TBMSoundEffect alloc] initWithSoundNamed:@"single_ding_chimes2.wav"];
        
        [self setupAudioSession];
        
        if (![self setupSessionWithError:&*error]){
            OB_ERROR(@"VideoRecorder: Unable to setup AVCaptureSession");
            return nil;
        }
        DebugLog(@"Set up session: %@", _captureSession);

        if (![self getVideoCaptureInputWithError:&*error]){
            OB_ERROR(@"VideoRecorder: Unable to getVideoCaptureInput");
            return nil;
        }
        [_captureSession addInput:_videoInput];
        DebugLog(@"Added videoInput: %@", _videoInput);

        [TBMDeviceHandler showAllAudioDevices];
        if (![self getAudioCaptureInputWithError:&*error]){
            OB_ERROR(@"VideoRecorder: Unable to getAudioCaptureInput");
            return nil;
        }
        [_captureSession addInput:_audioInput];
        DebugLog(@"Added audioInput: %@", _audioInput);

        _captureOutput = [[AVCaptureMovieFileOutput alloc] init];
        if (![self addCaptureOutputWithError:&*error]){
            OB_ERROR(@"VideoRecorder: Unable to addCaptureOutput");
            return nil;
        }
        DebugLog(@"Added captureOutput: %@", _captureOutput);
        [self addObservers];
    }
    return self;
}


- (AVCaptureSession *)setupSessionWithError:(NSError **)error{
    _captureSession = [[AVCaptureSession alloc] init];
    
    if (![_captureSession canSetSessionPreset:AVCaptureSessionPresetLow]){
        NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:@"Cannot set AVCaptureSessionPresetLow", NSLocalizedFailureReasonErrorKey, nil];
        *error = [NSError errorWithDomain:@"TBM" code:0 userInfo:userInfo];
        return nil;
    }
    _captureSession.sessionPreset = AVCaptureSessionPresetLow;
    return _captureSession;
}

- (AVAudioSession *)setupAudioSession{
    _audioSession = [AVAudioSession sharedInstance];
    
    NSError *error = nil;
    [_audioSession setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionMixWithOthers error:&error];
    if (error)
        DebugLog(@"ERROR: unable to set audiosession to AVAudioSessionCategoryPlayAndRecord ERROR: %@", error);
    
    error = nil;
    [_audioSession setMode:AVAudioSessionModeVideoChat error:&error];
    if (error)
        DebugLog(@"ERROR: unable to set audiosession to AVAudioSessionModeVideoChat ERROR: %@", error);
    
    error = nil;
    if (![_audioSession setActive:YES error:&error])
        DebugLog(@"ERROR: unable to activate audiosession ERROR: %@", error);

    return _audioSession;
}

- (AVCaptureInput *)getVideoCaptureInputWithError:(NSError **)error{
    _videoInput = [TBMDeviceHandler getAvailableFrontVideoInputWithError:&*error];
    return _videoInput;
}

- (AVCaptureInput *)getAudioCaptureInputWithError:(NSError **)error{
    _audioInput = [TBMDeviceHandler getAudioInputWithError:&*error];
    return _audioInput;
}

- (AVCaptureSession *)addCaptureOutputWithError:(NSError **)error{
    if (![_captureSession canAddOutput:_captureOutput]) {
        NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys: @"Could not add captureOutput to capture session.", NSLocalizedFailureReasonErrorKey, nil];
        *error = [NSError errorWithDomain:@"TBM" code:0 userInfo:userInfo];
        return nil;
    }
    [_captureSession addOutput:_captureOutput];
    return _captureSession;
}

//--------------------------
// Set videoRecorderDelegate
//--------------------------
- (void)setVideoRecorderDelegate:(id)delegate{
    self.delegate = delegate;
}

- (void)removeVideoRecorderDelegate{
    self.delegate = nil;
}

//-------------------
// Handle previewView
//-------------------
- (void)setupPreviewView:(UIView *)previewView{
    self.previewView = previewView;
    // Remove all sublayers that might have been added by calling this previously.
    self.previewView.layer.sublayers = nil;
    
    [self connectVideoCaptureToPreview];
    [self setupRecordingOverlay];
}


- (void)connectVideoCaptureToPreview{
    CALayer * videoViewLayer = _previewView.layer;
    AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    previewLayer.frame = _previewView.bounds;
    [videoViewLayer addSublayer:previewLayer];
}

- (void)setupRecordingOverlay{
    _recordingOverlay = [CALayer layer];
    _recordingOverlay.hidden = YES;
    _recordingOverlay.frame = _previewView.bounds;
    _recordingOverlay.cornerRadius = 2;
    _recordingOverlay.backgroundColor = [UIColor clearColor].CGColor;
    _recordingOverlay.borderWidth = 2;
    _recordingOverlay.borderColor = [UIColor redColor].CGColor;
    _recordingOverlay.delegate = self;
    [_previewView.layer addSublayer:_recordingOverlay];
    [_recordingOverlay setNeedsDisplay];
}

// The callback by the recording overlay CALayer due to setNeedsDisplay. Use it to add the dot to recordingOverlay
- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)context {
    CGRect borderRect = CGRectMake(8, 8, 7, 7);
    CGContextSetRGBFillColor(context, 248, 0, 0, 1.0);
    CGContextSetLineWidth(context, 0);
    CGContextFillEllipseInRect (context, borderRect);
    CGContextStrokeEllipseInRect(context, borderRect);
    CGContextFillPath(context);
}

//------------------
// Recording actions
//------------------

- (void)startPreview{
    [_captureSession startRunning];
}

- (void)stopPreview{
    [_captureSession stopRunning];
}

- (void)startRecordingWithMarker:(NSString *)marker{
    [_dingSoundEffect play];
    _marker = marker;
    DebugLog(@"Started recording with marker %@", _marker);
    NSError *error = nil;
    [_fileManager removeItemAtURL:_recordingVideoUrl error:&error];
    
    // Wait so we don't record our own ding.
    [NSThread sleepForTimeInterval:0.2f];
    [_captureOutput startRecordingToOutputFileURL:_recordingVideoUrl recordingDelegate:self];
    [self showRecordingOverlay];
}

- (void)stopRecording{
    [self hideRecordingOverlay];
    [_captureOutput stopRecording];
    [_dingSoundEffect play];
}

- (void)cancelRecording{
    [self hideRecordingOverlay];
    [_dingSoundEffect play];
}

- (void)showRecordingOverlay{
    _recordingOverlay.hidden = NO;
}

- (void)hideRecordingOverlay{
    _recordingOverlay.hidden = YES;
}


//------------------------------------------------
// Recording Finished callback and post processing
//------------------------------------------------
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error{
    DebugLog(@"didFinishRecording.");
    if (error){
		DebugLog(@"%@", error);
        return;
    }
    NSDictionary *fileAttributes = [_fileManager attributesOfItemAtPath:[_recordingVideoUrl path] error:&error];
    DebugLog(@"Recorded file size = %llu", fileAttributes.fileSize);
    
    [self convertOutgoingFileToMpeg4];
}

- (void)convertOutgoingFileToMpeg4{
    NSError *dontCareError = nil;
    [_fileManager removeItemAtURL:_recordedVideoMpeg4Url error:&dontCareError];
    
    AVAsset *asset = [AVAsset assetWithURL:_recordingVideoUrl];
    NSArray *allPresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:asset];
    DebugLog(@"%@", allPresets);
    
    AVAssetExportSession *session = [AVAssetExportSession exportSessionWithAsset:asset presetName:AVAssetExportPresetLowQuality];
    DebugLog(@"Filetypes: %@", session.supportedFileTypes);
    
    session.outputFileType = AVFileTypeMPEG4;
    session.outputURL = _recordedVideoMpeg4Url;
    [session exportAsynchronouslyWithCompletionHandler:^{[self didFinishConvertingToMpeg4];}];
}

- (void)didFinishConvertingToMpeg4{
    NSError *error = nil;
    [self moveRecordingToOutgoingFileWithError:&error];
    if (error){
        DebugLog(@"ERROR2: moveRecordingToOutgoingFileWithError this should never happen. error=%@", error);
        return;
    }
        
    DebugLog(@"calling delegate=%@", _delegate);
    if (self.delegate != nil){
        [self.delegate didFinishVideoRecordingWithMarker:_marker];
    } else {
        OB_ERROR(@"VideoRecorder: no videoRecorderDelegate");
    }
}

- (void)moveRecordingToOutgoingFileWithError:(NSError **)error{
    NSURL *outgoingVideoUrl = [TBMVideoRecorder outgoingVideoUrlWithMarker:_marker];
    
    NSError *dontCareError = nil;
    [_fileManager removeItemAtURL:outgoingVideoUrl error:&dontCareError];
    
    *error = nil;
    [_fileManager moveItemAtURL:_recordedVideoMpeg4Url toURL:outgoingVideoUrl error:&*error];
    if (*error) {
        DebugLog(@"ERROR: moveRecordingToOutgoingFile: ERROR: unable to move file. This should never happen. %@", *error);
        return;
    }
    
    NSDictionary *fileAttributes = [_fileManager attributesOfItemAtPath:outgoingVideoUrl.path error:&dontCareError];
    DebugLog(@"moveRecordingToOutgoingFile: Outgoing file size %llu", fileAttributes.fileSize);
}


//-------------------------------
// AVCaptureSession Notifications
//-------------------------------
- (void)dispose{
    [self removeObservers];
}

- (void)addObservers{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(AVCaptureSessionRuntimeErrorNotification:) name:AVCaptureSessionRuntimeErrorNotification object:_captureSession];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(AVCaptureSessionDidStartRunningNotification:) name:AVCaptureSessionDidStartRunningNotification object:_captureSession];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(AVCaptureSessionDidStopRunningNotification:) name:AVCaptureSessionDidStopRunningNotification object:_captureSession];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(AVCaptureSessionWasInterruptedNotification:) name:AVCaptureSessionWasInterruptedNotification object:_captureSession];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(AVCaptureSessionInterruptionEndedNotification:) name:AVCaptureSessionInterruptionEndedNotification object:_captureSession];
}

- (void)removeObservers{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureSessionRuntimeErrorNotification object:_captureSession];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureSessionDidStartRunningNotification object:_captureSession];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureSessionDidStopRunningNotification object:_captureSession];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureSessionWasInterruptedNotification object:_captureSession];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureSessionInterruptionEndedNotification object:_captureSession];
}

- (void) AVCaptureSessionRuntimeErrorNotification:(NSNotification *)notification{
    OB_ERROR(@"AVCaptureSessionRuntimeErrorNotification");
    NSDictionary *userInfo = [notification userInfo];
    NSError *error = [userInfo objectForKey:AVCaptureSessionErrorKey];
    NSString *message = [NSString stringWithFormat:@"Error: %@", error];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"AVCaptureSessionRuntimeErrorNotification" message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
}
- (void) AVCaptureSessionDidStartRunningNotification:(NSNotification *)notification{
    OB_INFO(@"AVCaptureSessionDidStartRunningNotification");
}
- (void) AVCaptureSessionDidStopRunningNotification:(NSNotification *)notification{
    OB_WARN(@"AVCaptureSessionDidStopRunningNotification");
}
- (void) AVCaptureSessionWasInterruptedNotification:(NSNotification *)notification{
    OB_WARN(@"AVCaptureSessionWasInterruptedNotification");
}
- (void) AVCaptureSessionInterruptionEndedNotification:(NSNotification *)notification{
    OB_WARN(@"AVCaptureSessionInterruptionEndedNotification");
    if (self.delegate != nil){
        [self.delegate previewInterruptionDidEnd];
    } else {
        OB_ERROR(@"VideoRecorder: no videoRecorderDelegate");
    }
}
@end
