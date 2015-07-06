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
#import "ViewController.h"
@interface ILSettingsMasterTableViewController ()

@end
@implementation ILSettingsMasterTableViewController
@synthesize vc=_vc;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        UIBarButtonItem * done = [[UIBarButtonItem alloc]
                                  initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                  target:self
                                  action:@selector(doneButtonPressed)];
        self.navigationItem.rightBarButtonItem = done;
    }

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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if (indexPath.section == 0)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"PrependText" forIndexPath:indexPath];

//        if (cell == nil) {
//            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"PrependText"];
//        }
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString* prependText = [defaults objectForKey:ILPrependPrefsKey];
        
        NSString* artistTitle;
        if ([_vc currentArtistTitle:&artistTitle])
        {
            NSString *potentialSpace = [cell.textLabel.text length]==0? @"":@" ";
            cell.detailTextLabel.text  =
            [NSString stringWithFormat:@"%@%@%@",prependText, potentialSpace, artistTitle];
        }
        else
        {
            cell.detailTextLabel.text = prependText;
        }
    }
    else
    {
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"SearchEngine" forIndexPath:indexPath];
//        if (cell == nil) {
//            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"SearchEngine"];
//        }
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString* searchEngine = [defaults objectForKey:ILSearchEnginePrefsKey];
        
        cell.detailTextLabel.text = searchEngine;
    }
    cell.editingAccessoryType = UITableViewCellAccessoryDetailButton;

    // Configure the cell...
    
//    [cell ]
    return cell;
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


@end
