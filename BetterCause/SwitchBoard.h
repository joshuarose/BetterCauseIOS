//
//  SwitchBoard.h
//  BetterCause
//
//  Created by emily butterworth on 4/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZBarSDK.h"

@interface SwitchBoard : UIViewController
<ZBarReaderDelegate,UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *txtVoucherCode;
@property (weak, nonatomic) IBOutlet UITextField *txtAmount;
- (IBAction)btnScan:(id)sender;
- (IBAction)btnCheckValue:(id)sender;
- (IBAction)btnRedeem:(id)sender;
@property NSString *VoucherCode;
@property NSDecimalNumber *VoucherValue;
@property (weak, nonatomic) IBOutlet UILabel *lblValue;
- (IBAction)EnterAmount:(id)sender;


@end
