//
//  ViewController.h
//  Instant Lyrics
//
//  Created by Tom Lai on 6/21/15.
//  Copyright © 2015 Tsz Chun Lai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NJKWebViewProgress.h"
@interface ViewController : UIViewController <UIViewControllerRestoration, UIPopoverPresentationControllerDelegate>
//-(BOOL)webView:(nonnull UIWebView *)webView shouldStartLoadWithRequest:(nonnull NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
-(void)webViewDidFinishLoad:(nonnull UIWebView *)webView;
-(void)swipeBack:(nonnull UIScreenEdgePanGestureRecognizer *)regcognizer;
-(void)swipeForward:(nonnull UIScreenEdgePanGestureRecognizer *)regcognizer;
- (void)popoverPresentationControllerDidDismissPopover:(nonnull UIPopoverPresentationController *)popoverPresentationController;
- (BOOL)currentArtistTitle:(NSString *__nullable *__nullable)result;
typedef enum searchOptions
{
    SEARCH_OPTIONAL,
    SEARCH_FORCED
} searchOptions;
@end

