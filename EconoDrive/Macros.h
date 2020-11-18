//
//  Macros.h
//  EconoDrive
//
//  Created by Vinicius Fontes on 18/10/14.
//  Copyright (c) 2014 Vinicius Fontes. All rights reserved.
//

#ifndef EconoDrive_Macros_h
#define EconoDrive_Macros_h

    #ifdef DEBUG
    #define DLog(fmt, ...) NSLog((@"%s[%d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
    #else
    #   define DLog(...)
    #endif

    #define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
    #ifdef DEBUG
    #   define ULog(fmt, ...)  { UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%s\n [Line %d] ", __PRETTY_FUNCTION__, __LINE__] message:[NSString stringWithFormat:fmt, ##__VA_ARGS__]  delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil]; [alert show]; }
    #else
    #   define ULog(...)
    #endif

#endif
