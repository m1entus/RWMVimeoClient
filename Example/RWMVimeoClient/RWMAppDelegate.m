//
//  RWMAppDelegate.m
//  RWMVimeoClient
//
//  Created by Michał Zaborowski on 25.04.2014.
//  Copyright (c) 2014 Railwaymen. All rights reserved.
//

#import "RWMAppDelegate.h"
#import "RWMVimeoOperationManager.h"

@implementation RWMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[RWMVimeoOperationManager sharedOperationManager] setClientId:@"YOUR_CLIENT_ID"
                                             secret:@"YOUR_SECRET"
                                        redirectURL:[NSURL URLWithString:@"rwmbs://login"]];
    
    OAToken *token = [[OAToken alloc] initWithUserDefaultsUsingServiceProviderName:@"qwerty" prefix:@"qwerty"];
    
    if (token) {
        [RWMVimeoOperationManager sharedOperationManager].authenticationToken = token;
        [self searchQuery];
    } else {
        [[RWMVimeoOperationManager sharedOperationManager] authenticateWithBlock:^(NSError *error) {
            if (error) {
                NSLog(@"%@",error);
            }
        }];
    }
    
    
    
    // Override point for customization after application launch.
    return YES;
}

- (void)searchQuery
{
    NSDictionary *paramters = @{
                                @"page" : @2,
                                @"per_page" : @5,
                                @"query" : @"test",
                                @"full_response" : @1
                                };
    
    [[RWMVimeoOperationManager sharedOperationManager] vimeoRequestOperationWithHTTPMethod:@"GET" APIMethod:@"vimeo.videos.search" parameters:paramters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    [[RWMVimeoOperationManager sharedOperationManager] handleOpenURL:url fallbackHandler:^(OAToken *token, NSError *error) {
        if (error) {
            NSLog(@"%@",error);
        } else {
            [token storeInUserDefaultsWithServiceProviderName:@"qwerty" prefix:@"qwerty"];
            [self searchQuery];
        }
    }];
    
    return NO;
}

@end
