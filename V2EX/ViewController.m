//
//  ViewController.m
//  V2EX
//
//  Created by St.Jimmy on 5/12/15.
//  Copyright (c) 2015 Xing He. All rights reserved.
//

#import "ViewController.h"
#import "AllTableViewCell.h"
#import "ContentTableViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "Reachability.h"
#import "SWRevealViewController.h"
#import "TFHpple.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "LoginViewController.h"
#import "V2UserModel.h"
#import "NetworkManager.h"
#import "SJBannerAlertView.h"

@interface ViewController () <UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UILabel *itemLabel;
@property (nonatomic, copy) NSDictionary *toContent;
@property (nonatomic, retain) UIView *bannerView;

@end

@implementation ViewController
@synthesize item;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self pullToRefresh];
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    // Start pull to refresh automatically.
    [self.refreshControl beginRefreshing];
    CGPoint newOffset = CGPointMake(0, - 60);
    [self.tableView setContentOffset:newOffset animated:YES];
    [self getLatestTitle];
    
    // Set the self-sizing UITableViewCell
    self.tableView.estimatedRowHeight = 71.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.26 green:0.26 blue:0.25 alpha:1];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor colorWithRed:0.26 green:0.26 blue:0.25 alpha:1]}];
    self.tableView.backgroundColor = [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Set the navigation item title name;
    self.navigationItem.title = self.naviTitleName;
    if (!self.naviTitleName) {
        self.navigationItem.title = @"全部";
    }
    
    SWRevealViewController *revealViewController = self.revealViewController;
    if (revealViewController) {
        [self.sidebarButton setTarget: self.revealViewController];
        [self.sidebarButton setAction: @selector(revealToggle:)];
        [self.tableView addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    
    NSLog(@"SELF AVATAR IS: %@", [NetworkManager manager].user.member.memberAvatarLarge);
    NSURL *avatURL = [NSURL URLWithString:[NetworkManager manager].user.member.memberAvatarLarge];
    [self.selfAvatar setImageWithURL:avatURL placeholderImage:[UIImage imageNamed:@"avatarPlaceholder"]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    // Deselect the cell after it segue to the next VC
    NSIndexPath *tableSelection = [self.tableView indexPathForSelectedRow];
    [self.tableView deselectRowAtIndexPath:tableSelection animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)pullToRefresh
{
    // Initialize the refresh control
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1];
    self.refreshControl.tintColor= [UIColor lightGrayColor];
    [self.refreshControl addTarget:self
                            action:@selector(getLatestTitle)
                  forControlEvents:UIControlEventValueChanged];
}

- (void)showConnectionAlertView
{
    self.bannerView = [SJBannerAlertView showBannerAlertViewWithMessage:@"无网络连接，请稍候重试" backgroundColor:[UIColor redColor] alpha:0.9f onTargetView:self.navigationController.navigationBar withViewController:self];
    
    // Create the ending frame or where you want it to end up on screen, in this case 0 y origin
    CGRect newFrm = self.bannerView.frame;
//    newFrm.origin.y = self.navigationController.navigationBar.frame.size.height;
    newFrm.origin.y = 64;
    self.bannerView.alpha = 0.0f;
    self.bannerView.frame = newFrm;
    newFrm.size.height = 25;
    
    UILabel *label1;
    for (UILabel *label in self.bannerView.subviews) {
        label1 = label;
    }
    CGRect labelFrame = label1.frame;
    labelFrame.size.height = 0;
    label1.frame = labelFrame;
    labelFrame.size.height = 25;
    
    // Animate it in
    [UIView animateWithDuration:0.4f animations:^{
        //        self.bannerView.frame = newFrm;
        self.bannerView.frame = newFrm;
        label1.frame = labelFrame;
        self.bannerView.alpha = 0.9f;
    }];
    
    [self performSelector:@selector(dismissViewController:) withObject:self.bannerView afterDelay:3.0f];
    
}

- (void)dismissViewController:(UIView *)view
{
//    CGRect newFrm = view.frame;
//    newFrm.origin.y = 0;
//    
//    [UIView animateWithDuration:0.4f animations:^{
//        view.frame = newFrm;
//    } completion:^(BOOL finished){
//        [view removeFromSuperview];
//    }];
    
    UILabel *label1;
    for (UILabel *label in view.subviews) {
        label1 = label;
    }
    [UIView animateWithDuration:0.4f
                     animations:^{
                         CGRect frame = view.frame;
                         CGRect frame2 = label1.frame;
                         frame.size.height = 0;
                         frame2.size.height = 0;
                         view.frame = frame;
                         label1.frame = frame2;
                     }
                     completion:^(BOOL finished){
                         [view removeFromSuperview];
                     }];
}

- (void)getLatestTitle
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
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
    
        NSMutableArray *titleArray = [[NSMutableArray alloc] init];
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
    
        NSString *userAgent = @"Mozilla/5.0 (iPhone; CPU iPhone OS 9_3 like Mac OS X) AppleWebKit/601.1.46(KHTML, like Gecko) Version/9.0 Mobile/13E188a Safari/601.1";
        NSURL *tabURL = [NSURL URLWithString:URLString];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:tabURL];
        [request setValue:userAgent forHTTPHeaderField:@"User-Agent"];
        
        NSURLResponse *response = nil;
        NSError *error = nil;
        NSData *tabHTMLData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
    
        // 2
        TFHpple *tabParser = [TFHpple hppleWithHTMLData:tabHTMLData];
        
        // 3 Tile list
        NSString *cellXPathQueryString = @"//div[@class='cell item']";
        NSArray *cellNodes = [tabParser searchWithXPathQuery:cellXPathQueryString];
    
        

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
            NSString *usernameXPathQueryString = @"//span[@class='small fade'][1]/strong[1]/a";
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
            NSString *replyDateXPathQueryString = @"//span[@class='small fade'][2]";
            NSArray *replyDateNodes = [element searchWithXPathQuery:replyDateXPathQueryString];
            for (TFHppleElement *element6 in replyDateNodes) {
                NSString *dateDataString = [element6 content];
                NSArray *dateArray = [dateDataString componentsSeparatedByString:@"  •  "];
                if (dateArray.count > 2) {
                    date_data = dateArray[2];
                } else {
                    date_data = dateArray.firstObject;
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
            [titleArray addObject:self.dictionary];
            
            if (titleArray) {
                self.myObject = [[NSMutableArray alloc] init];
                self.myObject = titleArray;
            }
        }

        if (self.refreshControl) {
            dispatch_async(dispatch_get_main_queue(), ^{
                    
                Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
                NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
                    
                if (networkStatus == NotReachable) {
                        
//                    [SJBannerAlertView showBannerAlertViewWithMessage:@"无网络连接，请稍候重试" backgroundColor:[UIColor redColor] alpha:0.9f onTargetView:self.navigationController.view];
                    
                    [self showConnectionAlertView];
                }
                    
                else if (!tabHTMLData) {
                        
//                    [SJBannerAlertView showBannerAlertViewWithMessage:@"无网络连接，请稍候重试" backgroundColor:[UIColor redColor] alpha:0.9f onTargetView:self.navigationController.view];
                    
                    [self showConnectionAlertView];
                        
                }
                
                [self.tableView reloadData];
                [self.refreshControl endRefreshing];
            });
        }
    });
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.myObject count];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"contentSegue"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        ContentTableViewController *dvc = segue.destinationViewController;
        dvc.contentAssets = [self.myObject objectAtIndex:indexPath.row];
        dvc.exchangeID = self.navigationItem.title;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [tableView fd_heightForCellWithIdentifier:@"AllTableViewCell" cacheByIndexPath:indexPath configuration:^(AllTableViewCell *cell) {
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
        cell.nodeLabel.backgroundColor = [UIColor colorWithRed:(230/255.f) green:(230/255.f) blue:(230/255.f) alpha:1.0f];
        cell.borderView.layer.cornerRadius = 2.0;
        cell.borderView.layer.masksToBounds = YES;
        cell.borderView.backgroundColor = [UIColor colorWithRed:(230/255.f) green:(230/255.f) blue:(230/255.f) alpha:1.0f];
        cell.nodeLabel.text = textNode;
        
        // Settings of the usernameLabel
        cell.usernameLabel.text = textUsername;
        
        // Settings of the timeLabel;
        cell.timeLabel.text = readableTime;
        
        // Settings of the repliesLabel;
        cell.repliesLabel.text = textReplies;
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"AllTableViewCell";
    
    AllTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
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
    [cell.IDImageView setImageWithURL:url placeholderImage:[UIImage imageNamed:@"avatarPlaceholder"]];
        
    
    // Settings of the titleLabel
    cell.titleLabel.text = textTitle;
    cell.titleLabel.preferredMaxLayoutWidth = cell.titleLabel.bounds.size.width;
    
    // Settings of the nodeLabel
    cell.nodeLabel.text = textNode;
    
    // Settings of the usernameLabel
    cell.usernameLabel.text = textUsername;
    
    // Settings of the timeLabel;
    cell.timeLabel.text = readableTime;
    
    // Settings of the repliesLabel;
    cell.repliesLabel.text = textReplies;
    
    cell.backgroundColor = [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1];
    
    return cell;
}

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    CGRect frame = self.bannerView.frame;
//    frame.origin.y = self.tableView.contentOffset.y + 64;
//    self.bannerView.frame = frame;
//    
//    [self.view bringSubviewToFront:self.bannerView];
//}


- (IBAction)signInButton:(id)sender
{
    BOOL isLogin = [[[NSUserDefaults standardUserDefaults] objectForKey:@"userIsLogin"] boolValue];
    
    if (isLogin) {
        
        UIActionSheet * sheet = [[UIActionSheet alloc] initWithTitle:@"您是否需要注销账户？"
                                                            delegate:self
                                                   cancelButtonTitle:@"取消"
                                              destructiveButtonTitle:@"注销账号"
                                                   otherButtonTitles:nil,nil];
        
        [sheet showInView:self.view];
        

    } else {
        
        if ([UIApplication sharedApplication].delegate.window.rootViewController.presentedViewController == nil) {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
            [[UIApplication sharedApplication].delegate.window.rootViewController presentViewController:loginViewController animated:YES completion:nil];
        }
        
//        [self presentViewController:self.loginViewController animated:YES completion:nil];
        
    }
    
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"userIsLogin"];
        
        NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        for (NSHTTPCookie *cookie in [storage cookies]) {
            [storage deleteCookie:cookie];
        }
        
        NSURL *avatURL = [NSURL URLWithString:[NetworkManager manager].user.member.memberAvatarLarge];
        [self.selfAvatar setImageWithURL:avatURL placeholderImage:[UIImage imageNamed:@"avatarPlaceholder"]];
        
    }
}

- (IBAction)sidebarButton:(UIBarButtonItem *)sender {
}
@end
