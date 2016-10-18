//
//  AppDelegate.m
//  NoteTask
//
//  Created by Ben on 16/1/16.
//  Copyright (c) 2016年 Ben. All rights reserved.
//

#import "AppDelegate.h"
#import "NoteViewController.h"
#import "RootViewController.h"
@interface AppDelegate () {
GCDWebServer* _webServer;
}
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [UIpConfig sharedUIpConfig];
    
    [AppConfig sharedAppConfig];

    RootViewController *vc = [[RootViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    
    // Create server
    
    _webServer = [[GCDWebServer alloc] init];
    
    // Add a handler to respond to GET requests on any URL
    [_webServer addDefaultHandlerForMethod:@"GET"
                              requestClass:[GCDWebServerRequest class]
                              processBlock:^GCDWebServerResponse *(GCDWebServerRequest* request) {
                                  
                                  NSString *resPath= [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"note.htm"];
                                  
                                  NSData *data = [NSData dataWithContentsOfFile:resPath];
                                  NSString *s = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

                                  return [GCDWebServerDataResponse responseWithHTML:s];
                                  
//                                  return [GCDWebServerDataResponse responseWithHTML:@"<html><body><p>Hello World</p></body></html>"];
                                  
                              }];
    
    // Start server on port 8080
    [_webServer startWithPort:8080 bonjourName:nil];
    NSLog(@"Visit %@ in your web browser", _webServer.serverURL);
    
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
