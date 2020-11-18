//
//  EDScannerSocket.m
//  EconoDrive
//
//  Created by Vinicius Fontes on 24/10/14.
//  Copyright (c) 2014 Vinicius Fontes. All rights reserved.
//

#import "EDScannerSocket.h"

@implementation EDScannerSocket {
    NSArray *initCommands;
    NSNumber *initCommandIndex;
}

-(instancetype)initWithHost:(NSString *)host andPort:(NSUInteger)port {
    self = [super init];
    
    //Define o estado atual
    self.state = ssDisconnected;
    
    //Define o separador '>'
    self.separator = [NSData dataWithBytes:(unsigned char[]){0x3e} length:1];
    
    //Define propriedades
    self.host = host;
    self.port = port;
    self.pids = [NSMutableArray new];
    self.lastError = [NSError new];
    self.lastCommand = @"";
    self.lastResponse = @"";
    
    //Inicializa o socket e tenta efetuar a conexão
    self.socket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    DLog(@"Tentando conectar em %@:%lu...",self.host, (unsigned long)self.port);
    [self.socket connectToHost:self.host onPort:self.port withTimeout:10 error:nil];
    return self;
}

-(void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    DLog(@"");
    
    //Define o estado atual
    self.state = ssInitializing;
    
    //Define comandos de inicialização do ELM327
    initCommands = @[@"ATWS\r",        //Warm start
                     @"ATE0\r",       //Echo off
                     @"ATL1\r",         //Linefeeds off
                     @"ATH0\r",         //Headers off
                       @"ATS0\r"];         //Spaces off];
                     //@"0100\r"];
    initCommandIndex = @(0);
    
    //Na inicialização deve ser enviado o comando 0100 para obter os PIDs disponíveis.
    //Pode ocorrer UNABLE TO CONNECT, nesse caso deve-se aguardar 10s e tentar novamente.
    
    //Escreve o primeiro comando e lê até o separador
    self.lastCommand = initCommands[initCommandIndex.intValue];
    [self.socket writeData:[initCommands[initCommandIndex.intValue] dataUsingEncoding:NSASCIIStringEncoding] withTimeout:15 tag:initCommandIndex.longValue];
    [self.socket readDataToData:self.separator withTimeout:15 tag:initCommandIndex.longValue];
}

-(void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    //DLog(@"%@",err);
    self.lastError = err;
   
    //Altera o estado atual e avisa o delegate
    self.state = ssDisconnected;
    [self.delegate scannerBecameUnavailable:self];
    
    //Tenta conectar novamente
    //Aguarda 10s antes de tentar conectar novamente
    double delayInSeconds = 10.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.socket connectToHost:self.host onPort:self.port withTimeout:15 error:nil];
    });
}

