//
//  ILSettingsTableViewController.m
//  Instant Lyrics
//
//  Created by Tom Lai on 6/30/15.
//  Copyright © 2015 Tom. All rights reserved.
//

#import "ILSettingsMasterTableViewController.h"
#import "ILSettingsDetailTableViewController.h"
#import "AppDelegate.h"
#import <UALogger.h>
#import "ViewController.h"
#import "ILURLLog.h"
#import "ILURLEntry.h"
@interface ILSettingsMasterTableViewController ()


// consider subclassing UITableCell later
//@property (weak, nonatomic) IBOutlet UILabel *nomusicplayingLabel;
//@property (weak, nonatomic) IBOutlet UISwitch *nomusicPlayingScreenSwitch;

@property (strong, nonatomic) UISwitch *messageSwitch;
@end
@implementation ILSettingsMasterTableViewController
@synthesize vc=_vc;
- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        UIBarButtonItem * done = [[UIBarButtonItem alloc]
                                  initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                  target:self
                                  action:@selector(doneButtonPressed)];
        self.navigationItem.rightBarButtonItem = done;
    }
    
    // tell tableview to not display empty cells in the bottom
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    
    

    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    

}
- (void)viewWillAppear:(BOOL)animated
{
    [[self tableView]reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section==0)
        return @"Search";
    else
        return @"On App Launch";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0)
        return 2;
    else
        return 1;
}

// TODO: This is ugly. refactor later
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    switch (indexPath.section) {
        case 0: // section 0
        {

            // Set title & subtitle
            switch (indexPath.row) {
                case 0:
                {
                    cell = [tableView dequeueReusableCellWithIdentifier:@"searchTerm"
                                                           forIndexPath:indexPath];
                    cell.textLabel.text = @"Search Term";
                    NSString* prependText = [defaults objectForKey:ILPrependPrefsKey];
                    NSString* artistTitle;
                    
                    // use current artist title if exists
                    // use last artist title if not
                    if (![_vc currentArtistTitle:&artistTitle])
                    {
                        ILURLEntry * last = [[ILURLLog sharedLog]lastEntry];
                        artistTitle = last? last.artistTitle : @"";
                    }
                    NSString *potentialSpace = [prependText length]==0? @"":@" ";
                    cell.detailTextLabel.text  =
                    [NSString stringWithFormat:@"%@%@%@",prependText, potentialSpace, artistTitle];
                    break;
                }
                case 1:
                {
                    cell = [tableView dequeueReusableCellWithIdentifier:@"searchEngine"
                                                           forIndexPath:indexPath];
                    cell.textLabel.text = @"Search Engine";
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    NSString* searchEngine = [defaults objectForKey:ILSearchEnginePrefsKey];
                    
                    cell.detailTextLabel.text = searchEngine;
                    break;
                }
                default:
                    break;
            }

            break;
        }
        case 1: // section 1
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"toggleCell"
                                                   forIndexPath:indexPath];
            
            switch (indexPath.row) {
                case 0:
                {
                    //consider making a custom view class
                    self.messageSwitch = (UISwitch *) [cell viewWithTag:121];
                    cell.textLabel.text = @"\"No Music Playing\" Screen";
                    cell.textLabel.backgroundColor = [UIColor clearColor];
                    self.messageSwitch.on = [defaults boolForKey:ILNoMusicPlayingScreenToggleKey
                                  ];
                    
                    // Add control event
                    [self.messageSwitch addTarget:self
                                           action:@selector(messageSwitchFlipped:)
                                 forControlEvents:UIControlEventValueChanged];
                    
                }
                    break;
                    
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
    // Configure the cell...
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1)
    {
        [[tableView cellForRowAtIndexPath:indexPath]setSelected:NO animated:YES];
    }
}
//- (NSString *)tableView:(nonnull UITableView *)tableView titleForFooterInSection:(NSInteger)section
//{
//    if (section == 0) return @"Prepend Text is inserted in front of every query";
//    else return @"Default search engine for Instant Lyrics";
//}

//- (CGFloat)tableView:(nonnull UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return 20;
//}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    ILSettingsDetailTableViewController* sdtvc = (ILSettingsDetailTableViewController *)
    [segue destinationViewController];
    [sdtvc setSourceSegue:segue];
    sdtvc.vc = _vc;
    
}
- (void)doneButtonPressed
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark control event
- (void)messageSwitchFlipped:(UISwitch *)aSwitch
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setBool:aSwitch.on forKey:ILNoMusicPlayingScreenToggleKey];
    
}
@end
