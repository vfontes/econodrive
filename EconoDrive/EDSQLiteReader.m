//
//  EDSQLiteReader.m
//  EconoDrive
//
//  Created by Vinicius Fontes on 17/10/14.
//  Copyright (c) 2014 Vinicius Fontes. All rights reserved.
//

#import "EDSQLiteReader.h"

@implementation EDSQLiteReader

-(void)clearData {
    if([self.db open]) {
        NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@",EDSQLITE_TABLE_NAME];
        if([self.db executeUpdate:sql]) {
            DLog(@"banco de dados limpo.");
        }
        [self.delegate didGetValueOfAllPIDs:self];
    }
    
}


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
                andGPSDistance:(NSNumber *)gps_distance {
    
    if([self.db open]) {
        NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@ (obd_fuelsys, obd_map, obd_rpm, obd_vss, obd_iat, obd_o2sensor, gps_latitude, gps_longitude, gps_vss, gps_altitude, gps_distance) VALUES ('%@', '%@', '%@', '%@', '%@', '%@', %f, %f, %f, %f, %f)",
                         EDSQLITE_TABLE_NAME,
                         obd_fuelsys,
                         obd_map,
                         obd_rpm,
                         obd_vss,
                         obd_iat,
                         obd_o2sensor,
                         gps_latitude.doubleValue,
                         gps_longitude.doubleValue,
                         gps_vss.doubleValue,
                         gps_altitude.doubleValue,
                         gps_distance.doubleValue];
        
        if(![self.db executeUpdate:sql]) {
            [MBLMessageBanner showMessageBannerInViewController:nil
                                                          title:[NSString stringWithFormat:@"Erro inserindo linha %@",sql]
                                                       subtitle:[self.db lastErrorMessage]
                                                           type:MBLMessageBannerTypeError
                                                       duration:10
                                         userDissmissedCallback:nil
                                                     atPosition:MBLMessageBannerPositionTop
                                           canBeDismissedByUser:YES];
        }
    }
}

-(void)insertRowWithFuelSys:(NSString *)obd_fuelsys
                     andMAP:(NSString *)obd_map
                     andRPM:(NSString *)obd_rpm
                     andVSS:(NSString *)obd_vss
                     andIAT:(NSString *)obd_iat
                andO2Sensor:(NSString *)obd_o2sensor {

    [self insertRowWithFuelSys:obd_fuelsys
                        andMAP:obd_map
                        andRPM:obd_rpm
                        andVSS:obd_vss
                        andIAT:obd_iat
                   andO2Sensor:obd_o2sensor
                andGPSLatitude:nil
               andGPSLongitude:nil
                andGPSAltitude:nil
                     andGPSVSS:nil
                   andGPSDistance:nil];
}

-(void)requestValueOfPID:(EDPID *)pid {
    //Verifica se já existe um objeto do mesmo tipo no array
    [self.checkPIDs addObject:pid];
    if(self.checkPIDs.count > 1) {
        for(int i = 1; i <= self.checkPIDs.count; i++) {
            if([self.checkPIDs[0] isMemberOfClass:pid.class]) {
                //Já foi requisitado o PID para essa linha.
                //Incrementa-se o currentRow e limpa-se o array
                self.offset = [NSNumber numberWithInteger:self.offset.integerValue + 1];
                [self.checkPIDs removeAllObjects];
            }
        }
    }
    //Executa a consulta
    if([self.db open]) {
        //DLog(@"checkPIDs.count: %d",self.checkPIDs.count);
        NSString *sql = [NSString stringWithFormat:@"SELECT %@, gps_distance FROM %@ LIMIT 1 OFFSET %d",
                         pid.name,
                         EDSQLITE_TABLE_NAME,
                         self.offset.intValue];
        FMResultSet *rs = [self.db executeQuery:sql];
        //Se retornou um resultado, instancia um PID da mesma classe
        //e chama o delegate
        if([rs next]) {
            if(self.checkPIDs.count == 1) {
                //AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                //DLog(@"totalDistance: %f",appDelegate.totalDistance.doubleValue);
                appDelegate.totalDistance = @(appDelegate.totalDistance.doubleValue + [rs doubleForColumnIndex:1]);
            }
            EDPID *newPID = [[pid.class alloc]initWithRawData:[rs stringForColumnIndex:0]];
            [self.db close];
            [self.delegate didGetValueOfPID:newPID scanner:self];
            newPID = nil;
        }
        else {
            //Condição de parada
            [self.db close];
            [self.delegate scannerBecameUnavailable:self];
        }
    }
}

