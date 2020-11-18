//
//  EDFuelEconomyIMAP.m
//  EconoDrive
//
//  Created by Vinicius Fontes on 22/10/14.
//  Copyright (c) 2014 Vinicius Fontes. All rights reserved.
//

#import "EDFuelEconomyIMAP.h"

@implementation EDFuelEconomyIMAP

-(void)clearTripData {
    [sqliteWriter clearData];
    DLog(@"");
    self.fuelBurned = @(0);
    self.average = @(0);
    appDelegate.totalDistance = @(0);
    obdFuelSystemStatus = nil;
    obdIAT = nil;
    obdMAP = nil;
    obdO2Sensor = nil;
    obdRPM = nil;
    obdVSS = nil;
    [self calculateFuelEconomy];
}

-(void)didGetValueOfAllPIDs:(id)scanner {
    [appDelegate.locationManager startUpdatingLocation];

    EDScannerSocket *s = (EDScannerSocket *)scanner;
    if(s.pids.count == ED_NUMBER_OF_PIDS) {
        NSIndexSet *indexSet;
        
        //Obtém o primeiro objeto do tipo EDPIDFuelSystemStatus
        indexSet = [s.pids indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            if([obj isMemberOfClass:[EDPIDFuelSystemStatus class]]) {
                *stop = YES;
                return YES;
            }
            return NO;
        }];
        EDPIDFuelSystemStatus *obd_fuelsys = [s.pids objectsAtIndexes:indexSet].firstObject;
        
        //Obtém o primeiro objeto do tipo EDPIDO2Sensor
        indexSet = [s.pids indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            if([obj isMemberOfClass:[EDPIDO2Sensor class]]) {
                *stop = YES;
                return YES;
            }
            return NO;
        }];
        EDPIDO2Sensor *obd_o2sensor = [s.pids objectsAtIndexes:indexSet].firstObject;
        
        //Obtém o primeiro objeto do tipo EDPIDMAP
        indexSet = [s.pids indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            if([obj isMemberOfClass:[EDPIDMAP class]]) {
                *stop = YES;
                return YES;
            }
            return NO;
        }];
        EDPIDMAP *obd_map = [s.pids objectsAtIndexes:indexSet].firstObject;
        
        //Obtém o primeiro objeto do tipo EDPIDIAT
        indexSet = [s.pids indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            if([obj isMemberOfClass:[EDPIDIAT class]]) {
                *stop = YES;
                return YES;
            }
            return NO;
        }];
        EDPIDIAT *obd_iat = [s.pids objectsAtIndexes:indexSet].firstObject;
        
        //Obtém o primeiro objeto do tipo EDPIDRPM
        indexSet = [s.pids indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            if([obj isMemberOfClass:[EDPIDRPM class]]) {
                *stop = YES;
                return YES;
            }
            return NO;
        }];
        EDPIDRPM *obd_rpm = [s.pids objectsAtIndexes:indexSet].firstObject;
        
        //Obtém o primeiro objeto do tipo EDPIDVSS
        indexSet = [s.pids indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            if([obj isMemberOfClass:[EDPIDVSS class]]) {
                *stop = YES;
                return YES;
            }
            return NO;
        }];
        EDPIDVSS *obd_vss = [s.pids objectsAtIndexes:indexSet].firstObject;
        
        //Escreve no banco
        [sqliteWriter insertRowWithFuelSys:obd_fuelsys.rawData
                                    andMAP:obd_map.rawData
                                    andRPM:obd_rpm.rawData
                                    andVSS:obd_vss.rawData
                                    andIAT:obd_iat.rawData
                               andO2Sensor:obd_o2sensor.rawData
                            andGPSLatitude:@(appDelegate.currentLocation.coordinate.latitude)
                           andGPSLongitude:@(appDelegate.currentLocation.coordinate.longitude)
                            andGPSAltitude:@(appDelegate.currentLocation.altitude)
                                 andGPSVSS:@(appDelegate.currentLocation.speed * 3.6)
                            andGPSDistance:@(appDelegate.currentDistance.doubleValue)];
    }
    else {
        [MBLMessageBanner showMessageBannerInViewController:nil
                                                      title:@"Erro ao inserir linha no banco de dados"
                                                   subtitle:[NSString stringWithFormat:@"Número de pids incorreto (%lu), deveria ser %d.",(unsigned long)s.pids.count, ED_NUMBER_OF_PIDS]                                                           type:MBLMessageBannerTypeError
                                                   duration:10
                                     userDissmissedCallback:nil
                                                 atPosition:MBLMessageBannerPositionTop
                                       canBeDismissedByUser:YES];
    }
}

