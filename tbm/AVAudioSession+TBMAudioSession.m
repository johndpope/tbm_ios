//
//  AVAudioSession+TBMAudioSession.m
//  Zazo
//
//  Created by Sani Elfishawy on 5/10/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "AVAudioSession+TBMAudioSession.h"
#import "OBLogger.h"
@import UIKit;

@implementation AVAudioSession (TBMAudioSession)

#pragma mark Interface methods

-(void)setupApplicationAudioSession {
    OB_INFO(@"TBMAudioSession: setupApplicationAudioSession");
    [self addObservers];
}


#pragma mark Audio Session Control

-(void)resetAudioSession {
    OB_INFO(@"TBMAudioSession: resetAudioSession");
    dispatch_async(dispatch_get_main_queue(), ^{
        [self removeRouteChangeObserver];
        [self setApplicationCategory];
        [self setPortOverride];
        [self addRouteChangeObserver];
    });
}

- (void)setApplicationCategory{
    NSError *error = nil;
    [self setCategory:AVAudioSessionCategoryPlayAndRecord
          withOptions:AVAudioSessionCategoryOptionAllowBluetooth
                error:&error];
    OB_INFO(@"TBMAudioSession: setApplicationCategory %@", error);
}

-(void)activate{
    NSError *error = nil;
    [self setApplicationCategory];
    [self setPortOverride];
    [self setActive:YES error:&error];
    OB_INFO(@"TBMAudioSession: Activate Audio Session %@", error);
    [self addRouteChangeObserver];
}

-(void)deactivate {
    OB_INFO(@"TBMAudioSession: deactivate Audio Session");
    [self removeRouteChangeObserver];
    [self setActive:NO
        withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation
              error:nil];
}


- (void)setPortOverride {
    if ([self hasNoExternalOutputs]) {
        OB_INFO(@"TBMAudioSession: setPortOverride: no external outputs");
        if ([self nearTheEar]){
            OB_INFO(@"TBMAudioSession: near the ear");
            [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideNone
                                                               error: nil];
        } else {
            OB_INFO(@"TBMAudioSession: far from the ear");
            [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker
                                                               error: nil];
        }
    } else {
        OB_INFO(@"TBMAudioSession: setPortOverride: Yes external outputs");
    }
}


#pragma mark Observers

-(void)addObservers {
    UIDevice *device = [UIDevice currentDevice];
    device.proximityMonitoringEnabled = YES;
    
    [self addRouteChangeObserver];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleProximityChange:)
                                                 name:UIDeviceProximityStateDidChangeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleAudioSessionInteruption)
                                                 name:AVAudioSessionInterruptionNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillResignActive)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
}

- (void)removeObservers{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)removeRouteChangeObserver{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionRouteChangeNotification object:nil];
}

-(void)addRouteChangeObserver{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleRouteChange:)
                                                 name:AVAudioSessionRouteChangeNotification
                                               object:nil];
}

#pragma mark Event Handlers

-(void)handleRouteChange:(NSNotification *)notification{
    OB_INFO(@"TBMAudioSession: handleRouteChange: %@", notification.userInfo[AVAudioSessionRouteChangeReasonKey]);
    AVAudioSessionRouteDescription *previousRoute = (AVAudioSessionRouteDescription *) notification.userInfo[AVAudioSessionRouteChangePreviousRouteKey];
    
    [self printOutputsWithPrefix:@"previousRoute:" Route:previousRoute];
    [self printOutputsWithPrefix:@"currentRoute:" Route:[self currentRoute]];
    
    // GARF: This is a hack. For some reason when changing route from bluetooth back to the built in spearker for
    // example when bluetooth is turned off it will play through earpiece and ignore the override unless I set the category
    // again. resetAudioSession does this.
    if (![self isOutputBuiltInWithRoute:previousRoute] &&
        [self isOutputBuiltInWithRoute:[self currentRoute]]) [self resetAudioSession];
}

-(void)handleProximityChange:(NSNotification *)notification{
    OB_INFO(@"TBMAudioSession: handleProximityChange");
    [self setPortOverride];
}

-(void)appDidBecomeActive{
    [self activate];
}

-(void)appWillResignActive{
    [self deactivate];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 50 * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
    });
}

-(void)handleAudioSessionInteruption{
    OB_INFO(@"TBMAudioSession: AudioSessionInteruption");
}


#pragma mark Route characteristics methods

- (BOOL)isOutputBuiltInWithRoute: (AVAudioSessionRouteDescription *)route{
    BOOL r = NO;
    for ( AVAudioSessionPortDescription *port in route.outputs ) {
        if ([port.portType isEqualToString:AVAudioSessionPortBuiltInSpeaker] ||
            [port.portType isEqualToString:AVAudioSessionPortBuiltInReceiver]){
            r = YES;
        }
    }
    return r;
}

- (void)printOutputsWithPrefix:(NSString *)prefix Route: (AVAudioSessionRouteDescription *)route{
    for ( AVAudioSessionPortDescription *port in route.outputs ) {
        OB_INFO(@"TBMAudioSession: %@ portType: %@", prefix, port.portType);
    }
}

-(BOOL)hasExternalOutputs {
    return [self currentRouteHasBluetoothOutput] || [self currentRouteHasHeadphonesOutput];
}

- (BOOL)hasNoExternalOutputs {
    return ![self hasExternalOutputs];
}


-(BOOL)currentRouteHasBluetoothOutput {
    BOOL hasBluetoothOutput = NO;
    for (AVAudioSessionPortDescription *port in self.currentRoute.outputs) {
        if ([port.portType isEqualToString:AVAudioSessionPortBluetoothHFP] ||
            [port.portType isEqualToString:AVAudioSessionPortBluetoothA2DP])
        {
            hasBluetoothOutput = YES;
        }
    }
    return hasBluetoothOutput;
}

-(BOOL)currentRouteHasHeadphonesOutput {
    BOOL hasHeadphonesOutput = NO;
    for (AVAudioSessionPortDescription *port in self.currentRoute.outputs) {
        if ([port.portType isEqualToString:AVAudioSessionPortHeadphones]) {
            hasHeadphonesOutput = YES;
        }
    }
    return hasHeadphonesOutput;
}



#pragma mark Proximity

- (BOOL)nearTheEar{
    return [UIDevice currentDevice].proximityState;
}



@end
