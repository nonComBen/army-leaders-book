#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"
#import <FlutterLocalNotificationsPlugin.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [GeneratedPluginRegistrant registerWithRegistry:self];
    
    [FlutterLocalNotificationsPlugin setPluginRegistrantCallback:registerPlugins];

    if (@available(iOS 10.0, *)) {
      [UNUserNotificationCenter currentNotificationCenter].delegate = (id<UNUserNotificationCenterDelegate>) self;
    }
    
    return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

void registerPlugins(NSObject<FlutterPluginRegistry>* registry) {
    [GeneratedPluginRegistrant registerWithRegistry:registry];
}

@end
