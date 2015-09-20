//
//  ILWebViewController.m
//  Instant Lyrics
//
//  Created by Tom Lai on 9/20/15.
//  Copyright © 2015 Tom. All rights reserved.
//

#import "ILWebViewController.h"
@import WebKit;
@interface ILWebViewController ()
@property (strong, nonatomic) WKWebView* webView;
@property (strong, nonatomic) NSURLRequest *request;
@end
@implementation ILWebViewController
- (WKWebView *)webView {
    if (!_webView) {
        _webView = [[WKWebView alloc] init];
        _webView.scrollView.scrollEnabled = YES;
        _webView.clipsToBounds = NO;
        _webView.scrollView.clipsToBounds = NO;
        _webView.allowsBackForwardNavigationGestures = YES;
        _webView.backgroundColor = [UIColor redColor];
        _webView.scrollView.backgroundColor = [UIColor blueColor];
    }
    return _webView;
}
- (void)setUrl:(NSURL *)url
{
    _url = url;
    _request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:self.request];
}

- (void)viewDidLoad {
//    NSURLRequest *request = [NSURLRequest requestWithURL:self.url];
    
}

- (void)loadView {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.google.com"]];
    [self.webView loadRequest:request];
}

- (BOOL)canGoBack {
    return self.webView.canGoBack;
}
- (BOOL)canGoForward {
    return self.webView.canGoForward;
}
- (void)goBack {
    if (self.canGoBack) {
        [self.webView goBack];
    }
}
- (void)goForward {
    if (self.canGoForward) {
        [self.webView goForward];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
