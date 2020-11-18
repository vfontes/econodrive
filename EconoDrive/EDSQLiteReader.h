//
//  EDSQLiteReader.h
//  EconoDrive
//
//  Created by Vinicius Fontes on 17/10/14.
//  Copyright (c) 2014 Vinicius Fontes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EDScanner.h"
#import <FMDB/FMDatabase.h>
#import "EDPIDO2Sensor.h"
#import "EDPIDMAP.h"
#import "EDPIDIAT.h"
#import "EDPIDFuelSystemStatus.h"
#import "EDPIDRPM.h"
#import "EDPIDVSS.h"
#import "AppDelegate.h"
#import <MBLMessageBanner.h>


@interface EDSQLiteReader : EDScanner {
    AppDelegate *appDelegate;
}
@property NSString *dbFile;
@property FMDatabase *db;
@property NSNumber *totalRows;
@property NSNumber *offset;
@property NSMutableArray *checkPIDs;

@property (nonatomic) NSNumber *progress;

-(void)requestValueOfPID:(EDPID *)pid;
-(void)insertRowWithFuelSys:(NSString *)obd_fuelsys
                     andMAP:(NSString *)obd_map
                     andRPM:(NSString *)obd_rpm
                     andVSS:(NSString *)obd_vss
                     andIAT:(NSString *)obd_iat
                andO2Sensor:(NSString *)obd_o2sensor;

-(void)insertRowWithFuelSys:(NSString *)obd_fuelsys
                     andMAP:(NSString *)obd_map
                     andRPM:(NSString *)obd_rpm
                     andVSS:(NSString *)obd_vss
                     andIAT:(NSString *)obd_iat
                andO2Sensor:(NSString *)obd_o2sensor
             andGPSLatitude:(NSNumber *)gps_latitude
            andGPSLongitude:(NSNumber *)gps_longitude
             andGPSAltitude:(NSNumber *)gps_altitude
                  andGPSVSS:(NSNumber *)gps_vss
                andGPSDistance:(NSNumber *)gps_distance;

-(void)clearData;


@end
