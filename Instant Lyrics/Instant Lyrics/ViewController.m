//
//  ViewController.m
//  Instant Lyrics
//
//  Created by Tom Lai on 6/21/15.
//  Copyright © 2015 Tsz Chun Lai. All rights reserved.
//

#import "ViewController.h"
#import "ILURLLog.h"
#import "ILURLEntry.h"
#import "AppDelegate.h"
#import "Prefix.pch"
#import "ILWelcomeViewController.h"
#import "ILSettingsMasterTableViewController.h"
#import "NJKWebViewProgress.h"
@import MediaPlayer;
@import WebKit;
@interface ViewController () <UIViewControllerRestoration, UIPopoverPresentationControllerDelegate, UIViewControllerRestoration, UIWebViewDelegate, UIGestureRecognizerDelegate, UIAlertViewDelegate, UISearchBarDelegate>
@property (strong, nonatomic) ILURLLog *urlmap;
@property (strong, nonatomic) MPMusicPlayerController *MPcontroller;
@property (strong, nonatomic) WKWebView *webView;
@property (weak, nonatomic) IBOutlet UIView *centerView;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *forwardButton;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@end

NSString *const searchbarPlaceholder = @"Search Lyrics";
@implementation ViewController
{
    // This is a global variable
    NJKWebViewProgress *_progressProxy;
}
- (NSUserDefaults *)defaults {
    return [NSUserDefaults standardUserDefaults];
}
#pragma mark- lazy instntiation
- (MPMusicPlayerController *)MPcontroller {
    if (!_MPcontroller) {
        _MPcontroller = [[MPMusicPlayerController alloc] init];
//        _webView.UIDelegate=_progressProxy;
    }
    return _MPcontroller;
}
- (WKWebView *)webView {
    if (!_webView) {
        _webView = [WKWebView new];
    }
    return _webView;
}
- (NJKWebViewProgress *)progressProxy {
    if (!_progressProxy) {
        _progressProxy = [[NJKWebViewProgress alloc] init];
    }
    return _progressProxy;
}
#pragma mark - UIView
- (void)loadView {
    [super loadView];

    self.centerView = self.webView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    _webView.scrollView.scrollEnabled = YES;
//    _webView.scalesPageToFit =YES;
//    _webView.clipsToBounds = NO;
//    _webView.scrollView.clipsToBounds = NO;
//    _webView.allowsInlineMediaPlayback = NO;
//    _webView.mediaPlaybackRequiresUserAction = YES;
//    _progressProxy.webViewProxyDelegate = self;
//    _progressProxy.progressDelegate = self;
    
    NSURL *url = [[NSURL alloc]initWithString:@"https://google.com"];
    NSURLRequest *requst = [[NSURLRequest alloc]initWithURL:url];
    [self.webView loadRequest:requst];

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

    [self.MPcontroller beginGeneratingPlaybackNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(searchLyricsIfPlaying)
                                                 name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(searchLyricsIfPlaying)
                                                 name:MPMusicPlayerControllerPlaybackStateDidChangeNotification
                              object:nil];
    self.urlmap = [ILURLLog sharedLog];
//    self.progressView.backgroundColor = [UIColor clearColor];
    

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

//    [[self progressView] setAlpha:0];
//    [[self progressView] setProgress:0];

//    [self searchLyricsIfPlaying]; //uncomment after screenshot taking
    [self searchLyricsHelperWithArtistTitle:@"U2 Song for Someone"]; //remove after screenshot taking
//    [self updateBackForwardButtons];

}
- (void)viewDidAppear:(BOOL)animated
{
//    [self displayWelcome]; //uncomment after screenshot taking
//    [self updateBackForwardButtons];
}
- (void)displayWelcome
{
    if([self.defaults boolForKey:ILNoMusicPlayingScreenToggleKey] &&
       [_MPcontroller playbackState] != MPMusicPlaybackStatePlaying)
    {
        ILWelcomeViewController * welcomeVC = [[ILWelcomeViewController alloc] initWithNibName:@"Welcome" bundle:nil];
        
        welcomeVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        
        [self presentViewController:welcomeVC animated:YES completion:nil];
    }
}
- (void)searchLyricsIfPlaying
{
    
    if ([_MPcontroller playbackState] == MPMusicPlaybackStatePlaying)
    {
        [self searchLyricsWithOptions: SEARCH_OPTIONAL];
    }

}
- (void)searchLyricsWithOptions:(searchOptions)options {
    NSString* at = nil;
    if ([self currentArtistTitle:&at])
    {
        ILURLEntry* lastEntry = [self.urlmap lastEntry];
        
        // This generated URL is the same as last, so don't load
        if (options == SEARCH_OPTIONAL &&
            [lastEntry.originUrl isEqual:[self generateSearchURLWithArtistTitle:at]])
        {
            return;
        }
        [self searchLyricsHelperWithArtistTitle:at];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry"
                                                        message:@"We only support local music at this time"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }

}
- (BOOL)currentArtistTitle:(NSString**)result {
    MPMediaItem *mediaItem = [_MPcontroller nowPlayingItem];
    if (mediaItem)
    {
        NSMutableString* at = [[NSMutableString alloc] init];
        
        NSString* artist = [mediaItem valueForKey:MPMediaItemPropertyArtist];
        NSString* title = [mediaItem valueForKey:MPMediaItemPropertyTitle];
        if (artist) [at appendString:artist];
        if (artist && title) [at appendString:@" "];
        if (title) [at appendString:title];
        
        *result =  [at copy];
        return true;
    }
    else
    {
        return false;
    }
}
- (void)searchLyricsHelperWithArtistTitle:(NSString*) at
{
    NSURL* url = [self generateSearchURLWithArtistTitle:at];
    [self loadURL:url];
    [[self urlmap]addURL:url forArtistTitle:at];
}
- (NSURL *)generateSearchURLWithArtistTitle:(NSString *)at
{
    NSMutableString* query = [at mutableCopy];
    NSString* stringToPrepend = [self.defaults objectForKey:ILPrependPrefsKey];
    query = [NSMutableString stringWithFormat:@"%@ %@", stringToPrepend,query];
    NSMutableString *urlStr = [NSMutableString stringWithFormat:@"%@",
                               [query stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLPathAllowedCharacterSet]]];
    
