//
//  ILSettingsDetailTableViewController.h
//  
//
//  Created by Tom Lai on 7/1/15.
//
//

#import <UIKit/UIKit.h>
@class ViewController;
@interface ILSettingsDetailTableViewController : UITableViewController <UITableViewDataSource>
@property (strong, nonatomic) ViewController *vc;
-(void) setSourceSegue:(UIStoryboardSegue *)aSourceSegue;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
@end
