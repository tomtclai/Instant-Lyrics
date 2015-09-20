//
//  ILWebViewController.h
//  Instant Lyrics
//
//  Created by Tom Lai on 9/20/15.
//  Copyright © 2015 Tom. All rights reserved.
//

#import "ViewController.h"

@interface ILWebViewController : UIViewController
@property (strong, nonatomic) NSURL *url;
- (BOOL)canGoBack;
- (BOOL)canGoForward;
- (void)goBack; // go back if possible
- (void)goForward; // go forward if possible
@end
