//
//  ViewController.m
//  Instant Lyrics
//
//  Created by Tom Lai on 6/21/15.
//  Copyright © 2015 Tom. All rights reserved.
//

#import "ViewController.h"
@import MediaPlayer;
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) MPMusicPlayerController *controller;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.controller = [[MPMusicPlayerController alloc] init];
    [self getNowPlayingInfo];
}

- (void)getNowPlayingInfo {
    MPMediaItem *mediaItem = [_controller nowPlayingItem];
    
    if (!mediaItem)
    {
        NSLog(@"No media is playing");
        return;
    }
    
    if ([mediaItem mediaType] == MPMediaTypeMusic)
    {
        
    } else if ([mediaItem mediaType] == MPMediaTypeMusicVideo)
    {
        
    } else if ([mediaItem mediaType] == MPMediaTypePodcast)
    {
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
