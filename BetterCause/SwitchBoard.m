//
//  SwitchBoard.m
//  BetterCause
//
//  Created by emily butterworth on 4/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

#import "SwitchBoard.h"

@interface SwitchBoard ()

@end

@implementation SwitchBoard
@synthesize txtVoucherCode;
@synthesize txtAmount;
@synthesize VoucherCode;
@synthesize lblValue;
@synthesize VoucherValue;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    txtVoucherCode.delegate = self;
    txtAmount.delegate = self;

}

- (void)viewDidUnload
{
    [self setTxtVoucherCode:nil];
    [self setTxtAmount:nil];
    [self setLblValue:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)btnScan:(id)sender {
    ZBarReaderViewController *reader = [ZBarReaderViewController new];
    reader.readerDelegate = self;
    reader.supportedOrientationsMask = ZBarOrientationMaskAll;
    
    ZBarImageScanner *scanner = reader.scanner;
    // TODO: (optional) additional reader configuration here
    
    // EXAMPLE: disable rarely used I2/5 to improve performance
    [scanner setSymbology: ZBAR_I25
                   config: ZBAR_CFG_ENABLE
                       to: 0];
    
    // present and release the controller
    [self presentModalViewController: reader
                            animated: YES];
}

- (IBAction)btnCheckValue:(id)sender {
    if([txtVoucherCode.text intValue] != 0)
    {
        NSString *urlString = [NSString stringWithFormat: @"http://dev.thebettercause.com/voucher/apivalue?key=mU7R2frUtAwR&code=%@", txtVoucherCode.text];
        NSURL *voucherURL = [NSURL URLWithString:urlString];
        dispatch_async(kBgQueue, ^{
            NSData* data = [NSData dataWithContentsOfURL: 
                            voucherURL];
            [self performSelectorOnMainThread:@selector(valueCheck:) 
                                   withObject:data waitUntilDone:YES];
        });
    }
}

- (IBAction)btnRedeem:(id)sender {
    if([txtVoucherCode.text intValue] != 0 && [txtAmount.text doubleValue] != 0 && [lblValue.text doubleValue] > 0 && ([lblValue.text doubleValue] >= [txtAmount.text doubleValue]))
    {
        NSString *urlString = [NSString stringWithFormat: @"http://dev.thebettercause.com/voucher/apiredeem?key=mU7R2frUtAwR&code=%@&value=%@", txtVoucherCode.text, txtAmount.text];
        NSURL *voucherURL = [NSURL URLWithString:urlString];
        dispatch_async(kBgQueue, ^{
            NSData* data = [NSData dataWithContentsOfURL: 
                            voucherURL];
            [self performSelectorOnMainThread:@selector(redemptionCall:) 
                                withObject:data waitUntilDone:YES];
        });
    }
    else 
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Invalid" message:@"Redemption values invalid" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView { // This method needs to be used. It asks how many columns will be used in the UIPickerView
	return 1; // We only need one column so we will return 1.
}

- (void) imagePickerController: (UIImagePickerController*) reader
 didFinishPickingMediaWithInfo: (NSDictionary*) info
{
    // ADD: get the decode results
    id<NSFastEnumeration> results =
    [info objectForKey: ZBarReaderControllerResults];
    ZBarSymbol *symbol = nil;
    for(symbol in results)
        break;
    
    txtVoucherCode.text = symbol.data;

    // ADD: dismiss the controller (NB dismiss from the *reader*!)
    [reader dismissModalViewControllerAnimated: YES];
}

- (void)valueCheck:(NSData *)responseData {
    //parse out the json data
    NSError* error;
    NSDictionary* jsonCheck = [NSJSONSerialization
                          JSONObjectWithData:responseData
                          options:kNilOptions 
                          error:&error];
    NSNumber *resp = (NSNumber *)[jsonCheck objectForKey:@"response"];
    NSString* val = [jsonCheck objectForKey: @"value"];
    
    if (resp && [resp boolValue] == YES)
    {
        lblValue.text = val;
    }
    else
    {
        lblValue.text = @"Invalid Voucher";
    } 
}

- (void)alertView:(UIAlertView *)actionView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 1:
            if ([lblValue.text doubleValue] != 0)
            {
                txtAmount.text = lblValue.text;
            }
            break;
        default:
            break;
    }
}

- (IBAction)EnterAmount:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Value" message:@"What would you like to redeem" delegate:self cancelButtonTitle:@"Partial" otherButtonTitles:@"Full", nil];
    [alert show];
}

- (void)redemptionCall:(NSData *)responseData {
    //parse out the json data
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                               JSONObjectWithData:responseData
                               options:kNilOptions 
                               error:&error];
    NSNumber *resp = (NSNumber *)[json objectForKey:@"response"];
    NSString *val = [json objectForKey:@"text"];
    
    if (resp && [resp boolValue] == YES)
    {
        lblValue.text = val;
    }
    else
    {
        lblValue.text = @"Redemption Failed";
    } 
}

@end