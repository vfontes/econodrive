//
//  ViewController.h
//  EconoDrive
//
//  Created by Vinicius Fontes on 17/10/14.
//  Copyright (c) 2014 Vinicius Fontes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EDSQLiteReader.h"
#import "EDScannerSocket.h"
#import "EDPIDRPM.h"
#import "EDPIDMAP.h"
#import "EDPIDIAT.h"
#import "EDPIDVSS.h"
#import "EDPIDFuelSystemStatus.h"
#import "EDPIDO2Sensor.h"
#import "EDFuelEconomyIMAP.h"
#import <MBLMessageBanner.h>



@interface ViewController : UIViewController <EDFuelEconomyDelegate>
@property EDFuelEconomy *fuelEconomy;
@property IBOutlet UILabel *lblAverage;
//@property IBOutlet UILabel *lblProgress;
@property IBOutlet UIProgressView *progressBar;
@property IBOutlet UILabel *lblInstant;
//@property IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UILabel *lblfuelBurned;
@property (weak, nonatomic) IBOutlet UILabel *lblDistance;

@property BOOL firstUpdate;

@end

