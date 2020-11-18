//
//  EDScannerSocket.h
//  EconoDrive
//
//  Created by Vinicius Fontes on 24/10/14.
//  Copyright (c) 2014 Vinicius Fontes. All rights reserved.
//

#import "EDScanner.h"
#import <CocoaAsyncSocket/GCDAsyncSocket.h>
#import <MBLMessageBanner.h>

#import "EDSQLiteReader.h"
#import "EDPIDO2Sensor.h"
#import "EDPIDMAP.h"
#import "EDPIDIAT.h"
#import "EDPIDFuelSystemStatus.h"
#import "EDPIDRPM.h"
#import "EDPIDVSS.h"

//#import "Constants.h"


typedef NS_OPTIONS(NSUInteger, ScannerState) {
    ssDisconnected = 0,
    ssInitializing = 1,
    ssReady = 2
};

typedef NS_OPTIONS(NSUInteger, ScannerTags) {
    tagInit = 100
};


@interface EDScannerSocket : EDScanner <GCDAsyncSocketDelegate>

@property GCDAsyncSocket *socket;
@property ScannerState state;
@property NSData *separator;
@property NSString *host;
@property NSUInteger port;
@property NSMutableArray *pids;
@property NSError *lastError;
@property NSString *lastCommand;
@property NSString *lastResponse;

-(instancetype)initWithHost:(NSString *)host andPort:(NSUInteger)port;
-(void)requestValueOfPID:(EDPID *)pid;


@end
