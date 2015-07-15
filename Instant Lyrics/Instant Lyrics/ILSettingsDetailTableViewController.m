//
//  ILSettingsDetailTableViewController.m
//  
//
//  Created by Tom Lai on 7/1/15.
//
//

#import "ILSettingsDetailTableViewController.h"
#import "AppDelegate.h"
#import "ViewController.h"
#import "ILURLEntry.h"
#import "ILURLLog.h"
#import <UALogger.h>
@interface ILSettingsDetailTableViewController ()
@property NSMutableArray * tableDataSource;
@property (strong, nonatomic) UIStoryboardSegue *sourceSegue;
@property (strong, nonatomic) NSUserDefaults *defaults;

@end

@implementation ILSettingsDetailTableViewController
@synthesize sourceSegue,vc=_vc;
//- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self)
//    {
//        self.restorationIdentifier = NSStringFromClass([self class]);
//        self.restorationClass = [self class];
//    }
//    return  self;
//}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _defaults = [NSUserDefaults standardUserDefaults];

    if ([sourceSegue.identifier isEqualToString:@"SearchTermSegue"])
    {
        _tableDataSource = [_defaults objectForKey:ILPrependOptionsKey];
        self.navigationItem.title = @"Set Search Term";
    }
    else //if ([sourceSegue.identifier isEqualToString:@"SearchEngineSegue"])
    {
        _tableDataSource = [_defaults objectForKey:ILSearchEngineOptionsKey];
        self.navigationItem.title = @"Search Engine";
    }

    
    [[self tableView]registerClass:[UITableViewCell class]forCellReuseIdentifier:@"UITableCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [_tableDataSource count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableCell" forIndexPath:indexPath];
    
    
    cell.textLabel.text = _tableDataSource[indexPath.row];
    
    if ([sourceSegue.identifier isEqualToString:@"SearchTermSegue"])
    {
        // add the artist title to the text if currently playing
        // if not, use last artist title
        NSString* artistTitle;
        if (![_vc currentArtistTitle:&artistTitle])
        {
            // add last artist title
            ILURLEntry * last = [[ILURLLog sharedLog]lastEntry];
            artistTitle = last? last.artistTitle : @"";
        }
        NSString *potentialSpace = [cell.textLabel.text length]==0? @"":@" ";
        cell.textLabel.text =
        [NSString stringWithFormat:@"%@%@%@",cell.textLabel.text, potentialSpace, artistTitle];

        if ([_tableDataSource[indexPath.row]
             isEqualToString:[_defaults objectForKey:ILPrependPrefsKey]])
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    else if ([sourceSegue.identifier isEqualToString:@"SearchEngineSegue"] &&
             [cell.textLabel.text isEqualToString:[_defaults objectForKey:ILSearchEnginePrefsKey]])
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    return cell;
    
}
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *selectedCell = [self.tableView cellForRowAtIndexPath:indexPath];
    [self clearTableCellViewCheckmarks];
    selectedCell.accessoryType = UITableViewCellAccessoryCheckmark;
    NSString * newValue = _tableDataSource[indexPath.row];
    // Is it changed?
    if ([sourceSegue.identifier isEqualToString:@"SearchTermSegue"] &&
        ![newValue isEqualToString:[_defaults objectForKey:ILPrependPrefsKey]])
    {
        // Save to defaults
        [_defaults setObject:newValue forKey:ILPrependPrefsKey];
    }
    else if ([sourceSegue.identifier isEqualToString:@"SearchEngineSegue"] &&
              ![newValue isEqualToString:[_defaults objectForKey:ILSearchEnginePrefsKey]])
    {
        // Save to defaults
        [_defaults setObject:newValue forKey:ILSearchEnginePrefsKey];
    }

    
}

- (NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if ([sourceSegue.identifier isEqualToString:@"SearchTermSegue"])
    {
        return @"The query format is: <prepend text> <artist> <title>. \n\
Depending on the language of songs you listen to and the search engine you choose, different prepend text may produce better search results.";
    }
    else // if ([sourceSegue.identifier isEqualToString:@"SearchEngineSegue"])
    {
        return @"Instant Lyrics will look up lyrics using the selected search engine. \n";
    }
}

- (void)clearTableCellViewCheckmarks
{
    for (int i = 0 ; i < [_tableDataSource count]; i++){
        
        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        UITableViewCell * aCell = [self.tableView cellForRowAtIndexPath:indexPath];
        aCell.accessoryType = UITableViewCellAccessoryNone;
    }
}
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

#pragma mark - state restoration
+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(nonnull NSArray *)path coder:(nonnull NSCoder *)coder
{
    UALog(@"%@", NSStringFromSelector(_cmd));
    ILSettingsDetailTableViewController *vc = nil;
    UIStoryboard *storyboard = [coder decodeObjectForKey: UIStateRestorationViewControllerStoryboardKey];
    if (storyboard)
    {
        vc = (ILSettingsDetailTableViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ILSettingsDetailTableViewController"];
        
        vc.restorationIdentifier = [path lastObject];
        vc.restorationClass = [self class];
    }
    return [[self alloc]init];
}


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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
@end
