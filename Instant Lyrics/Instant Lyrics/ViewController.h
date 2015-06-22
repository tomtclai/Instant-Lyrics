//
//  ViewController.h
//  Instant Lyrics
//
//  Created by Tom Lai on 6/21/15.
//  Copyright © 2015 Tom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
-(BOOL)webView:(nonnull UIWebView *)webView shouldStartLoadWithRequest:(nonnull NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
-(void)webViewDidFinishLoad:(nonnull UIWebView *)webView;
-(void)swipeBack:(__nonnull UIScreenEdgePanGestureRecognizer *)regcognizer;
-(void)swipeForward:(__nonnull UIScreenEdgePanGestureRecognizer *)regcognizer;
@end

