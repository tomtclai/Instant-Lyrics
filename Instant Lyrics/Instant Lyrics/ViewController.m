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
@property (strong, nonatomic) MPMusicPlayerController *MPcontroller;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *forwardButton;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (strong, nonatomic) NSMutableString *artistTitle;
@property (strong, nonatomic) NSURL *lastURL;
@property (strong, nonatomic) NSString *lastArtistTitle;
@end
NSString *const searchbarPlaceholder = @"Search Lyrics";
@implementation ViewController

#pragma mark - UIView
- (void)viewDidLoad {
    self.MPcontroller = [[MPMusicPlayerController alloc] init];
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
    
    [self.MPcontroller beginGeneratingPlaybackNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(searchLyrics)
                                                 name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(searchLyrics)
                                                 name:MPMusicPlayerControllerPlaybackStateDidChangeNotification
                                               object:nil];
    self.artistTitle = [[NSMutableString alloc]init];
    self.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    self.searchBar.translucent = YES;
    self.searchBar.delegate=self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [[self progressView] setAlpha:0];
    [[self progressView] setProgress:0];
    
    [self searchLyricsWithOptions:SEARCH_OPTIONAL];
    [self updateBackForwardButtons];
}

- (void)searchLyrics
{
    [self searchLyricsWithOptions: SEARCH_OPTIONAL];
}
- (void)searchLyricsWithOptions:(searchOptions)options {
    MPMediaItem *mediaItem = [_MPcontroller nowPlayingItem];
    if ([_MPcontroller playbackState] != MPMusicPlaybackStatePlaying)
    {
        self.searchBar.placeholder = searchbarPlaceholder;
        if (self.lastURL) [self loadURL:self.lastURL];
        return;
    }
    else {
        NSString* artist = [mediaItem valueForKey:MPMediaItemPropertyArtist];
        NSString* title = [mediaItem valueForKey:MPMediaItemPropertyTitle];
        if (artist) [self.artistTitle appendString:artist];
        if (artist && title) [self.artistTitle appendString:@" "];
        if (title) [self.artistTitle appendString:title];
        //This query is same as last query, so don't search
        if (options == SEARCH_OPTIONAL &&
            [self.lastArtistTitle isEqualToString: self.artistTitle])
        {
            return;
        }
        

        [self searchLyricsHelper];
    }
}
- (void)searchLyricsHelper
{
    NSMutableString* query = [self.artistTitle mutableCopy];
    if (![query containsString:@"Lyrics"] && ![query containsString:@"lyrics"])
    {
        query = [NSMutableString stringWithFormat:@"Lyrics %@",query];
    };
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
    [self loadURL:url];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)loadURL: (NSURL*) url
{
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
    self.lastArtistTitle = self.artistTitle;
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
    [self searchLyricsWithOptions:SEARCH_FORCED];
}

#pragma mark - action button
-(IBAction)actionButtonPressed:(id)sender {
    
    NSLog(@"shareButton pressed");
    
    [[UIApplication sharedApplication] openURL:self.webView.request.URL];
}

#pragma mark - search button
//-(IBAction)manualSearch:(id)sender
//{
//    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Manual Search"
//                                                     message:@"Enter artist and title here"
//                                                    delegate:self
//                                           cancelButtonTitle:@"Hide"
//                                           otherButtonTitles:@"Search",nil];
//    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
//
//    [alert show];
//}

-(void)alertView:(nonnull UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        self.artistTitle = [NSMutableString stringWithFormat:@"%@",[alertView textFieldAtIndex:0].text];
        [self searchLyricsHelper];
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
}
- (void)searchBarSearchButtonClicked:(nonnull UISearchBar *)searchBar
{
    self.artistTitle = [NSMutableString stringWithFormat:@"%@",searchBar.text];
    self.searchBar.text = self.artistTitle;
    [self searchLyricsHelper];
    searchBar.text = @"";
    [searchBar resignFirstResponder];

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
    [_MPcontroller endGeneratingPlaybackNotifications];
}
@end
