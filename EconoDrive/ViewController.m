//
//  ViewController.m
//  EconoDrive
//
//  Created by Vinicius Fontes on 17/10/14.
//  Copyright (c) 2014 Vinicius Fontes. All rights reserved.
//

#import "ViewController.h"
#import "EDSQLiteReader.h"

@interface ViewController ()
@end

@implementation ViewController



-(BOOL)prefersStatusBarHidden{
    return NO;
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
    self.firstUpdate = YES;
    self.fuelEconomy = [[EDFuelEconomyIMAP alloc]initWithScanner:[[EDScannerSocket alloc]initWithHost:@"192.168.0.10" andPort:35000]];
    
    /*self.fuelEconomy = [[EDFuelEconomyIMAP alloc]initWithScanner:[EDSQLiteReader new]];
    [(EDFuelEconomyIMAP *)self.fuelEconomy setFuelBurned:@(0)];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.totalDistance = @(0);*/
    
    self.fuelEconomy.delegate = self;
    
    
    NSString *plistFile = [[NSBundle mainBundle] pathForResource:ED_TRIP_DATA_FILE_NAME ofType:ED_TRIP_DATA_FILE_TYPE];
    if(plistFile == nil) {
        //Caso o arquivo não exista ainda, define sua localização
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        plistFile = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",ED_TRIP_DATA_FILE_NAME,ED_TRIP_DATA_FILE_TYPE]];
    }
    if(plistFile) {
        NSDictionary *tripData = [[NSDictionary alloc]initWithContentsOfFile:plistFile];
        [self didUpdateFuelEconomy:nil
                           average:[tripData objectForKey:@"average"]
                        fuelBurned:[tripData objectForKey:@"fuelBurned"]
                     totalDistance:[tripData objectForKey:@"totalDistance"]
                           scanner:nil];
    }
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]
                                               initWithTarget:self.fuelEconomy
                                               action:@selector(clearTripData)];
    longPress.minimumPressDuration = 3;
    longPress.numberOfTouchesRequired = 3;
    longPress.allowableMovement = 100;
    [self.view addGestureRecognizer:longPress];
}


-(void)didUpdateFuelEconomy:(NSNumber *)instant average:(NSNumber *)average fuelBurned:(NSNumber *)fuelBurned totalDistance:(NSNumber *)totalDistance scanner:(EDScanner *)scanner {
    dispatch_async(dispatch_get_main_queue(), ^{

        //Atualiza os labels de fuelBurned e distance
        self.lblfuelBurned.text = [NSString stringWithFormat:@"%.3f L",fuelBurned.doubleValue];
        self.lblDistance.text = [NSString stringWithFormat:@"%.3f Km",totalDistance.doubleValue];
        
        if([scanner respondsToSelector:@selector(progress)]) {
            /*self.lblProgress.text = [NSString stringWithFormat:@"%.0f%%",
                                     [(EDSQLiteReader *)scanner progress].doubleValue * 100.0];*/
            [self.progressBar setProgress:[(EDSQLiteReader *)scanner progress].floatValue animated:YES];
        }
        else {
            if(self.firstUpdate) {
                self.firstUpdate = NO;
                /*[MBLMessageBanner showMessageBannerInViewController:nil
                                                              title:@"Recebendo dados."
                                                           subtitle:nil
                                                              image:nil
                                                               type:MBLMessageBannerTypeMessage
                                                           duration:3
                                             userDissmissedCallback:nil
                                                         atPosition:MBLMessageBannerPositionTop
                                               canBeDismissedByUser:YES];*/
            }
        }
        if(instant.doubleValue > 0.0) {
            self.lblInstant.text = [NSString stringWithFormat:@"%.1f Km/l",instant.doubleValue];
        }
        else {
            self.lblInstant.text = @"--.-";
        }
        if(average.doubleValue >= 0.0) {
            self.lblAverage.text = [NSString stringWithFormat:@"%.1f Km/l",average.doubleValue];
        }
        else {
            self.lblAverage.text = @"--.-";
        }
        
        
    });
}

-(void)scannerBecameUnavailable:(EDScanner *)scanner {
    DLog(@"");
    dispatch_async(dispatch_get_main_queue(), ^{
        //Banco de dados
        
        if([scanner respondsToSelector:@selector(progress)]) {
            /*[UIView animateWithDuration:0.3
                             animations:^{
                                 self.lblProgress.alpha = 0.0;
                                 self.progressBar.alpha = 0.0;
                             }];
          */
            //Instancia o EDScannerSocket
            self.fuelEconomy = [[EDFuelEconomyIMAP alloc]initWithScanner:[[EDScannerSocket alloc]initWithHost:@"192.168.0.10" andPort:35000]];
            self.fuelEconomy.delegate = self;
        }
        else {
            self.firstUpdate = YES;
            NSError *error;
            if([scanner respondsToSelector:@selector(lastError)]) {
                error = [(EDScannerSocket *)scanner lastError];
            }
            else {
                error = [NSError new];
            }
            /*[MBLMessageBanner showMessageBannerInViewController:nil
                                                          title:@"Conexão ao scanner perdida."
                                                       subtitle:error.localizedDescription
                                                          image:nil
                                                           type:MBLMessageBannerTypeError
                                                       duration:2
                                         userDissmissedCallback:nil
                                                     atPosition:MBLMessageBannerPositionTop
                                           canBeDismissedByUser:YES];*/
        }
    });
}
-(void)didGetRawData:(NSString *)rawData command:(NSString *)command {
    /*dispatch_async(dispatch_get_main_queue(), ^{
        self.textView.text = [NSString stringWithFormat:@"%@\n%@\n%@",self.textView.text, command, rawData];
        [self.textView scrollRangeToVisible:NSMakeRange(self.textView.text.length, 0)];
    });*/
}

-(void)scannerBecameAvailable:(EDScanner *)scanner {
    dispatch_async(dispatch_get_main_queue(), ^{
        if([scanner respondsToSelector:@selector(progress)]) {
            //Banco de dados. Não exibir os alertas e esconder a textview.
            //self.progressBar.alpha = 1.0;
            //self.lblProgress.alpha = 1.0;
            //self.textView.alpha = 0.0;
            //self.lblAverage.alpha = 1.0;
        }
        else {
            //Scanner OBD. Exibir alertas e mostrar a textview.
            //self.progressBar.alpha = 0.0;
            //self.lblProgress.alpha = 0.0;
            //self.textView.alpha = 1.0;
            //self.lblAverage.alpha = 0.0;

            [MBLMessageBanner showMessageBannerInViewController:nil
                                                          title:@"Conectado ao scanner."
                                                       subtitle:nil
                                                          image:nil
                                                           type:MBLMessageBannerTypeSuccess
                                                       duration:2
                                         userDissmissedCallback:nil
                                                     atPosition:MBLMessageBannerPositionTop
                                           canBeDismissedByUser:YES];
        }
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