-(void)calculateFuelEconomy {
    imap = @(obdRPM.doubleValue * obdMAP.doubleValue / obdIAT.doubleValue);
    maf = @((imap.doubleValue/120.0 * ev.doubleValue * vdm.doubleValue * mm.doubleValue)/r.doubleValue);
    NSNumber *correctedStoichRate = @(0.0);
    
    if(obdFuelSystemStatus.integerValue == 2) {
        correctedStoichRate = @(stoichRate.doubleValue + (stoichRate.doubleValue * obdO2Sensor.doubleValue / 100.0));
    }
    else {
        correctedStoichRate = @(11.5);
    }
    self.fuelBurned = @(self.fuelBurned.doubleValue + ((maf.doubleValue / correctedStoichRate.doubleValue / poundsPerGallon.doubleValue / gramsPerPound.doubleValue) * 3.78541178));
    if(isnan(self.fuelBurned.doubleValue)) {
        self.fuelBurned = @(0);
    }
    mpg = @((correctedStoichRate.doubleValue * poundsPerGallon.doubleValue * gramsPerPound.doubleValue * obdVSS.floatValue * 0.621371)/(3600.0 * maf.doubleValue));
    
    if(!isnan(mpg.floatValue)) {
        //Converte para Km/l
        mpg = @(mpg.doubleValue * @(0.4251).doubleValue);
    }
    
    //Calcula o consumo médio
    if(self.fuelBurned.doubleValue > 0) {
        self.average = @(appDelegate.totalDistance.doubleValue / self.fuelBurned.doubleValue);
    }
    else {
        self.average = @(0.0);
    }
    
    //Salva fuelBurned e totalDistance na plist
    //Verifica se o arquivo do banco de dados já existe
    self.tripData = [[NSDictionary alloc]initWithObjectsAndKeys:
                              @(self.fuelBurned.doubleValue),
                              @"fuelBurned",
                              @(appDelegate.totalDistance.doubleValue),
                              @"totalDistance",
                              @(self.average.doubleValue),
                              @"average",
                              nil];
   [self.tripData writeToFile:self.plistFile atomically:YES];
    
    //Informa o delegate que novos dados estão disponíveis
    [self.delegate didUpdateFuelEconomy:mpg
                                average:self.average
                             fuelBurned:self.fuelBurned
                          totalDistance:appDelegate.totalDistance
                                scanner:self.scanner];
}

-(void)didGetRawData:(NSString *)rawData command:(NSString *)command {
    [self.delegate didGetRawData:rawData command:command];
}

