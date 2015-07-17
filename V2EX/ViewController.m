//
//  ViewController.m
//  V2EX
//
//  Created by St.Jimmy on 5/12/15.
//  Copyright (c) 2015 Xing He. All rights reserved.
//

#import "ViewController.h"
#import "AllTableViewCell.h"
#import "contentTableViewController.h"
#import "contentTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "Reachability.h"
#import "SWRevealViewController.h"
#import "TFHpple.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *itemLabel;
@property (nonatomic, strong) NSDictionary *toContent;

@end

@implementation ViewController
@synthesize item;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self pullToRefresh];
    
    // Start pull to refresh automatically.
    [self.refreshControl beginRefreshing];
    CGPoint newOffset = CGPointMake(0, - 60);
    [self.tableView setContentOffset:newOffset animated:YES];
    [self performSelector:@selector(getLatestTitle) withObject:nil afterDelay:2.0];

    [self getLatestTitle];
    
    // Set the navigation item title name;
    self.navigationItem.title = self.naviTitleName;
    
    // Set the self-sizing UITableViewCell
    self.tableView.estimatedRowHeight = 71.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    SWRevealViewController *revealViewController = self.revealViewController;
    if (revealViewController) {
        [self.sidebarButton setTarget: self.revealViewController];
        [self.sidebarButton setAction: @selector(revealToggle:)];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)pullToRefresh
{
    // Initialize the refresh control
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor whiteColor];
    self.refreshControl.tintColor= [UIColor lightGrayColor];
    [self.refreshControl addTarget:self
                            action:@selector(getLatestTitle)
                  forControlEvents:UIControlEventValueChanged];
}

