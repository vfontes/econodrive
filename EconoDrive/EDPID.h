//
//  EDPID.h
//  
//
//  Created by Vinicius Fontes on 17/10/14.
//
//

#import <Foundation/Foundation.h>
#include "Constants.h"
#import "Macros.h"

@interface EDPID : NSObject

@property (nonatomic, strong) NSString *dtm;
@property (nonatomic, strong) NSString *pid;
@property (nonatomic, strong) NSString *rawData;
@property (nonatomic, strong) NSMutableArray *bytes;
@property (nonatomic, strong) NSNumber *value;
@property (nonatomic, strong) NSString *name;

-(instancetype)initWithRawData:(NSString *)rawData;


@end
