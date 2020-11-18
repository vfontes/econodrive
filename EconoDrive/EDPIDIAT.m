//
//  EDPIDIAT.m
//  EconoDrive
//
//  Created by Vinicius Fontes on 20/10/14.
//  Copyright (c) 2014 Vinicius Fontes. All rights reserved.
//

#import "EDPIDIAT.h"

@implementation EDPIDIAT

-(instancetype)init {
    self = [super init];
    self.name = @"obd_iat";
    self.pid = @"0F";
    self.bytes = [[NSMutableArray alloc]initWithCapacity:1];
    return self;
}

-(NSNumber *)value {
    if(self.bytes.count == 1) {
        NSScanner *scannerA = [NSScanner scannerWithString:[self.bytes objectAtIndex:0]];
        unsigned int byteA;
        [scannerA scanHexInt:&byteA];
        return [NSNumber numberWithDouble:(byteA - 40 + 274.15)];
    }
    else return nil;
}
@end
