//
//  AppDelegate.m
//  Instant Lyrics
//
//  Created by Tom Lai on 6/21/15.
//  Copyright © 2015 Tsz Chun Lai. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "ILURLLog.h"
#import <UALogger.h>

NSString * const ILPrependPrefsKey =  @"PrependValue";
NSString * const ILSearchEnginePrefsKey = @"SearchEngineValue";
NSString * const ILPrependOptionsKey =  @"AvailPrependValues";
NSString * const ILSearchEngineOptionsKey = @"AvailSearchEngineValues";
NSString * const ILNoMusicPlayingScreenToggleKey = @"NoMusicPlayingScreenToggle";
NSDictionary * searchEngineBaseURLs;

@interface AppDelegate ()
@property (strong, nonatomic) ViewController* rootViewController;
@end

@implementation AppDelegate
@synthesize window = _window;

+ (void)initialize
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *factorySettings = @{
                                      ILPrependPrefsKey: @"Lyrics",
                                      ILSearchEnginePrefsKey: @"Google",
                                      ILPrependOptionsKey:
                                          @[@"",
                                            @"Lyrics",
                                            @"Letras",
                                            @"Paroles",
                                            @"가사",
                                            @"歌詞",
                                            @"歌词"],
                                      ILSearchEngineOptionsKey:
                                          @[@"Google",
                                            @"Bing",
                                            @"DuckDuckGo",
                                            @"BaiDu",
                                            @"LyricWiki"],
                                      ILNoMusicPlayingScreenToggleKey:@YES
                                      };
    searchEngineBaseURLs = @{
                             @"Google"    :@"https://www.google.com/search?q=",
                             @"Bing"      :@"https://www.bing.com/search?q=",
                             @"DuckDuckGo":@"https://duckduckgo.com/?q=",
                             @"BaiDu"     :@"https://www.baidu.com/s?wd=",
                             @"LyricWiki" :@"https://lyrics.wikia.com/Special:Search?search="
                             };
    [defaults registerDefaults:factorySettings];
}
- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // dunno why this is necessary, disabled for now
    // self.window = [[UIWindow alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
    
    
    // The following fixes "Unbalanced calls to begin/end appearance transitions." this turns out to be always needed. see https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIApplicationDelegate_Protocol/index.html#//apple_ref/occ/intfm/UIApplicationDelegate/application:willFinishLaunchingWithOptions:
    [self.window makeKeyAndVisible];
    return YES;
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    if (!self.window.rootViewController)
    {
        self.window.rootViewController = [[ViewController alloc] init];
    }
    

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    if( [[ILURLLog sharedLog] saveChanges]) {
        UALog(@"Saved all of the URL Logs");
    }
    else {
        UALog(@"Could not save any of the URL Logs ");
    }
    
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
#pragma mark - state restoration
- (BOOL)application:(UIApplication *)application shouldSaveApplicationState:(nonnull NSCoder *)coder
{
    return YES;
}

- (BOOL)application:(nonnull UIApplication *)application shouldRestoreApplicationState:(nonnull NSCoder *)coder
{
    return YES;
}
@end
