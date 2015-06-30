//
//  ViewController.m
//  Instant Lyrics
//
//  Created by Tom Lai on 6/21/15.
//  Copyright © 2015 Tsz Chun Lai. All rights reserved.
//

#import "ViewController.h"
#import "ILURLMap.h"
#import "LyricsURL.h"

@import MediaPlayer;
@interface ViewController () <UIWebViewDelegate, UIGestureRecognizerDelegate, UIAlertViewDelegate, UISearchBarDelegate, NJKWebViewProgressDelegate>
@property (strong, nonatomic) ILURLMap *urlmap;
@property (strong, nonatomic) MPMusicPlayerController *MPcontroller;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
//@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
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
    self.urlmap = [[ILURLMap alloc] init];
//    self.searchBar.searchBarStyle = UISearchBarStyleMinimal;
//    self.searchBar.translucent = YES;
//    self.searchBar.delegate=self;
    self.progressView.backgroundColor = [UIColor clearColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [[self progressView] setAlpha:0];
    [[self progressView] setProgress:0];

    [self searchLyrics];
    [self updateBackForwardButtons];

}

- (void)searchLyrics
{
    [self searchLyricsWithOptions: SEARCH_OPTIONAL];

}
- (void)searchLyricsWithOptions:(searchOptions)options {
    MPMediaItem *mediaItem = [_MPcontroller nowPlayingItem];
    LyricsURL* lastEntry = [self.urlmap lastEntry];
    if ([_MPcontroller playbackState] != MPMusicPlaybackStatePlaying)
    {
        if (lastEntry) [self loadURL:lastEntry.url];
        return;
    }
    else {
        NSMutableString* artistTitle = [[NSMutableString alloc] init];

        NSString* artist = [mediaItem valueForKey:MPMediaItemPropertyArtist];
        NSString* title = [mediaItem valueForKey:MPMediaItemPropertyTitle];
        if (artist) [artistTitle appendString:artist];
        if (artist && title) [artistTitle appendString:@" "];
        if (title) [artistTitle appendString:title];
        
//        This entry is same as the last, so don't search
        if (options == SEARCH_OPTIONAL &&
            [lastEntry.artistTitle isEqualToString: artistTitle])
        {
            return;
        }
        [self searchLyricsHelperWithArtistTitle:artistTitle];
    }

}
- (void)searchLyricsHelperWithArtistTitle:(NSString*) at
{
    NSMutableString* query = [at mutableCopy];
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
    [[self urlmap]addURL:url forArtistTitle:at];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

#pragma mark - search bar
//- (void)searchBarTextDidBeginEditing:(nonnull UISearchBar *)searchBar
//{
//}
//- (void)searchBarSearchButtonClicked:(nonnull UISearchBar *)searchBar
//{
//    self.artistTitle = [NSMutableString stringWithFormat:@"%@",searchBar.text];
//    self.searchBar.text = self.artistTitle;
//    [self searchLyricsHelper];
//    searchBar.text = @"";
//    [searchBar resignFirstResponder];
//
//}
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

#pragma mark - state restoration
+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(nonnull NSArray *)path coder:(nonnull NSCoder *)coder
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    return [[self alloc]init];
}

- (void)encodeRestorableStateWithCoder:(nonnull NSCoder *)coder
{
//    [coder encodeObject:self.item.itemKey
//                 forKey:@"item.itemKey"];
//
//    // Save changes into item
//    self.item.itemName = self.nameField.text;
//    self.item.serialNumber = self.serialNumberField.text;
//    self.item.valueInDollars = [self.valueField.text intValue];
//
//    // Have store save changes to disk
//    [[BNRItemStore sharedStore] saveChanges];
        NSLog(@"%@", NSStringFromSelector(_cmd));

    [super encodeRestorableStateWithCoder:coder];
}

- (void)decodeRestorableStateWithCoder:(nonnull NSCoder *)coder
{
//    NSString *itemKey = [coder decodeObjectForKey:@"item.itemKey"];
//
//    for (BNRItem *item in [[BNRItemStore sharedStore] allItems]) {
//        if ([itemKey isEqualToString:item.itemKey]) {
//            self.item = item;
//            break;
//        }
//    }
        NSLog(@"%@", NSStringFromSelector(_cmd));
    [super decodeRestorableStateWithCoder:coder];
}

#pragma mark - NJKWebViewProgressDelegate
-(void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    [_progressView setProgress:progress animated:NO];
}
@end
