//
//  MenuTableViewController.m
//  V2EX
//
//  Created by St.Jimmy on 7/9/15.
//  Copyright (c) 2015 Xing He. All rights reserved.
//

#import "MenuTableViewController.h"
#import "SWRevealViewController.h"
#import "ViewController.h"

@interface MenuTableViewController ()

@end

@implementation MenuTableViewController

{
    NSArray *menuItems;
    NSArray *titleNames;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    menuItems = @[@"title", @"tech", @"creative", @"play", @"apple", @"jobs", @"deals", @"city", @"qna", @"hot", @"all", @"r2"];
    
    titleNames = @[@"分类", @"技术", @"创意", @"好玩", @"Apple", @"酷工作", @"交易", @"城市", @"问与答", @"最热", @"全部", @" R2"];
    
    self.tableView.backgroundColor = [UIColor colorWithRed:0.82 green:0.82 blue:0.81 alpha:1];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.revealViewController.frontViewController.view setUserInteractionEnabled:NO];
    [self.revealViewController.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    [self.revealViewController.navigationController.view addGestureRecognizer:self.revealViewController.tapGestureRecognizer];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.revealViewController.frontViewController.view setUserInteractionEnabled:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return menuItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = [menuItems objectAtIndex:indexPath.row];
    UITableView *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.backgroundColor = [UIColor colorWithRed:0.82 green:0.82 blue:0.81 alpha:1];
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Transfer the title name to the ViewController;
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    UINavigationController *destViewController = segue.destinationViewController;
    ViewController *showTitleViewController = [destViewController childViewControllers].firstObject;
    NSString *title = [NSString stringWithFormat:@"%@", [titleNames objectAtIndex:indexPath.row]];
    showTitleViewController.naviTitleName = title;
    
    // Transfer the tab item if it navigates to the ViewController
    if ([segue.identifier isEqualToString:@"showTitle"]) {
        UINavigationController *navController = segue.destinationViewController;
        ViewController *titleViewController = [navController childViewControllers].firstObject;
        NSString *titleName = [NSString stringWithFormat:@"%@", [menuItems objectAtIndex:indexPath.row]];
        titleViewController.tabName = titleName;
    }
}


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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
