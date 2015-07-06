//
//  ILSettingsTableViewController.h
//  Instant Lyrics
//
//  Created by Tom Lai on 6/30/15.
//  Copyright © 2015 Tom. All rights reserved.
//
#import "ViewController.h"
#import <UIKit/UIKit.h>

@interface ILSettingsMasterTableViewController : UITableViewController <UITableViewDataSource>
@property (strong, nonatomic) ViewController *vc;
@end
