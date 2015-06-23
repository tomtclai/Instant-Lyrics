//
//  ViewController.m
//  Instant Lyrics
//
//  Created by Tom Lai on 6/21/15.
//  Copyright © 2015 Tsz Chun Lai. All rights reserved.
//

#import "ViewController.h"
@import MediaPlayer;
@interface ViewController () <UIWebViewDelegate, UIGestureRecognizerDelegate, UIAlertViewDelegate, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) MPMusicPlayerController *controller;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *forwardButton;
@property (strong, nonatomic) NSString *artistTitle;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (strong, nonatomic) NSURL *lastURL;
@end
NSString *const searchbarPlaceholder = @"Search";
@implementation ViewController

#pragma mark - UIView
- (void)viewDidLoad {
    self.controller = [[MPMusicPlayerController alloc] init];
    self.webView.delegate=self;
    [super viewDidLoad];
    self.webView.scrollView.scrollEnabled = YES;
    self.webView.scalesPageToFit =YES;
    self.webView.clipsToBounds = NO;
    self.webView.scrollView.clipsToBounds = NO;
    self.webView.allowsInlineMediaPlayback = NO;
    self.webView.mediaPlaybackRequiresUserAction = YES;
    
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
                                             selector:@selector(loadSearch)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    self.artistTitle = [[NSString alloc]init];
    self.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    self.searchBar.translucent = YES;
    self.searchBar.delegate=self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [[self progressView] setAlpha:0];
    [[self progressView] setProgress:0];
    
    [self loadSearchWithOptions:SEARCH_OPTIONAL];

}
- (void)loadSearch
{
    [self loadSearchWithOptions: SEARCH_OPTIONAL];
}
- (void)loadSearchWithOptions:(searchOptions)options {
    MPMediaItem *mediaItem = [_controller nowPlayingItem];
    if ([_controller playbackState] != MPMusicPlaybackStatePlaying)
    {
        self.searchBar.placeholder = searchbarPlaceholder;
        NSString *urlStr = [NSMutableString stringWithFormat:@"http://www.google.com/search?q="];
        NSLog(@"%@",urlStr);
        NSURL *url = [NSURL URLWithString:urlStr];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [self.webView loadRequest:request];
        return;
    }
    else {
        NSString* artist = [mediaItem valueForKey:MPMediaItemPropertyArtist];
        NSString* title = [mediaItem valueForKey:MPMediaItemPropertyTitle];
        self.artistTitle = [NSString stringWithFormat:@"%@ %@", artist, title];
        
        //This query is same as last query, so don't reload.
        if (options == SEARCH_OPTIONAL &&
            [self.searchBar.placeholder containsString:self.artistTitle])
        {
            return;
        }
        

        [self searchForLyrics];
    }
}
- (void)searchForLyrics
{
    NSMutableString* query = [self.artistTitle mutableCopy];
    if (![query containsString:@" Lyrics"])
    {
        [query appendString:@" Lyrics"];
    };
    self.searchBar.placeholder = query;
    NSMutableString *urlStr = [NSMutableString stringWithFormat:@"%@",
                               [query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
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
    [[self progressView] setAlpha:1];
    [[self progressView] setProgress:0];
    float old = [[self progressView]progress];
    [[self progressView] setProgress:old+0.1 animated:YES];
    //    self.lastURL = [[request URL]copy];
    return YES;
}

-(void)webViewDidStartLoad:(nonnull UIWebView *)webView
{
    [self updateBackForwardButtons];
}
-(void)webViewDidFinishLoad:(nonnull UIWebView *)webView
{
    [[self progressView] setProgress:1.0 animated:YES];
    
    
    
    int64_t delayInSeconds = 0.3;
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [UIView animateWithDuration:0.3f animations:^{
            [[self progressView] setAlpha:0.0f];
            
        } completion:nil];
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

#pragma mark - refresh button

- (IBAction)refresh:(id)sender
{
    [self loadSearchWithOptions:SEARCH_FORCED];
}

#pragma mark - action button
-(IBAction)actionButtonPressed:(id)sender {
    
    NSLog(@"shareButton pressed");
    
    [[UIApplication sharedApplication] openURL:self.webView.request.URL];
}

#pragma mark - search button
-(IBAction)manualSearch:(id)sender
{
    [[self searchBar] becomeFirstResponder];
}

-(void)alertView:(nonnull UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        self.artistTitle = [NSString stringWithFormat:@"%@",[alertView textFieldAtIndex:0].text];
        self.searchBar.placeholder= self.artistTitle;
        [self searchForLyrics];
    }
}
#pragma mark - back button
- (IBAction)backButtonTapped:(id)sender {
    [[self webView]goBack];
    [self updateBackForwardButtons];
}

#pragma mark - forward button
- (IBAction)forwardButtonTapped:(id)sender {
    [[self webView]goForward];
    [self updateBackForwardButtons];
}

#pragma mark - update back/foward buttons
- (void)updateBackForwardButtons
{
    [[self backButton] setEnabled:[self.webView canGoBack]];
    [[self forwardButton] setEnabled:[self.webView canGoForward]];
    
}

#pragma mark - search bar
- (void)searchBarTextDidBeginEditing:(nonnull UISearchBar *)searchBar
{
    if ([searchBar.placeholder isEqualToString:searchbarPlaceholder]) return;
    searchBar.text = searchBar.placeholder;
}
- (void)searchBarSearchButtonClicked:(nonnull UISearchBar *)searchBar
{
    self.artistTitle = [NSString stringWithFormat:@"%@",searchBar.text];
    self.searchBar.text = self.artistTitle;
    [self searchForLyrics];
    searchBar.placeholder = searchBar.text;
    searchBar.text = @"";
    [searchBar resignFirstResponder];

}
@end
