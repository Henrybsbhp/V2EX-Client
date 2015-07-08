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
    
    // Set the self-sizing UITableViewCell
    self.tableView.estimatedRowHeight = 71.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
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
    self.createdDate = @"createdDate";
    self.content = @"content";
    self.titleID = @"titleID";
    
    self.myObject = [[NSMutableArray alloc] init];
    
    NSData *jsonSource = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"https://www.v2ex.com/api/topics/latest.json"]];
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
        id jsonObjects = [NSJSONSerialization JSONObjectWithData:jsonSource
                                                         options:NSJSONReadingMutableContainers
                                                           error:nil];
        for (NSDictionary *dataDict in jsonObjects) {
        
            // Get the lastest titles
            NSString *title_data = [dataDict objectForKey:@"title"];
        
            // Get the avatars of the members;
            NSDictionary *member = [dataDict objectForKey:@"member"];
            NSString *avatarURL = [member objectForKey:@"avatar_normal"];
            NSString *memAvatar_data = [NSString stringWithFormat:@"http:%@", avatarURL];
        
            // Get the nodes
            NSDictionary *nodes = [dataDict objectForKey:@"node"];
            NSString *node_data = [nodes objectForKey:@"title"];
        
            // Get the username
            NSString *username_data = [member objectForKey:@"username"];
        
            // Get the last modified date
            NSString *lastDate_data = [dataDict objectForKey:@"last_touched"];
            
            // Get the created date
            NSString *createdDate_data = [dataDict objectForKey:@"created"];
        
            // Get the replies
            NSString *replies_data = [dataDict objectForKey:@"replies"];
            
            // Get the content
            NSString *content_data = [dataDict objectForKey:@"content_rendered"];
            
            // Get the title ID
            NSNumber *titleIDNum = [dataDict objectForKey:@"id"];
            NSString *titleID_data = [NSString stringWithFormat:@"%@", titleIDNum];
            
        
            NSLog(@"TITLE: %@", title_data);
            NSLog(@"AVATAR: %@", memAvatar_data);
            NSLog(@"NODE: %@", node_data);
            NSLog(@"USERNAME: %@", username_data);
            NSLog(@"LASTDATE: %@", lastDate_data);
            NSLog(@"REPLIES: %@", replies_data);
            NSLog(@"TITLEID: %@", titleID_data);
        
            self.dictionary = [NSDictionary dictionaryWithObjectsAndKeys:title_data, self.item,
                          memAvatar_data, self.memAvatar,
                          node_data, self.node,
                          username_data, self.username,
                          lastDate_data, self.lastDate,
                          replies_data, self.replies,
                          createdDate_data, self.createdDate,
                          content_data, self.content,
                          titleID_data, self.titleID, nil];
        
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
    double timestampcvt = [[tmpDict objectForKey:self.lastDate] doubleValue];
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
    
    NSLog(@"%@", readableTime);
    
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



@end