- (void)getLatestTitle
{
    self.item = @"title";
    self.memAvatar = @"memAvatar";
    self.node = @"node";
    self.username = @"username";
    self.lastDate = @"lastDate";
    self.replies = @"replies";
    self.date = @"date";
    self.content = @"content";
    self.titleID = @"titleID";
    self.URLID = @"URLID";
    
    self.myObject = [[NSMutableArray alloc] init];
    NSString *item_data;
    NSString *username_data;
    NSString *node_data;
    NSString *reply_data;
    NSString *date_data;
    NSString *avatar_data;
    NSString *titleURL_data;
    NSString *URLID_data;
    
    // 1
    NSString *URLString = [NSString stringWithFormat:@"https://www.v2ex.com/?tab=%@", self.tabName];
    
    if (!self.tabName) {
        URLString = @"https://www.v2ex.com/?tab=all";
    }
    
    NSURL *tabURL = [NSURL URLWithString:URLString];
    NSData *tabHTMLData = [NSData dataWithContentsOfURL:tabURL];
    
    // 2
    TFHpple *tabParser = [TFHpple hppleWithHTMLData:tabHTMLData];
    
    // 3 Tile list
    NSString *cellXPathQueryString = @"//div[@class='cell item']";
    NSArray *cellNodes = [tabParser searchWithXPathQuery:cellXPathQueryString];
    
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    
    if (networkStatus == NotReachable) {
        UIAlertView *networkAlert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                               message:@"No internet connection, please make sure you have connected to the internet."
                                                              delegate:nil
                                                     cancelButtonTitle:@"OK"
                                                     otherButtonTitles:nil, nil];
        [networkAlert show];
    }
    else {
        for (TFHppleElement *element in cellNodes) {
        
            // Get the lastest titles
            NSString *itemXPathQueryString = @"//span[@class='item_title']/a";
            NSArray *itemNodes = [element searchWithXPathQuery:itemXPathQueryString];
            for (TFHppleElement *element2 in itemNodes) {
                item_data = [[element2 firstChild] content];
                
                titleURL_data = [element2 objectForKey:@"href"];
                NSString *firstURLString;
                NSArray *URLArray = [titleURL_data componentsSeparatedByString:@"#"];
                if (URLArray.count > 1) {
                    firstURLString = URLArray[0];
                    
                    NSArray *firstURLArray = [firstURLString componentsSeparatedByString:@"/"];
                    if (firstURLArray.count > 2) {
                        URLID_data = firstURLArray[2];
                    }
                }
                
                NSLog(@"TITLE: %@", item_data);
                NSLog(@"TITLEURL: %@", titleURL_data);
                NSLog(@"URL ID: %@", URLID_data);
            }
            
            // Get the username lists
            NSString *usernameXPathQueryString = @"//span[@class='small fade']/strong[1]/a";
            NSArray *usernameNodes = [element searchWithXPathQuery:usernameXPathQueryString];
            for (TFHppleElement *element3 in usernameNodes) {
                username_data = [[element3 firstChild] content];
                NSLog(@"USERNAME: %@", username_data);
            }
            
            // Get the node lists
            NSString *nodeXPathQueryString = @"//a[@class='node']";
            NSArray *nodeNodes = [element searchWithXPathQuery:nodeXPathQueryString];
            for (TFHppleElement *element4 in nodeNodes) {
                node_data = [[element4 firstChild] content];
                NSLog(@"NODE: %@", node_data);
            }
            
            // Get the number of replies
            NSString *replyXPathQueryString = @"//a[@class='count_livid']";
            NSArray *replyNodes = [element searchWithXPathQuery:replyXPathQueryString];
            if (replyNodes.count == 0) {
                reply_data = @"0";
            }
            else {
                for (TFHppleElement *element5 in replyNodes) {
                    reply_data = [[element5 firstChild] content];
                    NSLog(@"REPLY: %@", reply_data);
                }
            }
            
            // Get the reply date;
            NSString *replyDateXPathQueryString = @"//span[@class='small fade']";
            NSArray *replyDateNodes = [element searchWithXPathQuery:replyDateXPathQueryString];
            for (TFHppleElement *element6 in replyDateNodes) {
                NSString *dateDataString = [element6 content];
                NSArray *dateArray = [dateDataString componentsSeparatedByString:@"  •  "];
                if (dateArray.count > 2) {
                    date_data = dateArray[2];
                } else {
                    date_data = [dateDataString stringByReplacingOccurrencesOfString:@"  •  (.*?)$" withString:@""];
                }
                NSLog(@"DATETEMPSTRING: %@", date_data);
            }
            
            // Get the avatar lists
            NSString *avatarXPathQueryString = @"//img[@class='avatar']";
            NSArray *avatarNodes = [element searchWithXPathQuery:avatarXPathQueryString];
            for (TFHppleElement *element7 in avatarNodes) {
                avatar_data = [NSString stringWithFormat:@"https:%@", [element7 objectForKey:@"src"]];
                
                NSLog(@"AVATAR: %@", avatar_data);
            }
            
            self.dictionary = [NSDictionary dictionaryWithObjectsAndKeys:item_data, self.item, username_data, self.username,
                                                                         node_data, self.node, reply_data, self.replies,
                                                                         date_data, self.date, avatar_data, self.memAvatar,
                                                                         titleURL_data, self.titleID, URLID_data, self.URLID, nil];
            [self.myObject addObject:self.dictionary];
        }
    }
    if (self.refreshControl) {
        [self.refreshControl endRefreshing];
        [self.tableView reloadData];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.myObject count];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"contentSegue"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        contentTableViewController *dvc = segue.destinationViewController;
        dvc.contentAssets = [self.myObject objectAtIndex:indexPath.row];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"AllTableViewCell";
    
    AllTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[AllTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary *tmpDict = [self.myObject objectAtIndex:indexPath.row];
    
    // Get the title's item
    NSMutableString *textTitle;
    textTitle = [tmpDict objectForKeyedSubscript:self.item];
    
    // Get the node's item
    NSMutableString *textNode;
    textNode = [tmpDict objectForKey:self.node];
    
    // Get the username's item
    NSMutableString *textUsername;
    textUsername = [tmpDict objectForKey:self.username];
    
    // Get and convert the last modified timestamp to NSDate
    NSMutableString *readableTime = [NSMutableString stringWithFormat:@"%@", [tmpDict objectForKey:self.date]];
    /*
    NSTimeInterval timestamp = (NSTimeInterval)timestampcvt;
    NSDate *updateTimestamp = [NSDate dateWithTimeIntervalSince1970:timestamp];
    
    // These codes can set the timezone to GMT
    // NSTimeZone *zone = [NSTimeZone systemTimeZone];
    // NSInteger interval = [zone secondsFromGMTForDate:updateTimestamp];
    // NSDate *localDate = [updateTimestamp dateByAddingTimeInterval:interval];

    
    NSDate *now = [NSDate date];
    NSTimeInterval sinceNow = [now timeIntervalSinceDate:updateTimestamp];

    int intervalTime;
    NSString *readableTime;
    if (sinceNow < 3600) {
        intervalTime = sinceNow / 60;
        readableTime = [NSString stringWithFormat:@"%im", intervalTime];
    }
    else if (sinceNow > 3600 && sinceNow < 86400) {
        intervalTime = sinceNow / 3600;
        readableTime = [NSString stringWithFormat:@"%ih", intervalTime];
    }
    else if (sinceNow >= 86400) {
        intervalTime = sinceNow / 86400;
        readableTime = [NSString stringWithFormat:@"%id", intervalTime];
    }
    */
    
    // Get the replies item and display a UIImage in the repliesLabel
    NSMutableString *textReplies;
    textReplies = [NSMutableString stringWithFormat:@"%@", [tmpDict objectForKey:self.replies]];
    
    
    // Asynchronously Settings of the IDImageView
    NSURL *url = [NSURL URLWithString:[tmpDict objectForKey:self.memAvatar]];
    [cell.IDImageView setImageWithURL:url];
    cell.IDImageView.layer.cornerRadius = 5.0;
    cell.IDImageView.layer.masksToBounds = YES;
        
    
    // Settings of the titleLabel
    cell.titleLabel.text = textTitle;
    cell.titleLabel.preferredMaxLayoutWidth = cell.titleLabel.bounds.size.width;
    
    // Settings of the nodeLabel
    cell.nodeLabel.layer.cornerRadius = 2.0;
    cell.nodeLabel.layer.masksToBounds = YES;
    cell.nodeLabel.text = textNode;
    
    // Settings of the usernameLabel
    cell.usernameLabel.text = textUsername;
    
    // Settings of the timeLabel;
    cell.timeLabel.text = readableTime;
    
    // Settings of the repliesLabel;
    cell.repliesLabel.text = textReplies;
    
    cell.layer.shouldRasterize = YES;
    cell.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    return cell;
}



- (IBAction)sidebarButton:(UIBarButtonItem *)sender {
}
@end
