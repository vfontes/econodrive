//
//  EDPIDMAP.m
//  EconoDrive
//
//  Created by Vinicius Fontes on 20/10/14.
//  Copyright (c) 2014 Vinicius Fontes. All rights reserved.
//

#import "EDPIDMAP.h"

@implementation EDPIDMAP

-(instancetype)init {
    self = [super init];
    self.name = @"obd_map";
    self.pid = @"0B";
    self.bytes = [[NSMutableArray alloc]initWithCapacity:1];
    return self;
    
}

-(NSNumber *)value {
    if(self.bytes.count == 1) {
        NSScanner *scannerA = [NSScanner scannerWithString:[self.bytes objectAtIndex:0]];
        unsigned int byteA;
        [scannerA scanHexInt:&byteA];
        return @(fabs(101.325 - (float)byteA));
        //return @(byteA);
    }
    else return nil;
}

@end
