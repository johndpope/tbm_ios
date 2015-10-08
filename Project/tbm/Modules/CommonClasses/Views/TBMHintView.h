/**
 *
 * Tutorial screen base class
 *
 * Created by Maksim Bazarov on 10/06/15.
 * Copyright (c) 2015 No Plan B. All rights reserved.
 */
#import <Foundation/Foundation.h>
//#import "TBMEventsFlowModulePresenter.h"
//#import "TBMHintArrow.h"
//#import "TBMDialogViewInterface.h"
#import "ZZGridModuleInterface.h"


NSString *const kTBMTutorialFontName;

@interface TBMHintView : UIView //<TBMDialogViewInterface>

@property (nonatomic, strong) UIColor *fillColor;
/**
 * Array of UIBezierPath paths for cut out
 */
@property (nonatomic, strong) NSArray *framesToCutOut;

/**
 * Array of TBMHintArrow
 */
@property (nonatomic, strong) NSArray *arrows;
@property (nonatomic, assign) BOOL showGotItButton;
@property (nonatomic, assign) BOOL dismissAfterAction;

@property (nonatomic, weak) id <ZZGridModuleInterface> gridModule;

@end