//
// Created by Maksim Bazarov on 10/06/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMTutorialDataSource.h"
#import "TBMFriend.h"
#import "TBMGridElement.h"

#define NSUD [NSUserDefaults standardUserDefaults]

NSString
        *const kInviteHint1NSUDkey = @"kInviteHint1NSUDkey",
        *const kInviteHint2NSUDkey = @"kInviteHint2NSUDkey",
        *const kPlayHintNSUDkey = @"kPlayHintNSUDkey",
        *const kRecordHintNSUDkey = @"kRecordHintNSUDkey",
        *const kSentHintNSUDkey = @"kSentHintNSUDkey",
        *const kViewedHintNSUDkey = @"kViewedHintNSUDkey",
        *const kMessageWelcomeHintNSUDkey = @"*const kMessageWelcomeHintNSUDkey",
// Events state
        *const kMesagePlayedNSUDkey = @"kMesagePlayedNSUDkey",
        *const kMesageRecordedNSUDkey = @"kMesageRecordedNSUDkey";


@implementation TBMTutorialDataSource {
}

void saveNSUDState(BOOL state, NSString *const key) {
    [NSUD setBool:state forKey:key];
    [NSUD synchronize];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self startSession];
    }
    return self;
}

// Invite Hint 1 | every time
- (BOOL)inviteHint1State {
    return [NSUD boolForKey:kInviteHint1NSUDkey];
}

- (void)setInviteHint1State:(BOOL)state {
    saveNSUDState(state, kInviteHint1NSUDkey);
}

// Invite Hint 2
- (BOOL)inviteSomeoneElseHintState {
    return [NSUD boolForKey:kInviteHint2NSUDkey];
}

- (void)setInviteSomeoneElseHintState:(BOOL)state {
    saveNSUDState(state, kInviteHint2NSUDkey);
}

// PlayHint
- (BOOL)playHintState {
    return [NSUD boolForKey:kPlayHintNSUDkey];
}

- (void)setPlayHintState:(BOOL)state {
    saveNSUDState(state, kPlayHintNSUDkey);
}

// RecordHint
- (BOOL)recordHintState {
    return [NSUD boolForKey:kRecordHintNSUDkey];
}

- (void)setRecordHintState:(BOOL)state {
    saveNSUDState(state, kRecordHintNSUDkey);
}

// SentHint
- (BOOL)sentHintState {
    return [NSUD boolForKey:kSentHintNSUDkey];
}

- (void)setSentHintState:(BOOL)state {
    saveNSUDState(state, kSentHintNSUDkey);
}

// ViewedHint
- (BOOL)viewedHintState {
    return [NSUD boolForKey:kViewedHintNSUDkey];
}

- (void)setViewedHintState:(BOOL)state {
    saveNSUDState(state, kViewedHintNSUDkey);
}

// Viewed at least one mesaage
- (BOOL)messagePlayedState {
    return [NSUD boolForKey:kMesagePlayedNSUDkey];
}

- (void)setMessagePlayedState:(BOOL)state {
    saveNSUDState(state, kMesagePlayedNSUDkey);
}

// Welcome
- (BOOL)welcomeHintState {
    return [NSUD boolForKey:kMessageWelcomeHintNSUDkey];;
}

- (void)setWelcomeHintState:(BOOL)state {
    [NSUD boolForKey:kMessageWelcomeHintNSUDkey];
}

// Recorded at least one mesaage
- (BOOL)messageRecordedState {
    return [NSUD boolForKey:kMesageRecordedNSUDkey];
}

- (void)setMessageRecordedState:(BOOL)state {
    saveNSUDState(state, kMesageRecordedNSUDkey);
}

- (NSUInteger)friendsCount {
    return [TBMFriend count];
}

- (NSUInteger)unviewedCount {
    return [TBMFriend allUnviewedCount];
}

- (void)startSession {
    self.invite1HintShowedThisSession = NO;
    self.inviteSomeoneElseHintShowedThisSession = NO;
    self.playHintShowedThisSession = NO;
    self.recordHintShowedThisSession = NO;
    self.sentHintShowedThisSession = NO;
    self.viewedHintShowedThisSession = NO;
    self.welcomeHintShowedThisSession = NO;
}

- (void)resetHintsState {
    [self setInviteHint1State:NO];
    [self setInviteSomeoneElseHintState:NO];
    [self setPlayHintState:NO];
    [self setRecordHintState:NO];
    [self setSentHintState:NO];
    [self setViewedHintState:NO];
    [self setMessagePlayedState:NO];
    [self setWelcomeHintState:NO];
    [self setMessageRecordedState:NO];
    [self startSession];
}

- (BOOL)hasSentVideos:(NSUInteger)gridIndex {
    return [TBMGridElement hasSentVideos:gridIndex];
}


@end