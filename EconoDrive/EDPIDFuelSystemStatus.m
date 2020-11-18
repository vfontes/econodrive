//
//  EDPIDFuelSystemStatus.m
//  EconoDrive
//
//  Created by Vinicius Fontes on 20/10/14.
//  Copyright (c) 2014 Vinicius Fontes. All rights reserved.
//

#import "EDPIDFuelSystemStatus.h"

@implementation EDPIDFuelSystemStatus

-(instancetype)init {
    self = [super init];
    self.name = @"obd_fuelsys";
    self.pid = @"03";
    self.bytes = [[NSMutableArray alloc]initWithCapacity:2];
    return self;
}

-(NSNumber *)value {
    if(self.bytes.count == 2) { //Apenas o primeiro byte será considerado
        NSScanner *scannerA = [NSScanner scannerWithString:[self.bytes objectAtIndex:0]];
        unsigned int byteA;
        [scannerA scanHexInt:&byteA];
        return [NSNumber numberWithInt:(byteA)];
    }
    else return nil;
}

@end
