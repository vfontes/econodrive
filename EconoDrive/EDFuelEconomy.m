//
//  EDFuelEconomy.m
//  EconoDrive
//
//  Created by Vinicius Fontes on 22/10/14.
//  Copyright (c) 2014 Vinicius Fontes. All rights reserved.
//

#import "EDFuelEconomy.h"

@implementation EDFuelEconomy

-(void)requestFuelEconomy { }

#pragma mark Init methods
-(instancetype)init {
    self = [super init];
    currentPIDIndex = @(0);
    mpgSum = @(0);
    mpg = @(0);
    //totalDataPoints = @(0);
    return self;
}

-(instancetype)initWithScanner:(EDScanner *)scanner {
    self = [self init];
    if(scanner) {
        self.scanner = scanner;
        self.scanner.delegate = self;
        return self;
    }
    else return nil;
}

#pragma mark EDScannerDelegate
-(void)scannerBecameAvailable:(id)scanner { }
-(void)scannerBecameUnavailable:(id)scanner { }
-(void)didGetValueOfPID:(EDPID *)pid scanner:(id)scanner { }

@end