-(NSNumber *)progress {
    return @(self.offset.doubleValue/self.totalRows.doubleValue);
}

#pragma mark Init method
-(instancetype)init {
    self = [super init];
    self.checkPIDs = [NSMutableArray new];
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    //Verifica se o arquivo do banco de dados já existe
    if(![[NSBundle mainBundle] pathForResource:EDSQLITE_FILE_NAME ofType:EDSQLITE_FILE_TYPE]) {
        //Caso o arquivo não exista ainda, define sua localização
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        self.dbFile = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",EDSQLITE_FILE_NAME,EDSQLITE_FILE_TYPE]];
    }
    
    //Abre ou cria o banco de dados
    self.db = [[FMDatabase alloc]initWithPath:self.dbFile];
    if([self.db open]) {
        //Banco de dados criado. Verificando se a tabela existe em uma thread separada e retorna.
        dispatch_queue_t concurrentQueue = (dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
        dispatch_async(concurrentQueue, ^{
            [self checkDB];
        });
        self.offset = @(0);
        return self;
    }
    else {
        //Erro ao abrir banco de dados. Retorna nulo.
        [self.db close];
        return nil;
    }
}

-(void)countTotalRows {
    if([self.db open]) {
        NSString *sql;
        FMResultSet *resultSet;
        
        //Verifica se já existe a tabela
        sql =  [NSString stringWithFormat:@"SELECT count(*) FROM %@;",EDSQLITE_TABLE_NAME];
        resultSet = [self.db executeQuery:sql];
        if([resultSet next]) {
            self.totalRows = @([resultSet intForColumnIndex:0]);
        }
    }
}
#pragma mark Auxiliar methods
-(void)checkDB {
    NSString *sql;
    FMResultSet *resultSet;
    
    //Verifica se já existe a tabela
    sql =  [NSString stringWithFormat:@"SELECT count(*) AS tables FROM sqlite_master WHERE type='table' AND name='%@';",EDSQLITE_TABLE_NAME];
    resultSet = [self.db executeQuery:sql];
    [resultSet next];
    if([resultSet intForColumnIndex:0] > 0) {
        //Tabela já existe. Manda mensagem para o delegate.
        [self countTotalRows];
        [self.db close];
        [self.delegate scannerBecameAvailable:self];
    }
    else {
        //Tabela não existe. Cria a tabela.
        //Lê o arquivo createDB.sql
        sql = [NSString stringWithContentsOfFile:[[NSBundle mainBundle]
                                                  pathForResource:EDSQLITE_DB_CREATE_FILE_NAME
                                                  ofType:EDSQLITE_DB_CREATE_FILE_TYPE]
                                        encoding:NSUTF8StringEncoding
                                           error:nil];
        
        //Verifica se a query foi executada corretamente
        if([self.db executeStatements:sql]) {
            //Tudo OK. Manda mensagem para o delegate.
            [self countTotalRows];
            [self.db close];
            [self.delegate scannerBecameAvailable:self];
        }
        else {
            //Erro. Manda mensagem para o delegate.
            [self.db close];
            [self.delegate scannerBecameUnavailable:self];
        }
    }
}

#pragma mark Overrides
-(NSString *)description {
    return [NSString stringWithFormat:@"dbFile: %@\ndelegate: %@",[self.dbFile stringByAbbreviatingWithTildeInPath], self.delegate];
}

@end
