//
//  EDFuelEconomyIMAP.h
//  EconoDrive
//
//  Created by Vinicius Fontes on 22/10/14.
//  Copyright (c) 2014 Vinicius Fontes. All rights reserved.
//

#import "EDFuelEconomy.h"
#import "EDPIDFuelSystemStatus.h"
#import "EDPIDMAP.h"
#import "EDPIDIAT.h"
#import "EDPIDRPM.h"
#import "EDPIDVSS.h"
#import "EDPIDO2Sensor.h"

#import "EDSQLiteReader.h"
#import "EDScannerSocket.h"
#import <MBLMessageBanner.h>
#import "AppDelegate.h"
#import <CoreLocation/CoreLocation.h>

//#include "Constants.h"


@interface EDFuelEconomyIMAP : EDFuelEconomy <EDScannerDelegate> {
    NSNumber *obdMAP;
    NSNumber *obdIAT;
    NSNumber *obdRPM;
    NSNumber *obdVSS;
    NSNumber *obdFuelSystemStatus;
    NSNumber *obdO2Sensor;
    
    NSNumber *imap;
    NSNumber *maf;
    
    
    NSNumber *poundsPerGallon;
    NSNumber *gramsPerPound;
    NSNumber *stoichRate;
    NSNumber *ev;
    NSNumber *vdm;
    NSNumber *mm;
    NSNumber *r;
    
    EDSQLiteReader *sqliteWriter;
    //CLLocationManager *locationManager;
    //CLLocation *previousLocation;
    //CLLocation *currentLocation;
    
    AppDelegate *appDelegate;
}

@property NSNumber *fuelBurned;
@property NSNumber *average;
@property NSString *plistFile;
@property NSDictionary *tripData;

//@property NSNumber *totalDistance;

-(void)clearTripData;

@end
