//
//  ViewController.h
//  Instant Lyrics
//
//  Created by Tom Lai on 6/21/15.
//  Copyright © 2015 Tsz Chun Lai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NJKWebViewProgress.h"
@interface ViewController : UIViewController

- (NSString *)currentArtistTitle;
typedef enum searchOptions
{
    SEARCH_OPTIONAL,
    SEARCH_FORCED
} searchOptions;
@end

