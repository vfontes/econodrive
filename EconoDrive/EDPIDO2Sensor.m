//
//  EDPIDO2Sensor.m
//  EconoDrive
//
//  Created by Vinicius Fontes on 20/10/14.
//  Copyright (c) 2014 Vinicius Fontes. All rights reserved.
//

#import "EDPIDO2Sensor.h"

@implementation EDPIDO2Sensor

-(instancetype)init {
    self = [super init];
    self.name = @"obd_o2sensor";
    self.pid = @"14";
    self.bytes = [[NSMutableArray alloc]initWithCapacity:2];
    return self;
    
}

-(NSNumber *)value {
    if(self.bytes.count == 2) { //Apenas o segundo byte será considerado
        NSScanner *scannerA = [NSScanner scannerWithString:[self.bytes objectAtIndex:1]];
        unsigned int byteA;
        [scannerA scanHexInt:&byteA];
        return [NSNumber numberWithFloat:((float)byteA-128.0)*100.0/128.0];
    }
    else return nil;
}
@end