-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSString *dataRead = [[NSString alloc]initWithData:data encoding:NSASCIIStringEncoding];
    //dataRead = [dataRead stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    //Remove tudo que não é [A-Z][a-z][0-9]>.?:
    NSCharacterSet *charactersToRemove = [NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789>.:? "];
    charactersToRemove = [charactersToRemove invertedSet];
    dataRead = [[dataRead componentsSeparatedByCharactersInSet:charactersToRemove] componentsJoinedByString:@""];
    self.lastResponse = dataRead;
    [self.delegate didGetRawData:dataRead command:self.lastCommand];
    //DLog(@"comando: %@",self.lastCommand);
    //DLog(@"resposta: %@",self.lastResponse);
    
    EDPID *pid = nil;
    
    switch (self.state) {
        case ssInitializing:
            /*if([dataRead hasPrefix:@"4100"]) { //PIDs disponíveis
                self.state = ssReady;
                [self.delegate scannerBecameAvailable:self];
            }*/
            initCommandIndex = @(initCommandIndex.intValue + 1);
            //Envia os comandos de inicialização um a um
            if(initCommandIndex.intValue <= (initCommands.count - 1)) {
                self.lastCommand = initCommands[initCommandIndex.intValue];
                [self.socket writeData:[initCommands[initCommandIndex.intValue] dataUsingEncoding:NSASCIIStringEncoding]
                           withTimeout:10
                                   tag:initCommandIndex.longValue];
                [self.socket readDataToData:self.separator
                                withTimeout:10
                                        tag:initCommandIndex.longValue];
            }
            else {
                //Todos os comandos de inicialização já foram enviados.
                //Atualiza o estado e informa o delegate.
                self.state = ssReady;
                [self.delegate scannerBecameAvailable:self];
            }
            break;
        case ssReady:
            //PID recebido
            if([dataRead hasPrefix:@"4103"]) { //fuelsystem
                pid = [[EDPIDFuelSystemStatus alloc]initWithRawData:[[NSString alloc]initWithData:data encoding:NSASCIIStringEncoding]];
            }
            else if([dataRead hasPrefix:@"410B"]) { //MAP
                pid = [[EDPIDMAP alloc]initWithRawData:[[NSString alloc]initWithData:data encoding:NSASCIIStringEncoding]];
            }
            else if([dataRead hasPrefix:@"410C"]) { //RPM
                pid = [[EDPIDRPM alloc]initWithRawData:[[NSString alloc]initWithData:data encoding:NSASCIIStringEncoding]];
            }
            else if([dataRead hasPrefix:@"410D"]) { //VSS
                pid = [[EDPIDVSS alloc]initWithRawData:[[NSString alloc]initWithData:data encoding:NSASCIIStringEncoding]];
            }
            else if([dataRead hasPrefix:@"410F"]) { //IAT
                pid = [[EDPIDIAT alloc]initWithRawData:[[NSString alloc]initWithData:data encoding:NSASCIIStringEncoding]];
            }
            else if([dataRead hasPrefix:@"4114"]) { //O2 sensor
                pid = [[EDPIDO2Sensor alloc]initWithRawData:[[NSString alloc]initWithData:data encoding:NSASCIIStringEncoding]];
            }
            else if([dataRead hasPrefix:@"4115"]) { //O2 sensor
                pid = [[EDPIDO2Sensor alloc]initWithRawData:[[NSString alloc]initWithData:data encoding:NSASCIIStringEncoding]];
            }
            else if([dataRead containsString:@"UNABLETOCONNECT"] ||
                    [dataRead containsString:@"STOPPED"] ||
                    [dataRead containsString:@"NODATA"]) {
                NSString *atz = @"ATZ\r";
                self.lastCommand = atz;
                [self.socket writeData:[atz dataUsingEncoding:NSASCIIStringEncoding] withTimeout:15 tag:initCommandIndex.longValue];
                [self.socket disconnectAfterReadingAndWriting];
            }
            if(pid) {
                //Adiciona PID ao array
                [self.pids addObject:pid];
                if(self.pids.count >= ED_NUMBER_OF_PIDS) {
                    [self.delegate didGetValueOfAllPIDs:self];
                    [self.pids removeAllObjects];
                }
                [self.delegate didGetValueOfPID:pid scanner:self];
            }
            else {
                //Reseta o scanner
                //Aguarda 5s antes de desconectar e tentar conectar novamente
                NSString *atz = @"ATZ\r";
                self.lastCommand = atz;
                [self.socket writeData:[atz dataUsingEncoding:NSASCIIStringEncoding] withTimeout:15 tag:initCommandIndex.longValue];
                [self.socket disconnectAfterReadingAndWriting];
            }
        break;
        default:
        break;
    }
}

-(void)requestValueOfPID:(EDPID *)pid {
    NSString *command = [NSString stringWithFormat:@"%@%@1\r",
                         pid.dtm,
                         pid.pid];
    switch (self.state) {
        case ssReady:
            self.lastCommand = command;
            [self.socket writeData:[command dataUsingEncoding:NSASCIIStringEncoding] withTimeout:10 tag:0];
            [self.socket readDataToData:self.separator
                            withTimeout:10
                                    tag:0];
            break;
        case ssInitializing:
            break;
        case ssDisconnected:
            [self.socket disconnectAfterReadingAndWriting];
            break;
        default:
            break;
    }
}

@end
