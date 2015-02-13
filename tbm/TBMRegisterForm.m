//
//  TBMRegisterForm.m
//  FormUsingCode
//
//  Created by Sani Elfishawy on 11/12/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "TBMRegisterForm.h"
#import "TPKeyboardAvoidingScrollView.h"

@interface TBMRegisterForm()
@property (nonatomic) float screenWidth;
@property (nonatomic) BOOL isWaiting;

@property (nonatomic) UIView *topView;
@property (nonatomic) id delegate;

@property (nonatomic) TPKeyboardAvoidingScrollView *scrollView;
@property (nonatomic) UIView *contentView;
@property (nonatomic) UIImageView *title;
@property (nonatomic) UILabel *plus;
@property (nonatomic) UILabel *countryCodeLbl;
@property (nonatomic) UIButton *submit;
@property (nonatomic) UIButton *debug;
@end

static const float TBMRegisterLogoTopMargin = 106.0;
static const float TBMRegisterFieldsTopMargin = 60.0;
static const float TBMRegisterSubmitTopMargin = 60.0;
static const float TBMRegisterSpinnerTopMargin = 10.0;

static const float TBMRegisterTextFieldHeight = 36.0;
static const float TBMRegisterTextFieldFontSize = 18.0;
static const float TBMRegisterTextFieldLargeWidth = 251.0;


@implementation TBMRegisterForm

- (instancetype)initWithView:(UIView *)view delegate:(id <TBMRegisterFormDelegate>)delegate{
    self = [super init];
    if (self != nil) {
        _topView = view;
        _delegate = delegate;
        _isWaiting = NO;
        _screenWidth = [[UIScreen mainScreen] bounds].size.width;
        [self setupRegisterForm];
    }
    return self;
}

//----------------
// Form control
//----------------
- (void)startWaitingForServer{
    self.isWaiting = YES;
    [self.spinner startAnimating];

}
- (void)stopWaitingForServer{
    self.isWaiting = NO;
    [self.spinner stopAnimating];
}

//------------
// Form events
//------------
- (void)submitClick{
    [self.topView endEditing:YES];
    [self.delegate didClickSubmit];
}

- (void)debugClick{
    DebugLog(@"debugClick");
    [self.topView endEditing:YES];
    [self.delegate didClickDebug];
}

- (BOOL) textFieldShouldReturn:(TBMTextField *) textField {
    BOOL didResign = [textField resignFirstResponder];
    if (!didResign) return NO;
    
    TBMTextField *nextField = [(TBMTextField *)textField nextField];
    if ([textField isKindOfClass:[TBMTextField class]] && nextField != nil){
        [nextField becomeFirstResponder];
    }
    return YES;
}

- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField{
    if (self.isWaiting)
        return NO;
    else
        return YES;
}

//----------------
// Set up the form
//----------------
- (void)setupRegisterForm{
    [self addScrollView];
    [self addContentView];
    [self addTitle];
    [self addFieldsBG];
    [self addFirstName];
    [self addLastName];
    [self addPlus];
    [self addCountryCode];
    [self addCountryCodeLabel];
    [self addMobileNumber];
    [self addSubmit];
    [self addSpinner];
    [self addDebug];
    [self setScrollViewSize];
    [self addNextFields];
    [self.topView setNeedsDisplay];
}

- (void)addScrollView{
    self.scrollView = [[TPKeyboardAvoidingScrollView alloc] initWithFrame:self.topView.frame];
    [self.topView addSubview:self.scrollView];
}

- (void)addContentView{
    self.contentView = [[UIView alloc] initWithFrame:self.topView.frame];
    [self.scrollView addSubview:self.contentView];
}

- (void)addTitle{
    CGRect f;
    f.size.width = 136.0;
    f.size.height = 35.0;
    f.origin.x = (self.topView.frame.size.width - f.size.width) / 2.0;
    f.origin.y = TBMRegisterLogoTopMargin;
    
    self.title = [[UIImageView alloc] initWithFrame:f];
    self.title.image = [UIImage imageNamed:@"logotype"];
    [self.contentView addSubview:self.title];
}

