//
//  AppDelegate.h
//  Instant Lyrics
//
//  Created by Tom Lai on 6/21/15.
//  Copyright © 2015 Tsz Chun Lai. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const ILPrependPrefsKey;
extern NSString * const ILSearchEnginePrefsKey;
extern NSString * const ILPrependOptionsKey;
extern NSString * const ILSearchEngineOptionsKey;
extern NSString * const ILNoMusicPlayingScreenToggleKey;
extern NSDictionary * searchEngineBaseURLs;
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;


@end