//    [urlStr replaceOccurrencesOfString:@"$" withString:@"%24" options:NSCaseInsensitiveSearch range: NSMakeRange(0, [urlStr length])];
//    [urlStr replaceOccurrencesOfString:@"&" withString:@"%26" options:NSCaseInsensitiveSearch range: NSMakeRange(0, [urlStr length])];
//    [urlStr replaceOccurrencesOfString:@"+" withString:@"%2B" options:NSCaseInsensitiveSearch range: NSMakeRange(0, [urlStr length])];
//    [urlStr replaceOccurrencesOfString:@"," withString:@"%2C" options:NSCaseInsensitiveSearch range: NSMakeRange(0, [urlStr length])];
//    [urlStr replaceOccurrencesOfString:@"/" withString:@"%2F" options:NSCaseInsensitiveSearch range: NSMakeRange(0, [urlStr length])];
//    [urlStr replaceOccurrencesOfString:@":" withString:@"%3A" options:NSCaseInsensitiveSearch range: NSMakeRange(0, [urlStr length])];
//    [urlStr replaceOccurrencesOfString:@";" withString:@"%3B" options:NSCaseInsensitiveSearch range: NSMakeRange(0, [urlStr length])];
//    [urlStr replaceOccurrencesOfString:@"=" withString:@"%3D" options:NSCaseInsensitiveSearch range: NSMakeRange(0, [urlStr length])];
//    [urlStr replaceOccurrencesOfString:@"?" withString:@"%3F" options:NSCaseInsensitiveSearch range: NSMakeRange(0, [urlStr length])];
    
    NSString* searchEngineName = [self.defaults objectForKey:ILSearchEnginePrefsKey];
    NSString* baseURL = [searchEngineBaseURLs objectForKey:searchEngineName];
    urlStr = [NSMutableString stringWithFormat:@"%@%@", baseURL, urlStr];
    
    UALog(@"%@",urlStr);
    return [NSURL URLWithString:urlStr];
}
//memory pressure ios
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}

- (void)loadURL: (NSURL*) url
{
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}
#pragma mark - UIWebViewDelegate

//-(void)webViewDidStartLoad:(nonnull UIWebView *)webView
//{
//
//    if (self.progressView.progress > 0)
//    {
//        [UIView animateWithDuration:0.2f animations:^{
//            [[self progressView] setAlpha:1];
//        }];
//    }
//    [self updateBackForwardButtons];
//}
//-(void)webViewDidFinishLoad:(nonnull UIWebView *)webView
//{
//    if (self.progressView.progress >= 1)
//    {
//        [UIView animateWithDuration:0.2f animations:^{
//            [[self progressView] setAlpha:0.0f];
//        }];
//        UALog(@"%@",[self webView].request.URL);
//    }
//}
#pragma mark - gestures
-(void)swipeForward:(UIScreenEdgePanGestureRecognizer *)regcognizer
{
    if (regcognizer.state == UIGestureRecognizerStateEnded) {
        if (self.webView.canGoForward) [[self webView]goForward];
    }
}

-(void)swipeBack:(UIScreenEdgePanGestureRecognizer *)regcognizer
{
    if (regcognizer.state == UIGestureRecognizerStateEnded) {
        if (self.webView.canGoBack) [[self webView]goBack];
    }
}

#pragma mark - refresh button

- (IBAction)refresh:(id)sender
{
    [self searchLyricsWithOptions:SEARCH_FORCED];
}

#pragma mark - action button
-(IBAction)actionButtonPressed:(id)sender {

    UALog(@"shareButton pressed");

    [[UIApplication sharedApplication] openURL:self.webView.URL];
}

#pragma mark - search button
-(void)alertView:(nonnull UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        NSString* artistTitle = [NSMutableString stringWithFormat:@"%@",[alertView textFieldAtIndex:0].text];
        [self searchLyricsHelperWithArtistTitle:artistTitle];
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

#pragma mark - dealloc
- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMusicPlayerControllerPlaybackStateDidChangeNotification
                                                  object:nil];
    [self.MPcontroller endGeneratingPlaybackNotifications];
}

#pragma mark - state restoration
+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(nonnull NSArray *)path coder:(nonnull NSCoder *)coder
{
    return nil;
}

#pragma mark - NJKWebViewProgressDelegate
-(void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{

}
#pragma mark - UIPopoverControllerDelegate
- (void)popoverPresentationControllerDidDismissPopover:(UIPopoverPresentationController *)popoverPresentationController
{

}
#pragma mark - UI story board
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

    
}


@end
