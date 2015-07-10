//
//  ILWelcomeViewController.m
//  Instant Lyrics
//
//  Created by Tom Lai on 7/1/15.
//  Copyright (c) 2015 Tom. All rights reserved.
//

#import "ILWelcomeViewController.h"
@import MediaPlayer;
@interface ILWelcomeViewController ()
@property (weak, nonatomic) IBOutlet UIButton *playMusicButton;
@property (weak, nonatomic) IBOutlet UIButton *goToMusicApp;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@end

@implementation ILWelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _playMusicButton.hidden = NO;
    _goToMusicApp.hidden = YES;
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)playButtonPressed:(id)sender {
    [[MPMusicPlayerController systemMusicPlayer]play];
    if ([[MPMusicPlayerController systemMusicPlayer]playbackState]==MPMusicPlaybackStatePlaying)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        [_playMusicButton setSelected:NO];
        [_playMusicButton setHidden:YES];
        [_goToMusicApp setHidden:NO];
    }
}
- (IBAction)goToMusicAppButtonPressed:(id)sender {
    BOOL success = [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"music:"]];
    if (success)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        _messageLabel.text = @"This device have no music app.\nInstant Lyrics needs iOS music\napp to function.";
        
        _messageLabel.numberOfLines = 3;
        
        CGSize labelSize = [_messageLabel.text sizeWithAttributes:@{NSFontAttributeName:_messageLabel.font}];
        
        CGRect newFrame = _messageLabel.frame;
        newFrame.size = labelSize;
        _messageLabel.frame = newFrame;
        
        [_goToMusicApp setHidden:YES];
    }
}

@end
