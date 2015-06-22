//
//  ViewController.m
//  Instant Lyrics
//
//  Created by Tom Lai on 6/21/15.
//  Copyright © 2015 Tom. All rights reserved.
//

#import "ViewController.h"
@import MediaPlayer;
@interface ViewController () <UIWebViewDelegate, UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) MPMusicPlayerController *controller;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (strong, nonatomic) NSString *query;
@property (strong, nonatomic) NSURL *lastURL;
@end

@implementation ViewController

- (void)viewDidLoad {
    self.controller = [[MPMusicPlayerController alloc] init];
    self.webView.delegate=self;
    [super viewDidLoad];
    self.webView.scrollView.scrollEnabled = YES;
    
    UIScreenEdgePanGestureRecognizer
    *rightSwipeRecognizer =
    [[UIScreenEdgePanGestureRecognizer alloc]initWithTarget:self
                                                     action:@selector(swipeBack:)];
    
    UIScreenEdgePanGestureRecognizer
    *leftSwipeRecognizer =
    [[UIScreenEdgePanGestureRecognizer alloc]initWithTarget:self
                                                     action:@selector(swipeForward:)];
    
    rightSwipeRecognizer.edges = UIRectEdgeLeft;
    leftSwipeRecognizer.edges = UIRectEdgeRight;
    
    [self.view addGestureRecognizer:rightSwipeRecognizer];
    [self.view addGestureRecognizer:leftSwipeRecognizer];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadLyrics)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [[self progressView] setHidden:YES];
    [[self progressView] setProgress:0];
    [self loadLyrics];
}

- (void)loadLyrics {
    MPMediaItem *mediaItem = [_controller nowPlayingItem];
    if ([_controller playbackState] != MPMusicPlaybackStatePlaying)
    {
        NSLog(@"No music playing");
        return;
    }
    if (!mediaItem)
    {
        NSLog(@"Home shared library.");
        return;
    }
    
    if ([mediaItem mediaType] == MPMediaTypeMusic)
    {
        NSString* artist = [mediaItem valueForKey:MPMediaItemPropertyArtist];
        NSString* title = [mediaItem valueForKey:MPMediaItemPropertyTitle];

        self.query = [NSString stringWithFormat:@"%@ %@ Lyrics", artist, title];
        NSLog(@"%@",self.query);
    }
    [self searchForLyrics];
//        else if ([mediaItem mediaType] == MPMediaTypeMusicVideo)
//    {
//        
//    }
//        else if ([mediaItem mediaType] == MPMediaTypePodcast)
//    {
//        
//    }
}
- (void)searchForLyrics
{
    

    NSMutableString *urlStr = [NSMutableString stringWithFormat:@"%@",
                               [self.query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    [urlStr replaceOccurrencesOfString:@"$" withString:@"%24" options:NSCaseInsensitiveSearch range: NSMakeRange(0, [urlStr length])];
    [urlStr replaceOccurrencesOfString:@"&" withString:@"%26" options:NSCaseInsensitiveSearch range: NSMakeRange(0, [urlStr length])];
    [urlStr replaceOccurrencesOfString:@"+" withString:@"%2B" options:NSCaseInsensitiveSearch range: NSMakeRange(0, [urlStr length])];
    [urlStr replaceOccurrencesOfString:@"," withString:@"%2C" options:NSCaseInsensitiveSearch range: NSMakeRange(0, [urlStr length])];
    [urlStr replaceOccurrencesOfString:@"/" withString:@"%2F" options:NSCaseInsensitiveSearch range: NSMakeRange(0, [urlStr length])];
    [urlStr replaceOccurrencesOfString:@":" withString:@"%3A" options:NSCaseInsensitiveSearch range: NSMakeRange(0, [urlStr length])];
    [urlStr replaceOccurrencesOfString:@";" withString:@"%3B" options:NSCaseInsensitiveSearch range: NSMakeRange(0, [urlStr length])];
    [urlStr replaceOccurrencesOfString:@"=" withString:@"%3D" options:NSCaseInsensitiveSearch range: NSMakeRange(0, [urlStr length])];
    [urlStr replaceOccurrencesOfString:@"?" withString:@"%3F" options:NSCaseInsensitiveSearch range: NSMakeRange(0, [urlStr length])];
    
    urlStr = [NSMutableString stringWithFormat:@"http://www.google.com/search?q=%@", urlStr];
    
    NSLog(@"%@",urlStr);
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma Mark - UIWebViewDelegate
-(BOOL)webView:(nonnull UIWebView *)webView shouldStartLoadWithRequest:(nonnull NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if(request.URL != self.lastURL)
    {
        [[self progressView] setHidden:NO];
    }
    if ([self progressView].progress <= 0.05)
    {
        [[self progressView] setProgress:0.05 animated:YES];
    }
    self.lastURL = [[request URL]copy];
    return YES;
}
-(void)webViewDidFinishLoad:(nonnull UIWebView *)webView
{
    [[self progressView] setProgress:1.0 animated:YES];
    
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [[self progressView] setHidden:YES];
        [[self progressView] setProgress:0];
    });
}
#pragma Mark - gestures
-(void)swipeForward:(UIScreenEdgePanGestureRecognizer *)regcognizer
{
    if (regcognizer.state == UIGestureRecognizerStateEnded) {
        if (_webView.canGoForward) [[self webView]goForward];
    }
}

-(void)swipeBack:(UIScreenEdgePanGestureRecognizer *)regcognizer
{
    if (regcognizer.state == UIGestureRecognizerStateEnded) {
        if (_webView.canGoBack) [[self webView]goBack];
    }
}

@end
