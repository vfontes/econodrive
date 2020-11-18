//
//  EDScanner.h
//  EconoDrive
//
//  Created by Vinicius Fontes on 17/10/14.
//  Copyright (c) 2014 Vinicius Fontes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EDPID.h"
//#import "Constants.h"
#import "Macros.h"

@protocol EDScannerDelegate <NSObject>
@required
-(void)didGetValueOfPID:(EDPID *)pid scanner:(id)scanner;
-(void)scannerBecameAvailable:(id)scanner;
-(void)scannerBecameUnavailable:(id)scanner;
@optional
-(void)didGetValueOfAllPIDs:(id)scanner;
-(void)didGetRawData:(NSString *)rawData command:(NSString *)command;
@end

@interface EDScanner : NSObject
@property (nonatomic, weak) id<EDScannerDelegate> delegate;

-(void)requestValueOfPID:(EDPID *)pid;

@end
