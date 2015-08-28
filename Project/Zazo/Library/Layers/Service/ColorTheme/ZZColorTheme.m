//
//  ZZColorTheme.m
//  Zazo
//
//  Created by ANODA on 7/29/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZColorTheme.h"

static CGFloat const kNavigationBarIconHeight = 20;

@interface ZZColorTheme ()

@property (nonatomic, strong) UIColor* navBarbackgroundColor;
@property (nonatomic, strong) UIColor* navBarFontColor;

@end

@implementation ZZColorTheme

+ (instancetype)shared
{
    static id _sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [self new];
    });
    return _sharedClient;
}

+ (void)load
{
    [self setupFonts];
}

+ (void)setupFonts
{
    [UIFont an_addFontName:@"HelveticaNeue-Light" forType:ANFontTypeLight];
    [UIFont an_addFontName:@"HelveticaNeue" forType:ANFontTypeRegular];
    [UIFont an_addFontName:@"HelveticaNeue-Medium" forType:ANFontTypeMedium];
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        //TODO: convert in HEX
        self.authBackgroundColor = [UIColor colorWithRed:0.61f green:0.75f blue:0.27f alpha:1.0f];
        self.gridBackgourndColor = [UIColor colorWithRed:0.18 green:0.18 blue:0.16 alpha:1];
        self.gridHeaderBackgroundColor = [UIColor colorWithRed:0.11 green:0.11 blue:0.1 alpha:1];
        self.gridMenuColor = [UIColor colorWithRed:0.18 green:0.18 blue:0.16 alpha:1];
        self.gridMenuTextColor = [UIColor colorWithRed:0.64 green:0.62 blue:0.57 alpha:1];
        
        self.secretScreenHeaderColor = [UIColor colorWithRed:0.97 green:0.97 blue:0.97 alpha:1];
        self.secretScreenAddressBGGrayColor = [UIColor colorWithRed:0.98 green:0.98 blue:0.98 alpha:1];
        self.secretScreenAddressBorderGrayColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
        self.secretScreenBlueColor = [UIColor colorWithRed:0.02 green:0.47 blue:0.98 alpha:1];
        
        self.baseColor = [UIColor an_colorWithHexString:@"ac1e44"];
        
        self.navBarFontColor = [UIColor whiteColor];
        self.textGrayColor = [UIColor an_colorWithHexString:@"7b7b81"];
        self.textLightGrayColor = [UIColor an_colorWithHexString:@"8e8e93"];
        
        self.baseBackgroundColor = [UIColor an_colorWithHexString:@"ebebf1"];
        self.baseFontColor = [UIColor an_colorWithHexString:@"5B5B5B"];
        
        self.baseCellTextColor = [UIColor an_colorWithHexString:@"202020"];
        
        self.menuTextColor = [UIColor an_colorWithHexString:@"A8A295"];
        self.menuBackgroundColor = [UIColor an_colorWithHexString:@"2F2E28"];
        
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        
        [self setupAppearance];
    }
    return self;
}

- (void)setupAppearance
{
    [self _setupNavigationBar];
    [self _setupNavigationButtons];
}

- (void)_setupNavigationBar
{
    [[UINavigationBar appearance] setBackgroundImage:[UIImage an_imageWithColor:[UIColor an_colorWithHexString:@"1B1B19"]]
                                       forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage:[UIImage new]];
    NSDictionary* titleAttributes = @{NSForegroundColorAttributeName : self.navBarFontColor,
                                      NSFontAttributeName            : [UIFont an_regularFontWithSize:17],
                                      NSKernAttributeName            : @(2.0)};
    
    [[UINavigationBar appearance] setTitleTextAttributes:titleAttributes];
}

- (void)_setupNavigationButtons
{
    [self _addNavItemWithName:@"navbar_btn_back" type:ANBarButtonTypeBack];
    [self _addNavItemWithName:@"navbar_btn_close" type:ANBarButtonTypeClose];
    [self _addNavItemWithName:@"navbar_btn_done" type:ANBarButtonTypeDone];
    
    [self _addNavItemWithName:@"navbar_btn_add" type:ANBarButtonTypeAdd];
    [self _addNavItemWithName:@"navbar_btn_edit" type:ANBarButtonTypeEdit];
    [self _addNavItemWithName:@"navbar_btn_more" type:ANBarButtonTypeMore];
}

- (void)_addNavItemWithName:(NSString*)name type:(ANBarButtonType)type
{
    UIImage* icon = [UIImage imageWithPDFNamed:name atHeight:kNavigationBarIconHeight];
    [UIBarButtonItem an_addImage:[icon an_imageByTintingWithColor:[UIColor whiteColor]] forType:type];
}

@end