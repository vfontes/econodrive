//
//  EDFuelEconomy.h
//  EconoDrive
//
//  Created by Vinicius Fontes on 22/10/14.
//  Copyright (c) 2014 Vinicius Fontes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EDScanner.h"
#import "EDPID.h"

@protocol EDFuelEconomyDelegate <NSObject>
@required
-(void)didUpdateFuelEconomy:(NSNumber *)instant average:(NSNumber *)average fuelBurned:(NSNumber *)fuelBurned totalDistance:(NSNumber *)totalDistance scanner:(EDScanner *)scanner;

@optional
-(void)scannerBecameAvailable:(EDScanner *)scanner;
-(void)scannerBecameUnavailable:(EDScanner *)scanner;
-(void)didGetRawData:(NSString *)rawData command:(NSString *)command;
@end

@interface EDFuelEconomy : NSObject <EDScannerDelegate> {
    NSNumber *currentPIDIndex;
    NSNumber *mpg;
    NSNumber *mpgSum;
    //NSNumber *totalDataPoints;
    
}

@property EDScanner *scanner;
@property NSArray *pids;
@property (nonatomic, weak) id<EDFuelEconomyDelegate> delegate;

-(instancetype)initWithScanner:(EDScanner *)scanner;
-(void)requestFuelEconomy;

@end
