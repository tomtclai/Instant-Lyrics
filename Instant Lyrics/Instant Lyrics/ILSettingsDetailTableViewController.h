//
//  ILSettingsDetailTableViewController.h
//  
//
//  Created by Tom Lai on 7/1/15.
//
//

#import <UIKit/UIKit.h>
@class ViewController;
@interface ILSettingsDetailTableViewController : UITableViewController <UITableViewDataSource, UIViewControllerRestoration>
@property (strong, nonatomic) ViewController *vc;
@property (strong, nonatomic) NSString *sourceIdentifier;
@end
