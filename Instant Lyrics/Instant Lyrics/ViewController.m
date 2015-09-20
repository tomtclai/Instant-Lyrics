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
@import MediaPlayer;
@interface ViewController () <UIViewControllerRestoration, UIPopoverPresentationControllerDelegate, UIViewControllerRestoration, UIGestureRecognizerDelegate, UIAlertViewDelegate, UISearchBarDelegate, NJKWebViewProgressDelegate, UIWebViewDelegate>
@property (strong, nonatomic) ILURLLog *urlmap;
@property (strong, nonatomic) MPMusicPlayerController *MPcontroller;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *forwardButton;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (strong, nonatomic) NSUserDefaults * defaults;
@end
NSString *const searchbarPlaceholder = @"Search Lyrics";
@implementation ViewController
{
    // This is a global variable
    NJKWebViewProgress *_progressProxy;
}
- (ILURLLog *)urlmap {
    if (!_urlmap) {
        _urlmap = [ILURLLog sharedLog];
    }
    return _urlmap;
}
#pragma mark - UIView
- (void)viewDidLoad {
    _MPcontroller = [[MPMusicPlayerController alloc] init];
    _progressProxy = [[NJKWebViewProgress alloc] init];
    _webView.delegate=_progressProxy;
    [super viewDidLoad];
    _webView.scrollView.scrollEnabled = YES;
    _webView.scalesPageToFit =YES;
    _webView.clipsToBounds = NO;
    _webView.scrollView.clipsToBounds = NO;
    _webView.allowsInlineMediaPlayback = NO;
    _webView.mediaPlaybackRequiresUserAction = YES;
    _progressProxy.webViewProxyDelegate = self;
    _progressProxy.progressDelegate = self;
    _defaults = [NSUserDefaults standardUserDefaults];
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
    self.progressView.backgroundColor = [UIColor clearColor];
    

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [[self progressView] setAlpha:0];
    [[self progressView] setProgress:0];

    [self searchLyricsIfPlaying]; //uncomment after screenshot taking
//    [self searchLyricsHelperWithArtistTitle:@"U2 Song for Someone"]; //remove after screenshot taking
//    [self updateBackForwardButtons];

}
- (void)viewDidAppear:(BOOL)animated
{
    [self displayWelcome]; //uncomment after screenshot taking
    [self updateBackForwardButtons];
}
- (void)displayWelcome
{
    if([self.defaults boolForKey:ILNoMusicPlayingScreenToggleKey] &&
       [self webView].request == nil &&
       [self.MPcontroller playbackState] != MPMusicPlaybackStatePlaying)
    {
        ILWelcomeViewController * welcomeVC = [[ILWelcomeViewController alloc] initWithNibName:@"Welcome" bundle:nil];
        
        welcomeVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        
        [self presentViewController:welcomeVC animated:YES completion:nil];
    }
}
- (void)searchLyricsIfPlaying
{
    
    if ([self.MPcontroller playbackState] == MPMusicPlaybackStatePlaying)
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
        NSURL *generatedURL = [self generateSearchURLWithArtistTitle:at];
        if (options == SEARCH_OPTIONAL &&
            [lastEntry.originUrl isEqual:generatedURL])
        {
            return;
        } else {
            [self loadURL:generatedURL];
            [[self urlmap]addURL:generatedURL forArtistTitle:at];
        }
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
    MPMediaItem *mediaItem = [self.MPcontroller nowPlayingItem];
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
- (NSURL *)generateSearchURLWithArtistTitle:(NSString *)at
{
    NSMutableString* query = [at mutableCopy];
    NSString* stringToPrepend = [self.defaults objectForKey:ILPrependPrefsKey];
    query = [NSMutableString stringWithFormat:@"%@ %@", stringToPrepend,query];
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
    
    NSString* searchEngineName = [self.defaults objectForKey:ILSearchEnginePrefsKey];
    NSString* baseURL = [searchEngineBaseURLs objectForKey:searchEngineName];
    urlStr = [NSMutableString stringWithFormat:@"%@%@", baseURL, urlStr];
    
    UALog(@"%@",urlStr);
    return [NSURL URLWithString:urlStr];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    self.urlmap = nil;
}
- (void)loadURL: (NSURL*) url
{
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}
#pragma mark - UIWebViewDelegate

-(void)webViewDidStartLoad:(nonnull UIWebView *)webView
{

    if (_progressView.progress > 0)
    {
        [UIView animateWithDuration:0.2f animations:^{
            [[self progressView] setAlpha:1];
        }];
    }
    [self updateBackForwardButtons];
}
-(void)webViewDidFinishLoad:(nonnull UIWebView *)webView
{
    if (_progressView.progress >= 1)
    {
        [UIView animateWithDuration:0.2f animations:^{
            [[self progressView] setAlpha:0.0f];
        }];
        UALog(@"%@",[self webView].request.URL);
    }
}
#pragma mark - gestures
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
    [self searchLyricsWithOptions:SEARCH_FORCED];
}

#pragma mark - action button
-(IBAction)actionButtonPressed:(id)sender {

    UALog(@"shareButton pressed");

    [[UIApplication sharedApplication] openURL:self.webView.request.URL];
}

//#pragma mark - search button
//-(void)alertView:(nonnull UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
//{
//    if (buttonIndex == 1)
//    {
//        NSString* artistTitle = [NSMutableString stringWithFormat:@"%@",[alertView textFieldAtIndex:0].text];
//        [self searchLyricsHelperWithArtistTitle:artistTitle];
//    }
//}
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
    UALog(@"%@", NSStringFromSelector(_cmd));
    ViewController *vc = nil;
    UIStoryboard *storyboard = [coder decodeObjectForKey: UIStateRestorationViewControllerStoryboardKey];
    if (storyboard)
    {
        vc = (ViewController *)[storyboard instantiateViewControllerWithIdentifier:@"viewController"];
        
        vc.restorationIdentifier = [path lastObject];
        vc.restorationClass = [self class];
    }
    return [[self alloc]init];
}

#pragma mark - NJKWebViewProgressDelegate
-(void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    [self.progressView setProgress:progress animated:NO];
}
#pragma mark - UIPopoverControllerDelegate
- (void)popoverPresentationControllerDidDismissPopover:(UIPopoverPresentationController *)popoverPresentationController
{
        [self searchLyricsIfPlaying]; //uncomment after screenshot taking
//    [self searchLyricsHelperWithArtistTitle:@"U2 Song for Someone"]; //remove after screenshot taking
}
#pragma mark - UI story board
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"popoverPresent"])
    {
        if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            ILSettingsMasterTableViewController *smtvc =  segue.destinationViewController;
            smtvc.vc = self;
            smtvc.modalPresentationStyle = UIModalPresentationPopover;
            UIPopoverPresentationController *popoverPresentationController = smtvc.popoverPresentationController;
            popoverPresentationController.delegate = self;
        }
        else if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            UINavigationController* nc =  segue.destinationViewController;
            ILSettingsMasterTableViewController *smtvc = (ILSettingsMasterTableViewController *)
            [nc visibleViewController];
            smtvc.vc = self;
        }
    }
    
    
}



@end
