//
//  ZZAvatarInteractor.m
//  Zazo
//

#import "ZZAvatarInteractor.h"
#import "ZZAvatar.h"
#import "ZZKeychainDataProvider.h"
#import "ZZCommonNetworkTransportService.h"
#import "ZZUserDataProvider.h"

@import AWSS3;

@interface ZZAvatarInteractor ()

@property (nonatomic, assign) BOOL areCredentialsLoaded;

@end

@implementation ZZAvatarInteractor


- (void)checkAvatarStatus
{
    [self.output currentAvatarWasChanged:[self.storageService get]];
    [self updateConfiguration];
    
    if (self.areCredentialsLoaded)
    {
        [self.updateService checkUpdate];
        return;
    }
    
    [[ZZCommonNetworkTransportService loadS3CredentialsOfType:ZZCredentialsTypeAvatar] subscribeNext:^(id x) {
        if ([self updateConfiguration])
        {
            self.areCredentialsLoaded = YES;
            [self.updateService checkUpdate];
        }
    } error:^(NSError *error) {
        [self avatarFetchFailed:error.localizedDescription];
    }];
}

- (BOOL)hasAvatar
{
    return self.storageService.get != nil;
}

- (BOOL)updateConfiguration
{
    ZZS3CredentialsDomainModel *credentialsModel = [ZZKeychainDataProvider loadCredentialsOfType:ZZCredentialsTypeAvatar];
    
    if (!credentialsModel.isValid)
    {
        return NO;
    }
    
    AWSStaticCredentialsProvider *credentials =
    [[AWSStaticCredentialsProvider alloc] initWithAccessKey:credentialsModel.accessKey
                                                  secretKey:credentialsModel.secretKey];
    
    AWSRegionType region = [credentialsModel.region aws_regionTypeValue];
    
    AWSServiceConfiguration *configuration =
    [[AWSServiceConfiguration alloc] initWithRegion:region
                                credentialsProvider:credentials];
    
    [AWSS3 registerS3WithConfiguration:configuration
                                forKey:ZZCredentialsTypeAvatar];
    
    return YES;
}

- (void)uploadAvatar:(UIImage *)image completion:(UploadCompletion)completion;
{
    [[self.networkService legacySet:image] subscribeError:^(NSError *error) {
        completion(error);
    } completed:^{
        completion(nil);
    }];
}

- (void)removeAvatarCompletion:(UploadCompletion)completion
{
    [[self.networkService legacyDelete] subscribeError:^(NSError *error) {
        completion(error);
    } completed:^{
        completion(nil);
    }];
}

// MARK: AvatarUpdateServiceDelegate

- (void)avatarRemoved
{
    [self.storageService remove];
    [self.output currentAvatarWasChanged:nil];
    [self.output avatarFetchDidComplete];
}

- (void)avatarEnabled:(BOOL)enabled
{
    [self.output avatarEnabled:enabled];
}

- (void)avatarUpdatedWith:(NSInteger)timestamp completion:(ANCodeBlock)completion
{
    ANDispatchBlockToBackgroundQueue(^{
        
        AWSS3 *avatarService = [AWSS3 S3ForKey:ZZCredentialsTypeAvatar];
        
        ZZS3CredentialsDomainModel *credentialsModel = [ZZKeychainDataProvider loadCredentialsOfType:ZZCredentialsTypeAvatar];
        ZZUserDomainModel *userModel = [ZZUserDataProvider authenticatedUser];
        
        AWSS3GetObjectRequest *request = [AWSS3GetObjectRequest new];
        request.bucket = credentialsModel.bucket;
        request.key = [NSString stringWithFormat: @"%@_%ld", userModel.mkey, (long)timestamp];
        
        [[avatarService getObject:request] continueWithBlock:^id _Nullable(AWSTask<AWSS3GetObjectOutput *> * _Nonnull task) {
            
            if (task.error != nil)
            {
                [self avatarFetchFailed:task.error.localizedDescription];
                return nil;
            }
            
            CGFloat scale = [UIScreen mainScreen].scale;
            AWSS3GetObjectOutput *output = (AWSS3GetObjectOutput*)task.result;
            UIImage *image = [UIImage imageWithData:output.body scale:scale];
            [self.storageService updateWith:image];
            
            completion();
            
            ANDispatchBlockToMainQueue(^{
                [self.output currentAvatarWasChanged:image];
                [self.output avatarFetchDidComplete];
            });
            
            return nil;
        }];
    });
}

- (void)avatarUpToDate
{
    [self.output avatarFetchDidComplete];
}

- (void)avatarFetchFailed:(NSString * _Nonnull)errorText
{
    [self.output avatarFetchDidFail:errorText];
}

@end