-(void)didGetValueOfPID:(EDPID *)pid scanner:(id)scanner {
    //Verifica o tipo de PID que chegou
    if([pid isMemberOfClass:[EDPIDIAT class]]) {
        obdIAT = pid.value;
    }
    else if([pid isMemberOfClass:[EDPIDMAP class]]) {
        obdMAP = pid.value;
    }
    else if([pid isMemberOfClass:[EDPIDRPM class]]) {
        obdRPM = pid.value;
    }
    else if([pid isMemberOfClass:[EDPIDVSS class]]) {
        obdVSS = pid.value;
    }
    else if([pid isMemberOfClass:[EDPIDFuelSystemStatus class]]) {
        obdFuelSystemStatus = @(pid.value.integerValue);
    }
    else if([pid isMemberOfClass:[EDPIDO2Sensor class]]) {
        obdO2Sensor = @(pid.value.doubleValue);
    }
    
    //Verifica se é o último PID necessário para calcular MPG
    if(currentPIDIndex.intValue == self.pids.count - 1) {
        //Reseta o índice do próximo PID a ser obtido
        currentPIDIndex = @(0);
        //Todos os PIDs necessários obtidos. Realiza o cálculo do consumo.
        [self calculateFuelEconomy];
    }
    else { //Ainda faltam PIDs para realizar o cálculo. Incrementa o índice.
        currentPIDIndex = @(currentPIDIndex.intValue + 1);
    }
    
    //Obtém o próximo PID em uma thread separada
    dispatch_queue_t concurrentQueue = (dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
    dispatch_async(concurrentQueue, ^{
        [self.scanner requestValueOfPID:[self.pids objectAtIndex:currentPIDIndex.intValue]];
    });
}

#pragma mark EDScannerDelegate
-(void)scannerBecameAvailable:(id)scanner {
    if(![scanner respondsToSelector:@selector(progress)]) {
    }
    else {
        [appDelegate.locationManager stopUpdatingLocation];
    }
    
    //Inicia o loop para obter os PIDs
    if(currentPIDIndex.integerValue <= self.pids.count) {
        [self.scanner requestValueOfPID:[self.pids objectAtIndex:currentPIDIndex.intValue]];
    }
    [self.delegate scannerBecameAvailable:scanner];
    
}

-(void)scannerBecameUnavailable:(id)scanner {
    if(![scanner respondsToSelector:@selector(progress)]) {
        [appDelegate.locationManager stopUpdatingLocation];
    }
    
    [self.delegate scannerBecameUnavailable:scanner];
}
#pragma mark init
-(instancetype)initWithScanner:(EDScanner *)scanner {
    self = [self init];
    if(scanner) {
        appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        sqliteWriter = [EDSQLiteReader new];
        self.scanner = scanner;
        self.scanner.delegate = self;
        self.pids = @[[EDPIDFuelSystemStatus new],
                      [EDPIDMAP new],
                      [EDPIDRPM new],
                      [EDPIDVSS new],
                      [EDPIDIAT new],
                      [EDPIDO2Sensor new]];
        
        appDelegate.locationManager = [[CLLocationManager alloc]init];
        appDelegate.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        appDelegate.locationManager.distanceFilter = 20.0;
        //appDelegate.locationManager.distanceFilter = kCLDistanceFilterNone;
        appDelegate.locationManager.activityType = CLActivityTypeAutomotiveNavigation;
        appDelegate.locationManager.delegate = appDelegate;
        //TODO: comentar linha abaixo
        //[appDelegate.locationManager startUpdatingLocation];
        
        if([appDelegate.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [appDelegate.locationManager requestWhenInUseAuthorization];
        }
        
        imap = @(0.0);
        maf = @(0.0);
        
        obdRPM = @(0.0);
        obdMAP = @(0.0);
        obdIAT = @(0.0);
        obdVSS = @(0.0);
        
        self.plistFile = [[NSBundle mainBundle] pathForResource:ED_TRIP_DATA_FILE_NAME ofType:ED_TRIP_DATA_FILE_TYPE];
        if(self.plistFile == nil) {
            //Caso o arquivo não exista ainda, define sua localização
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            self.plistFile = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",ED_TRIP_DATA_FILE_NAME,ED_TRIP_DATA_FILE_TYPE]];
        }
        
        self.tripData = [NSDictionary dictionaryWithContentsOfFile:self.plistFile];
        self.fuelBurned = [[self.tripData objectForKey:@"fuelBurned"]copy];
        self.average = [[self.tripData objectForKey:@"average"]copy];
        appDelegate.totalDistance = [[self.tripData objectForKey:@"totalDistance"]copy];
        
        ev = @([[NSUserDefaults standardUserDefaults] floatForKey:@"ev"] / 100.0);
        vdm = @([[NSUserDefaults standardUserDefaults] floatForKey:@"vdm"] / 10.0);
        stoichRate = @([[NSUserDefaults standardUserDefaults] floatForKey:@"stoichRate"] / 100.0);
        DLog(@"ev: %.2f\t\tvdm:%.2f\t\tstoichRate: %.2f",ev.floatValue, vdm.floatValue, stoichRate.floatValue);
        //Constantes
        poundsPerGallon = @(6.17);
        gramsPerPound = @(453.59237);
        mm = @(28.97);;
        r = @(8.314);;
        
        return self;
    }
    else return nil;
}
@end
