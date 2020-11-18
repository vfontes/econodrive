//
//  AppDelegate.m
//  EconoDrive
//
//  Created by Vinicius Fontes on 17/10/14.
//  Copyright (c) 2014 Vinicius Fontes. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    if(self.previousLocation == nil) {
        self.previousLocation = [locations.firstObject copy];
        self.currentDistance = @(0);
        //self.totalDistance = @(0);
    }
    else {
        self.previousLocation = [self.currentLocation copy];
        self.currentLocation = [locations.lastObject copy];
        
        //DLog(@"locations: %@",locations);
        //DLog(@"previousLocation: %@",self.previousLocation);
        //DLog(@"currentLocation: %@",self.currentLocation);
        
        if(self.previousLocation.horizontalAccuracy <= 50.0 && self.currentLocation.horizontalAccuracy <= 50.0) {
            if([self.currentLocation distanceFromLocation:self.previousLocation] > 0.0) {
                DLog(@"calculando distancia");
                self.currentDistance = @([self.currentLocation distanceFromLocation:self.previousLocation] / 1000.0);
                self.totalDistance = @(self.totalDistance.doubleValue + self.currentDistance.doubleValue);
                //DLog(@"currentDistance: %@",self.currentDistance);
                //DLog(@"totalDistance: %@",self.totalDistance);
            }
        }
    }
    //[self.locationManager allowDeferredLocationUpdatesUntilTraveled:10.0 timeout:CLTimeIntervalMax];
}

- (void)registerDefaultsFromSettingsBundle {
    NSString *settingsBundle = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"];
    if(!settingsBundle) {
        NSLog(@"Could not find Settings.bundle");
        return;
    }
    
    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:[settingsBundle stringByAppendingPathComponent:@"Root.plist"]];
    NSArray *preferences = [settings objectForKey:@"PreferenceSpecifiers"];
    
    NSMutableDictionary *defaultsToRegister = [[NSMutableDictionary alloc] initWithCapacity:[preferences count]];
    for(NSDictionary *prefSpecification in preferences) {
        NSString *key = [prefSpecification objectForKey:@"Key"];
        if(key) {
            [defaultsToRegister setObject:[prefSpecification objectForKey:@"DefaultValue"] forKey:key];
        }
    }
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultsToRegister];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
        
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];

    // Get the application user default values
    NSNumber *stoichRate = @([[NSUserDefaults standardUserDefaults] floatForKey:@"stoichRate"]);
    NSNumber *ev = @([[NSUserDefaults standardUserDefaults] floatForKey:@"ev"]);
    NSNumber *vdm = @([[NSUserDefaults standardUserDefaults] floatForKey:@"vdm"]);
    
    if(!(stoichRate.floatValue > 0) || !(ev.floatValue > 0 ) || !(vdm.floatValue > 0)) {
        [self registerDefaultsFromSettingsBundle];
    }
    self.totalDistance = @(0);
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