- (void)addFieldsBG {
    CGRect f;
    f.origin.x = (self.topView.frame.size.width - TBMRegisterTextFieldLargeWidth) / 2.0;
    f.origin.y = self.title.frame.origin.y + self.title.frame.size.height + TBMRegisterFieldsTopMargin;
    f.size.width = TBMRegisterTextFieldLargeWidth;
    f.size.height = 118.0;
    
    UIImageView *fieldsBG = [[UIImageView alloc] initWithFrame:f];
    fieldsBG.image = [UIImage imageNamed:@"contact_input"];
    [self.contentView addSubview:fieldsBG];
}

- (void)addFirstName{
    CGRect f;
    f.origin.x = (self.topView.frame.size.width - TBMRegisterTextFieldLargeWidth) / 2.0;
    f.origin.y = self.title.frame.origin.y + self.title.frame.size.height + TBMRegisterFieldsTopMargin;
    f.size.width = TBMRegisterTextFieldLargeWidth;
    f.size.height = TBMRegisterTextFieldHeight;
    
    self.firstName = [[TBMTextField alloc] initWithFrame:f];
    self.firstName.placeholder = @"First Name";
    [self.firstName setKeyboardType:UIKeyboardTypeAlphabet];
    [self setCommonAttributesForTextField:self.firstName];
    [self.contentView addSubview:self.firstName];
}

- (void)addLastName{
    CGRect f;
    f.origin.x = (self.topView.frame.size.width - TBMRegisterTextFieldLargeWidth) / 2.0;
    f.origin.y = self.firstName.frame.origin.y + self.firstName.frame.size.height + 4.0;
    f.size.height = TBMRegisterTextFieldHeight;
    f.size.width = TBMRegisterTextFieldLargeWidth;
    
    self.lastName = [[TBMTextField alloc] initWithFrame:f];
    self.lastName.placeholder = @"Last Name";
    [self.lastName setKeyboardType:UIKeyboardTypeAlphabet];
    [self setCommonAttributesForTextField:self.lastName];
    [self.contentView addSubview:self.lastName];
}

- (void)addPlus{
    CGRect f;
    f.origin.x = self.firstName.frame.origin.x;
    f.origin.y = self.lastName.frame.origin.y + self.lastName.frame.size.height + 4.0;
    f.size.width = 19.0;
    f.size.height = TBMRegisterTextFieldHeight;
    
    self.plus = [[UILabel alloc] initWithFrame:f];
    self.plus.textColor = [UIColor whiteColor];
    [self.plus setText:@"+"];
    self.plus.font = [UIFont systemFontOfSize:TBMRegisterTextFieldFontSize];
    self.plus.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:self.plus];
}

- (void)addCountryCode{
    CGRect f;
    f.origin.x = self.plus.frame.origin.x + self.plus.frame.size.width - 10.0;
    f.origin.y = self.plus.frame.origin.y + 2.0;
    f.size.width = 50.0;
    f.size.height = TBMRegisterTextFieldHeight;
    
    self.countryCode = [[TBMTextField alloc] initWithFrame:f];
    [self.countryCode setKeyboardType:UIKeyboardTypeNumberPad];
    [self setCommonAttributesForTextField:self.countryCode];
    [self.contentView addSubview:self.countryCode];
}

- (void)addCountryCodeLabel{
    CGRect f;
    f.origin.x = self.plus.frame.origin.x - 5.0;
    f.origin.y = self.plus.frame.origin.y + self.plus.frame.size.height + 5.0;
    f.size.width = self.plus.frame.size.width + self.countryCode.frame.size.width;
    f.size.height = 10.0;
    
    UILabel *cclbl = [[UILabel alloc] initWithFrame:f];
    cclbl.font = [UIFont systemFontOfSize:8];
    cclbl.textAlignment = NSTextAlignmentCenter;
    cclbl.textColor = [UIColor whiteColor];
    [cclbl setText:@"Country Code"];
    [self.contentView addSubview:cclbl];
}

