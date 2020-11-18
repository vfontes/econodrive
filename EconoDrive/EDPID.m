//
//  EDPID.m
//  
//
//  Created by Vinicius Fontes on 17/10/14.
//
//


#import "EDPID.h"

@implementation EDPID

-(instancetype)init {
    self = [super init];
    self.dtm = @"01";
    self.pid = [NSString new];
    self.rawData = [NSString new];
    self.bytes = [NSMutableArray new];
    self.value = [NSNumber new];
    self.name = [NSString new];
    return self;
}

-(instancetype)initWithRawData:(NSString *)rawData {
    self = [self init];
    
    //Remove tudo que não é [A-Z][a-z][0-9]
    NSCharacterSet *charactersToRemove = [NSCharacterSet characterSetWithCharactersInString:@"ABCDEFabcdef0123456789"];
    charactersToRemove = [charactersToRemove invertedSet];
    self.rawData = [[rawData componentsSeparatedByCharactersInSet:charactersToRemove] componentsJoinedByString:@""];
    //self.rawData = [rawData stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    //self.rawData = [rawData stringByReplacingOccurrencesOfString:@" " withString:@""];

    //Armazena os bytes um a um em um array
    NSMutableArray *tempBytes = [NSMutableArray new];
    for (int i = 0; i <= (self.rawData.length - 2); i = i + 2) {
        [tempBytes addObject:[self.rawData substringWithRange:NSMakeRange(i, 2)]];
    }
    
    //Define o DTM
    [self calculateDTM:tempBytes.firstObject];
    
    //Define o PID
    self.pid = [tempBytes[1] copy];
    
    //Todos os demais bytes fazem parte da resposta do PID
    if(tempBytes.count > 2) {
        for (int i = 2; i <= tempBytes.count -1; i++) {
            [self.bytes addObject:[tempBytes[i] copy]];
        }
    }
    return self;
}

-(void)calculateDTM:(NSString *)byte {
    NSScanner *scanner = [NSScanner scannerWithString:byte];
    unsigned int b;
    [scanner scanHexInt:&b];
    b = b - 64;
    self.dtm = [[NSString stringWithFormat:@"%02x",b] uppercaseString];
}

/*-(NSString *)description {
    return [NSString stringWithFormat:@"name: %@ \t rawData: %@ \t DTM: %@ \t PID: %@ \t Value: %@",self.name, self.rawData, self.dtm, self.pid, self.value];
}*/

-(BOOL)isEqual:(id)object {
    EDPID *obj = (EDPID *)object;
    if([self.dtm isEqualToString:obj.dtm] && [self.pid isEqualToString:obj.pid]) {
        return YES;
    }
    else return NO;
}

@end
