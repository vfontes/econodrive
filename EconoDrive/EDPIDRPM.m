//
//  EDPIDRPM.m
//  EconoDrive
//
//  Created by Vinicius Fontes on 20/10/14.
//  Copyright (c) 2014 Vinicius Fontes. All rights reserved.
//

#import "EDPIDRPM.h"

@implementation EDPIDRPM


-(instancetype)init {
    self = [super init];
    self.name = @"obd_rpm";
    self.pid = @"0C";
    self.bytes = [[NSMutableArray alloc]initWithCapacity:2];
    return self;
}

-(NSNumber *)value {
    if(self.bytes.count == 2) {
        NSScanner *scannerA = [NSScanner scannerWithString:[self.bytes objectAtIndex:0]];
        NSScanner *scannerB = [NSScanner scannerWithString:[self.bytes objectAtIndex:1]];
        unsigned int byteA, byteB;
        [scannerA scanHexInt:&byteA];
        [scannerB scanHexInt:&byteB];
        return [NSNumber numberWithFloat:(((float)byteA*256.0)+byteB)/4.0];
    }
    else return nil;
}

@end