- (void)addMobileNumber{
    CGRect f;
    f.origin.x = self.countryCode.frame.origin.x + self.countryCode.frame.size.width + 8.0;
    f.origin.y = self.countryCode.frame.origin.y;
    f.size.width = TBMRegisterTextFieldLargeWidth - self.countryCode.frame.size.width - self.plus.frame.size.width - 2.0;
    f.size.height = TBMRegisterTextFieldHeight;
    
    self.mobileNumber = [[TBMTextField alloc] initWithFrame:f];
    self.mobileNumber.placeholder = @"Phone";
    [self.mobileNumber setKeyboardType:UIKeyboardTypeNumberPad];
    [self setCommonAttributesForTextField:self.mobileNumber];
    [self.contentView addSubview:self.mobileNumber];
}

- (void)setCommonAttributesForTextField:(TBMTextField *)tf{
    tf.delegate = self;
    tf.font =  [UIFont fontWithName:@"Helvetica-Light" size:TBMRegisterTextFieldFontSize];
    tf.autocorrectionType = UITextAutocorrectionTypeNo;
    tf.textColor = [UIColor blackColor];
    tf.backgroundColor = [UIColor clearColor];
    tf.borderStyle = UITextBorderStyleNone;
    
    UIView *spacerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    [tf setLeftViewMode:UITextFieldViewModeAlways];
    [tf setLeftView:spacerView];
}

- (void)addSubmit{
    CGRect f;
    f.size.width = 170.0;
    f.size.height = 55.0;
    f.origin.x = (self.topView.frame.size.width - f.size.width) / 2.0;
    f.origin.y = self.plus.frame.origin.y + self.plus.frame.size.height + TBMRegisterSubmitTopMargin;
    
    self.submit = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.submit setBackgroundImage:[UIImage imageNamed:@"dark-button-bg"] forState:UIControlStateNormal];
    [self.submit addTarget:self action:@selector(submitClick) forControlEvents:UIControlEventTouchUpInside];
    self.submit.frame = f;
    [self setCommonAttributesForButton:self.submit];
    [self.submit setTitle:@"Enter" forState:UIControlStateNormal];
    self.submit.titleLabel.textColor = [UIColor whiteColor];
    [self.contentView addSubview:self.submit];
}

- (void)addSpinner{
    CGRect f;
    f.origin.x = (self.screenWidth/2) - 50;
    f.origin.y = self.submit.frame.origin.y + self.submit.frame.size.height + TBMRegisterSpinnerTopMargin;
    f.size.width = 100;
    f.size.height = TBMRegisterTextFieldHeight;
    
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.spinner.frame = f;
    [self.contentView addSubview:self.spinner];
    [self.spinner stopAnimating];
}

- (void)addDebug{
    CGRect f;
    f.origin.x = self.submit.frame.origin.x;
    f.origin.y = self.spinner.frame.origin.y + self.spinner.frame.size.height + TBMRegisterSpinnerTopMargin;
    f.size.width = self.submit.frame.size.width;
    f.size.height = TBMRegisterTextFieldHeight;
    
    self.debug = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.debug addTarget:self action:@selector(debugClick) forControlEvents:UIControlEventTouchUpInside];
    self.debug.frame = f;
    [self.debug setTitle:@"Debug" forState:UIControlStateNormal];
    [self setCommonAttributesForButton:self.debug];
    [self.contentView addSubview:self.debug];
}

- (void)setScrollViewSize {
    float height = self.debug.frame.origin.y + self.debug.frame.size.height + 10.0;
    self.scrollView.contentSize = CGSizeMake(self.screenWidth, height);
    CGRect f = self.contentView.frame;
    f.size.height = height;
    self.contentView.frame = f;
}


- (void)setCommonAttributesForButton:(UIButton *)b{
    [b.titleLabel setFont:[UIFont systemFontOfSize:22]];
    b.titleLabel.textAlignment = NSTextAlignmentCenter;
}

- (void)addNextFields{
    self.firstName.nextField = self.lastName;
    self.lastName.nextField = self.countryCode;
    self.countryCode.nextField = self.mobileNumber;
    self.mobileNumber.nextField = nil;
}

@end