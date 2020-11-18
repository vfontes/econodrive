//
//  AppDelegate.h
//  EconoDrive
//
//  Created by Vinicius Fontes on 17/10/14.
//  Copyright (c) 2014 Vinicius Fontes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Macros.h"
#import "Constants.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate> 
@property (strong, nonatomic) UIWindow *window;
@property (strong) CLLocationManager *locationManager;
@property (strong, atomic) NSNumber *totalDistance;
@property (strong, atomic) NSNumber *currentDistance;
@property (strong, atomic) CLLocation *previousLocation;
@property (strong, atomic) CLLocation *currentLocation;

@end

