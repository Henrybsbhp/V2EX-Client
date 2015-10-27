//
//  contentTableViewController.m
//  V2EX
//
//  Created by St.Jimmy on 5/24/15.
//  Copyright (c) 2015 Xing He. All rights reserved.
//

#import "ContentTableViewController.h"
#import "ContenHeaderView.h"
#import "RepliesTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "TFHpple.h"
#import "MyContentImageAttachment.h"
#import "MyReplyImageAttachment.h"
#import "SWRevealViewController.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "Reachability.h"
#import "SVWebViewControllerActivityChrome.h"
#import "SVWebViewControllerActivitySafari.h"
#import "SVWebViewControllerActivityCopyLink.h"
#import "SVWebViewController.h"

@interface ContentTableViewController ()
{
    // Replies item
    NSMutableArray *myReplyObject;
    NSDictionary *repDictionary;
    NSString *replyID;
    NSString *replyDate;
    NSString *replyContent;
    NSString *repAvatar;
    
    // Contents item
    NSDictionary *contDictionary;
    NSString *contentDate;
    NSString *topicContent;
    
    UIActivityIndicatorView *indicator;
    UIActivityIndicatorView *indicator2;
    ContenHeaderView *headerView;
}

@property (nonatomic, strong) NSMutableArray *myObject2;
@property (nonatomic, copy) NSDictionary *myContentObject;

@end

@implementation ContentTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    [self getContentHeaderView];
    
    if ([self.exchangeID isEqualToString:@"交易"]) {
        [self getContentTextViewSpecial];
    } else {
        [self getContentTextView];
    }
    
    self.automaticallyAdjustsScrollViewInsets = YES;
    
    self.tableView.estimatedRowHeight = 66.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    self.tableView.backgroundColor = [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.tableView.separatorStyle = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self check3DTouch];
    
    self.navigationItem.title = @"主题内容";

    
    // Start pull to refresh automatically.
    // [self.refreshControl beginRefreshing];
    // CGPoint newOffset = CGPointMake(0, - 60);
    // [self.tableView setContentOffset:newOffset animated:YES];
    [self.refreshControl endRefreshing];
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    // Disabel the panGesture in this view.
    self.revealViewController.panGestureRecognizer.enabled = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // enable the panGesture while leave this view.
    self.revealViewController.panGestureRecognizer.enabled = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)check3DTouch {
    
    // register for 3D Touch (if available)
    if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
        
        [self registerForPreviewingWithDelegate:(id)self sourceView:self.view];
        NSLog(@"3D Touch is available! Hurra!");
        
        // no need for our alternative anymore
        self.longPress.enabled = NO;
        
    } else {
        
        NSLog(@"3D Touch is not available on this device. Sniff!");
        
        // handle a 3D Touch alternative (long gesture recognizer)
        self.longPress.enabled = YES;
        
    }
}

- (void)pullToRefresh
{
    // Initialize the refresh control
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1];
    self.refreshControl.tintColor= [UIColor lightGrayColor];
    if ([self.exchangeID isEqualToString:@"交易"]) {
        [self.refreshControl addTarget:self
                                action:@selector(getContentTextViewSpecial)
                      forControlEvents:UIControlEventValueChanged];
    } else {
        [self.refreshControl addTarget:self
                                action:@selector(getContentTextView)
                      forControlEvents:UIControlEventValueChanged];
    }
}

- (void)showConnectionAlertView
{
    // Create a view to hold the label and add images or whatever, place it off screen at -100
    UIView *alertView = [[UIView alloc] initWithFrame:CGRectMake(0, -100, CGRectGetWidth(self.view.bounds), 25)];
    alertView.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.7f];
    
    // Create a label to display the message and add it to the alertView
    UILabel *theMessage = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(alertView.bounds), CGRectGetHeight(alertView.bounds))];
    theMessage.text = @"无网络连接，请稍候重试";
    theMessage.font = [UIFont systemFontOfSize:12];
    theMessage.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.0f];
    theMessage.textColor = [UIColor whiteColor];
    theMessage.textAlignment = NSTextAlignmentCenter;
    [alertView addSubview:theMessage];
    
    // Add the alertView to the view
    [self.view addSubview:alertView];
    
    // Create the ending frame or where you want it to end up on screen, in this case 0 y origin
    CGRect newFrm = alertView.frame;
    newFrm.origin.y = 0;
    
    // Animate it in
    [UIView animateWithDuration:0.4f animations:^{
        alertView.frame = newFrm;
    }];
    
    [self performSelector:@selector(dismissViewController:) withObject:alertView afterDelay:2.0f];
}

- (void)dismissViewController:(UIView *)view
{
    CGRect newFrm = view.frame;
    newFrm.origin.y = -100;
    
    [UIView animateWithDuration:0.4f animations:^{
        view.frame = newFrm;
    } completion:^(BOOL finished){
        [view removeFromSuperview];
    }];
}

#pragma mark - Get contents

- (void)getContentHeaderView
{
    self.tableView.tableHeaderView = headerView;
    
    NSLog(@"CONTENTASSETS: %@", self.contentAssets);
    
    // Get the node item
    NSMutableString *textNode;
    textNode = [self.contentAssets objectForKeyedSubscript:@"node"];
    
    // Get the replies item
    NSMutableString *textReplies;
    textReplies = [NSMutableString stringWithFormat:@"%@ 回复", [self.contentAssets objectForKeyedSubscript:@"replies"]];
    
    // Get the username item
    NSMutableString *textUsername;
    textUsername = [self.contentAssets objectForKeyedSubscript:@"username"];
    
    // Get the title item
    NSMutableString *textTitle;
    textTitle = [self.contentAssets objectForKeyedSubscript:@"title"];
    NSLog(@"CONTENT TITLE IS %@", textTitle);
    
    // Asynchronously Settings of the IDImageView
    NSURL *url = [NSURL URLWithString:[self.contentAssets objectForKeyedSubscript:@"memAvatar"]];
    [headerView.avatarImageView setImageWithURL:url];
    headerView.avatarImageView.layer.cornerRadius = 5.0;
    headerView.avatarImageView.layer.masksToBounds = YES;
    
    // Settings of the labels;
    headerView.titleLabel.text = textTitle;
    headerView.titleLabel.textColor = [UIColor colorWithRed:0.26 green:0.26 blue:0.25 alpha:1];
    headerView.titleLabel.preferredMaxLayoutWidth = headerView.titleLabel.bounds.size.width;
    
    headerView.nodeLabel.text = textNode;
    headerView.nodeLabel.textColor = [UIColor colorWithRed:0.94 green:0.93 blue:0.91 alpha:1];
    headerView.nodeLabel.layer.cornerRadius = 2.0;
    headerView.nodeLabel.layer.masksToBounds = YES;
    headerView.nodeLabel.backgroundColor = [UIColor colorWithRed:0.67 green:0.67 blue:0.65 alpha:1];
    headerView.borderView.layer.cornerRadius = 2.0;
    headerView.borderView.layer.masksToBounds = YES;
    headerView.borderView.backgroundColor = [UIColor colorWithRed:0.67 green:0.67 blue:0.65 alpha:1];
    
    headerView.numOfRepLabel.text = textReplies;
    headerView.lzIDLabel.text = textUsername;
    headerView.byLabel.text = @"By";
    
    headerView.backgroundColor = [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1];
    
    indicator2 = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    CGFloat yPoint = headerView.nodeLabel.intrinsicContentSize.height + headerView.titleLabel.intrinsicContentSize.height + 35;
    indicator2.frame = CGRectMake(0, yPoint, self.tableView.frame.size.width, 21);
    [headerView addSubview:indicator2];
    [indicator2 startAnimating];
}

- (void)getTheReplies
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        replyID = @"replyID";
        replyDate = @"replyDate";
        replyContent = @"replyContent";
        repAvatar = @"repAvatar";
    
        myReplyObject = [[NSMutableArray alloc] init];
        NSString *repID = [self.contentAssets objectForKeyedSubscript:@"URLID"];
        NSString *jsonURL = [NSString stringWithFormat:@"https://www.v2ex.com/api/replies/show.json?topic_id=%@", repID];
        
        NSData *jsonSource = [NSData dataWithContentsOfURL:[NSURL URLWithString:jsonURL]];
        
    
        id jsonObjects = [NSJSONSerialization JSONObjectWithData:jsonSource
                                                         options:NSJSONReadingMutableContainers
                                                           error:nil];
    
        for (NSDictionary *dataDick in jsonObjects) {
        
            // Get the replyer ID
            NSDictionary *member = [dataDick objectForKey:@"member"];
            NSString *replyID_data = [member objectForKey:@"username"];
            
            // Get the replies content item.
            NSMutableString *textRepContent;
            textRepContent= [NSMutableString stringWithFormat:@"%@", [dataDick objectForKey:@"content_rendered"]];
            NSString *htmlStringContent = [NSString stringWithFormat:@"%@", textRepContent];
            NSString *styledHTML = [self styledHTMLwithHTML:htmlStringContent];
            NSMutableAttributedString *attrStrContent_data = [self replyAttributedStringWithHTML:styledHTML];
        
            // Get the rely date
            NSString *repDate = [dataDick objectForKey:@"created"];
            double timestampcvt2 = [repDate doubleValue];
            NSTimeInterval timestamp2 = (NSTimeInterval)timestampcvt2;
            NSDate *updateTimestamp2 = [NSDate dateWithTimeIntervalSince1970:timestamp2];
            
            NSDate *now2 = [NSDate date];
            NSTimeInterval sinceNow2 = [now2 timeIntervalSinceDate:updateTimestamp2];
            
            int intervalTime2;
            NSString *replyDate_data;
            if (sinceNow2 < 3600) {
                intervalTime2 = sinceNow2 / 60;
                replyDate_data = [NSString stringWithFormat:@"%i 分钟前", intervalTime2];
            }
            else if (sinceNow2 > 3600 && sinceNow2 < 86400) {
                intervalTime2 = sinceNow2 / 3600;
                replyDate_data = [NSString stringWithFormat:@"%i 小时前", intervalTime2];
            }
            else if (sinceNow2 >= 86400) {
                intervalTime2 = sinceNow2 / 86400;
                replyDate_data = [NSString stringWithFormat:@"%i 天前", intervalTime2];
            }
        
            // Get the replyer avatar
            NSString *avatarURL = [member objectForKey:@"avatar_normal"];
            NSString *repAvatar_data = [NSString stringWithFormat:@"https:%@", avatarURL];
    
            NSLog(@"REPLYID: %@", replyID_data);
            NSLog(@"REPLYDATE: %@", replyDate_data);
            NSLog(@"REPLYCONTENT: %@", attrStrContent_data);
            NSLog(@"REPAVATAR: %@", repAvatar_data);
        
            repDictionary = [NSDictionary dictionaryWithObjectsAndKeys:replyID_data, replyID,
                                                                       replyDate_data, replyDate,
                                                                       attrStrContent_data, replyContent,
                                                                       repAvatar_data, repAvatar, nil];
            [myReplyObject addObject:repDictionary];
        }
        if (myReplyObject) {
            self.myObject2 = [NSMutableArray new];
            self.myObject2 = myReplyObject;
        }
    
        dispatch_async(dispatch_get_main_queue(), ^{
                
            Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
            NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
            
            if (networkStatus == NotReachable) {
                [self showConnectionAlertView];
                
                [self.refreshControl endRefreshing];
            } else if (!jsonSource) {
                [self showConnectionAlertView];
                
                [self.refreshControl endRefreshing];
            } else {
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationMiddle];
                [indicator stopAnimating];
                [self.refreshControl endRefreshing];
            }
        });
    });
}

- (void)getContentTextViewSpecial
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        contentDate = @"contentDate";
        topicContent = @"topicContent";
        
        myReplyObject = [[NSMutableArray alloc] init];
        NSString *repID = [self.contentAssets objectForKeyedSubscript:@"URLID"];
        NSString *jsonURL = [NSString stringWithFormat:@"https://www.v2ex.com/api/topics/show.json?id=%@", repID];
        
        NSData *jsonSource = [NSData dataWithContentsOfURL:[NSURL URLWithString:jsonURL]];
        
        
        id jsonObjects = [NSJSONSerialization JSONObjectWithData:jsonSource
                                                         options:NSJSONReadingMutableContainers
                                                           error:nil];
        
        for (NSDictionary *dataDick in jsonObjects) {
            
            // Get the replies content item.
            NSMutableString *textRepContent;
            textRepContent= [NSMutableString stringWithFormat:@"%@", [dataDick objectForKey:@"content_rendered"]];
            NSString *attrContent_data = [NSString stringWithFormat:@"%@", textRepContent];
            
            // Get the rely date
            NSString *contDate = [dataDick objectForKey:@"created"];
            double timestampcvt2 = [contDate doubleValue];
            NSTimeInterval timestamp2 = (NSTimeInterval)timestampcvt2;
            NSDate *updateTimestamp2 = [NSDate dateWithTimeIntervalSince1970:timestamp2];
            
            NSDate *now2 = [NSDate date];
            NSTimeInterval sinceNow2 = [now2 timeIntervalSinceDate:updateTimestamp2];
            
            int intervalTime2;
            NSString *contDate_data;
            if (sinceNow2 < 3600) {
                intervalTime2 = sinceNow2 / 60;
                contDate_data = [NSString stringWithFormat:@"%i 分钟前", intervalTime2];
            }
            else if (sinceNow2 > 3600 && sinceNow2 < 86400) {
                intervalTime2 = sinceNow2 / 3600;
                contDate_data = [NSString stringWithFormat:@"%i 小时前", intervalTime2];
            }
            else if (sinceNow2 >= 86400) {
                intervalTime2 = sinceNow2 / 86400;
                contDate_data = [NSString stringWithFormat:@"%i 天前", intervalTime2];
            }
            
            contDictionary = [NSDictionary dictionaryWithObjectsAndKeys:contDate_data, contentDate,
                              attrContent_data, topicContent, nil];
        }
        if (contDictionary) {
            self.myContentObject = [NSDictionary new];
            self.myContentObject = contDictionary;
        }
        
        // Get and convert the last modified timestamp to NSDate
        NSString* contentTime = [self.myContentObject objectForKey:contentDate];
        
        // Get the topic content item.
        NSString *htmlStringContent;
        htmlStringContent= [self.myContentObject objectForKey:topicContent];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
            NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
            
            if (networkStatus == NotReachable) {
                [self showConnectionAlertView];
                
                [self.refreshControl endRefreshing];
            } else if (!jsonSource) {
                [self showConnectionAlertView];
                
                [self.refreshControl endRefreshing];
            } else {
                
                // Get the replies content item.
                NSString *styledHTML = [self styledHTMLwithHTML:htmlStringContent];
                NSMutableAttributedString *attrContent_data = [self replyAttributedStringWithHTML:styledHTML];
                
                headerView.timeLabel.text = contentTime;
                
                // UITextView Settings
                headerView.contentTextView.delegate = self;
                headerView.contentTextView.attributedText = attrContent_data;
                NSLog(@"ATTRSTR: %@", attrContent_data);
                headerView.contentTextView.backgroundColor = [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1];
                // UITextView without margin/padding
                headerView.contentTextView.textContainerInset = UIEdgeInsetsMake(0, -5, -0, -5);
                [headerView.contentTextView setTranslatesAutoresizingMaskIntoConstraints:NO];
                headerView.contentSepView.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1];
                
                NSString *content_data = [NSString stringWithFormat:@"%@", attrContent_data];
                if ([content_data isEqualToString:@""]) {
                    [headerView.contentSepView removeFromSuperview];
                    [headerView.contentTextView removeFromSuperview];
                    [indicator2 stopAnimating];
                }
                
                CGRect headerFrame = self.tableView.tableHeaderView.frame;
                CGFloat contentTextViewHeight = [self textViewHeightForAttributedText:attrContent_data andWidth:headerView.contentTextView.frame.size.width];
                
                headerFrame.size.height = contentTextViewHeight + headerView.titleLabel.intrinsicContentSize.height + headerView.lzIDLabel.intrinsicContentSize.height + 25;
                NSLog(@"TITLELABELHEIGHT: %f", contentTextViewHeight);
                headerView.frame = headerFrame;
                self.tableView.tableHeaderView = headerView;
                [indicator2 stopAnimating];
                [headerView sizeToFit];
                
                if (attrContent_data) {
                    indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                    indicator.frame = CGRectMake(0, headerFrame.size.height, self.tableView.frame.size.width, 21);
                    [self.tableView addSubview:indicator];
                    [indicator startAnimating];
                }
                
                if (contentTime) {
                    [self getTheReplies];
                }
            }
            
        });
    });
}

- (void)getContentTextView
{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *repID = [self.contentAssets objectForKeyedSubscript:self.titleID];
        NSString *contents = [NSString stringWithFormat:@"https://www.v2ex.com%@", repID];
        NSURL *contentsURL = [NSURL URLWithString:contents];
        
        NSData *contentsHTMLData = [NSData dataWithContentsOfURL:contentsURL];
        
        TFHpple *contentsParser = [TFHpple hppleWithHTMLData:contentsHTMLData];
        
        // Get the date nodes
        NSString *dateXPathQueryString = @"//small[@class='gray'][1]";
        NSArray *dateNodes = [contentsParser searchWithXPathQuery:dateXPathQueryString];
        NSString *readableDate;
        for (TFHppleElement *element in dateNodes) {
            NSString *dateDataString = [element raw];
            NSLog(@"DATE DATA STRING: %@", dateDataString);
            NSArray *dateArray = [dateDataString componentsSeparatedByString:@" · "];
            NSString *date_data;
            if (dateArray.count > 2) {
                date_data = dateArray[1];
            } else {
                date_data = [dateDataString stringByReplacingOccurrencesOfString:@" · (.*?)$" withString:@""];
            }
            
            NSArray *dateStringArray = [date_data componentsSeparatedByString:@" "];
            if (dateStringArray.count > 1) {
                NSString *unitString;
                NSString *subString = dateStringArray[1];
                if ([subString containsString:@"分"]) {
                    unitString = @" 分钟前";
                }
                if ([subString containsString:@"小"]) {
                    unitString = @" 小时前";
                }
                if ([subString containsString:@"天"]) {
                    unitString = @" 天前";
                }
                
                
                readableDate = [NSString stringWithFormat:@"%@%@", dateStringArray[0], unitString];
            }
        }
        
        
        // Get the content item and convert to html format, then set the NSMutableAttributedString in the main thread.
        NSString *contentXPathQueryString = @"//div[@class='topic_content'][1]";
        NSArray *contentNodes = [contentsParser searchWithXPathQuery:contentXPathQueryString];
        NSString *contentText;
        
        for (TFHppleElement *element2 in contentNodes) {
            contentText = [element2 raw];
            break;
        }
        
        if (contentText == nil) {
            contentText = @"";
        }
        
        
        /*
         NSString *htmlString = [NSString stringWithFormat:@"<html><body>%@</body></html>", contentText];
         NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, } documentAttributes:nil error:nil];
         NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init]; // adjust the line spacing
         [paragraphStyle setLineSpacing:3];
         [attrStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [attrStr length])];
         */
        
        
        // Get and convert the last modified timestamp to NSDate
        
        /*
         NSTimeInterval timestamp = (NSTimeInterval)timestampcvt;
         NSDate *updateTimestamp = [NSDate dateWithTimeIntervalSince1970:timestamp];
         
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
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [indicator stopAnimating];
            Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
            NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
            
            if (networkStatus == NotReachable) {
                [self showConnectionAlertView];
                
                [self.refreshControl endRefreshing];
            }
            else if (!contentsHTMLData) {
                [self showConnectionAlertView];
                
                [self.refreshControl endRefreshing];
            }
            else {
                
                // Get the topic content item.
                NSMutableString *textContent;
                textContent= [NSMutableString stringWithFormat:@"%@", contentText];
                NSString *styledHTML = [self styledHTMLwithHTML:textContent];
                NSMutableAttributedString *attrStrContent = [self attributedStringWithHTML:styledHTML];
                NSLog(@"ATTRSTR: %@", attrStrContent);
                
                NSMutableString *textTitle;
                textTitle = [self.contentAssets objectForKeyedSubscript:self.item];
                
                headerView.timeLabel.text = readableDate;
                // UITextView Settings
                headerView.contentTextView.delegate = self;
                headerView.contentTextView.attributedText = attrStrContent;
                headerView.contentTextView.backgroundColor = [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1];
                // UITextView without margin/padding
                headerView.contentTextView.textContainerInset = UIEdgeInsetsMake(0, -5, -0, -5);
                [headerView.contentTextView setTranslatesAutoresizingMaskIntoConstraints:NO];
                headerView.contentSepView.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1];
                
                if ([contentText isEqualToString:@""]) {
                    [headerView.contentSepView removeFromSuperview];
                    [headerView.contentTextView removeFromSuperview];
                    [indicator2 stopAnimating];
                }
                
                CGRect headerFrame = self.tableView.tableHeaderView.frame;
                CGFloat contentTextViewHeight = [self textViewHeightForAttributedText:attrStrContent andWidth:headerView.contentTextView.frame.size.width];
                
                headerFrame.size.height = contentTextViewHeight + headerView.titleLabel.intrinsicContentSize.height + headerView.lzIDLabel.intrinsicContentSize.height + 20;
                NSLog(@"TITLELABELHEIGHT: %f", contentTextViewHeight);
                headerView.frame = headerFrame;
                self.tableView.tableHeaderView = headerView;
                [indicator2 stopAnimating];
                [headerView sizeToFit];
                
                if (contentText) {
                    indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                    indicator.frame = CGRectMake(0, headerFrame.size.height, self.tableView.frame.size.width, 21);
                    [self.tableView addSubview:indicator];
                    [indicator startAnimating];
                }
                
                if (readableDate) {
                    [self getTheReplies];
                }
            }
        });
    });
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [myReplyObject count];
}

// Display a blank UIView at the footer cells which not cotain the data.
// - (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
// {
//     UIView *view = [[UIView alloc] init];
//     return view;
// }


- (NSString *)styledHTMLwithHTML:(NSString *)HTML
{
    NSString *style = @"<meta charset=\"Unicode\"><style> body { font-family: 'HelveticaNeue'; line-height: 22px; font-size: 15px; color: #4d4d4d; } b {font-family: 'MarkerFelt-Wide'; }</style>";
    
    return [NSString stringWithFormat:@"%@%@", style, HTML];
}

- (NSMutableAttributedString *)attributedStringWithHTML:(NSString *)HTML
{
    NSDictionary *options = @{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType };
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithData:[HTML dataUsingEncoding:NSUnicodeStringEncoding] options:options documentAttributes:NULL error:NULL];
    [attributedString enumerateAttribute:NSAttachmentAttributeName
                                 inRange:NSMakeRange(0, attributedString.length)
                                 options:NSAttributedStringEnumerationReverse
                              usingBlock:^(NSTextAttachment *value, NSRange range, BOOL *stop) {
                                  if ([value isKindOfClass:[NSTextAttachment class]]) {
                                      [attributedString removeAttribute:NSAttachmentAttributeName range:range];
                                      
                                      MyContentImageAttachment *attachment = [MyContentImageAttachment new];
                                      attachment.image = value.image;
                                      attachment.bounds = value.bounds;
                                      attachment.fileWrapper = value.fileWrapper;
                                      
                                      [attributedString addAttribute:NSAttachmentAttributeName value:attachment range:range];
                                  }
                              }];
    
    // Remove the underline of linkiiwj
    [attributedString beginEditing];
    [attributedString enumerateAttribute:NSUnderlineStyleAttributeName
                                 inRange:NSMakeRange(0, attributedString.length)
                                 options:0
                              usingBlock:^(id value, NSRange range, BOOL *stop) {
                                  if (value) {
                                      [attributedString addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleNone) range:range];
                                  }
                              }];
    [attributedString endEditing];
    
    return attributedString;
}

- (NSMutableAttributedString *)replyAttributedStringWithHTML:(NSString *)HTML
{
    NSDictionary *options = @{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType };
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithData:[HTML dataUsingEncoding:NSUnicodeStringEncoding] options:options documentAttributes:NULL error:NULL];
    [attributedString enumerateAttribute:NSAttachmentAttributeName
                                 inRange:NSMakeRange(0, attributedString.length)
                                 options:NSAttributedStringEnumerationReverse
                              usingBlock:^(NSTextAttachment *value, NSRange range, BOOL *stop) {
                                  if ([value isKindOfClass:[NSTextAttachment class]]) {
                                      [attributedString removeAttribute:NSAttachmentAttributeName range:range];
                                      
                                      MyReplyImageAttachment *attachment = [MyReplyImageAttachment new];
                                      attachment.image = value.image;
                                      attachment.bounds = value.bounds;
                                      attachment.fileWrapper = value.fileWrapper;
                                      
                                      [attributedString addAttribute:NSAttachmentAttributeName value:attachment range:range];
                                  }
                              }];
    
    // Remove the underline of linkiiwj
    [attributedString beginEditing];
    [attributedString enumerateAttribute:NSUnderlineStyleAttributeName
                                 inRange:NSMakeRange(0, attributedString.length)
                                 options:0
                              usingBlock:^(id value, NSRange range, BOOL *stop) {
                                  if (value) {
                                      [attributedString addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleNone) range:range];
                                  }
                              }];
    [attributedString endEditing];
    
    return attributedString;
}

- (CGFloat)textViewHeightForAttributedText:(NSAttributedString *)text andWidth:(CGFloat)width
{
    float fPadding = 10.0; // 5.0px x 2
    CGSize constraint = CGSizeMake(width + fPadding, CGFLOAT_MAX);
    UITextView *textView = [[UITextView alloc] init];
    [textView setAttributedText:text];
    CGSize size = [textView sizeThatFits:CGSizeMake(constraint.width, FLT_MAX)];
    return size.height;
}


/* Setup the cell separator line margins
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}
*/
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url
{
    // User tapped on a link, do something
    
    NSString *atID = [NSString stringWithFormat:@"%@", url];
    if ([atID containsString:@"."]) {
            
        if ([atID containsString:@"@"]) {
            
            if ([[UIApplication sharedApplication] canOpenURL:url]) {
                [[UIApplication sharedApplication] openURL:url];
            }
            
        } else {
                
            // Open the website here
            SFSafariViewController *webViewController = [[SFSafariViewController alloc] initWithURL:url];
            [self presentViewController:webViewController animated:YES completion:nil];
                
        }
    }
}

- (void)attributedLabel:(TTTAttributedLabel *)label didLongPressLinkWithURL:(NSURL *)url atPoint:(CGPoint)point;
{
    NSString *atID = [NSString stringWithFormat:@"%@", url];
    if ([atID containsString:@"."]) {
            
        NSArray *activities = @[[SVWebViewControllerActivityCopyLink new], [SVWebViewControllerActivitySafari new], [SVWebViewControllerActivityChrome new]];
            
        if ([[url absoluteString] hasPrefix:@"file:///"]) {
            UIDocumentInteractionController *dc = [UIDocumentInteractionController interactionControllerWithURL:url];
            [dc presentOptionsMenuFromRect:self.view.bounds inView:self.view animated:YES];
        } else {
            NSArray *objectsToShare = @[url];
            
            UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:activities];
                
#ifdef __IPHONE_8_0
            if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1 &&
                UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                UIPopoverPresentationController *ctrl = activityController.popoverPresentationController;
                ctrl.sourceView = self.view;
            }
#endif
                
            [self presentViewController:activityController animated:YES completion:nil];
        }
        
    }
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange
{
    // Check for long press event
    BOOL isLongPress = NO;
    
    for (UIGestureRecognizer *recognizer in textView.gestureRecognizers) {
        if ([recognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
            if (recognizer.state == UIGestureRecognizerStateBegan) {
                isLongPress = YES;
            }
        }
    }
    
    if (isLongPress == YES) {
      
        // User long pressed a link, do something
        
        return YES;
        
    } else {
    
        // User tapped on a link, do something
    
        NSString *atID = [NSString stringWithFormat:@"%@", URL];
        if ([atID containsString:@"."]) {
        
            if ([atID containsString:@"@"]) {
                return YES;
            } else {
        
                NSLog(@"URL IS: %@", URL);
        
                // Open the website here
                SFSafariViewController *webViewController = [[SFSafariViewController alloc] initWithURL:URL];
                [self presentViewController:webViewController animated:YES completion:nil];
                
                return NO;
            }
        }
    }
    
    return NO;
}

- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location
{
    NSLog(@"TEST");
    
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    
    if (indexPath) {
        RepliesTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        CGPoint const convertedPoint = [cell.repliesLabel convertPoint:location fromView:self.tableView];
        NSLog(@"CONVERTED POINT: %@", NSStringFromCGPoint(convertedPoint));
        TTTAttributedLabelLink *link = [cell.repliesLabel linkAtPoint:convertedPoint];
        NSString *URLString = [NSString stringWithFormat:@"%@", link.result.URL];
        if ([URLString containsString:@"."]) {
            
            if ([URLString containsString:@"@"]) {
                return nil;
            } else {
                
                NSLog(@"URL IS: %@", URLString);
                
                // Open the website here
                SFSafariViewController *webViewController = [[SFSafariViewController alloc] initWithURL:link.result.URL];
                
                return webViewController;
            }
        }
    }
    
    return nil;
}

- (void)previewingContext:(id <UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit
{
    NSLog(@"pop");
    
    SFSafariViewController *vc = (SFSafariViewController *)viewControllerToCommit;
    [self presentViewController:vc animated:YES completion:nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"repliesTableViewCell";
    
    RepliesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (cell == nil) {
        cell = [[RepliesTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    
    // The second UITableViewCell, cell2
    NSDictionary *tmpDict = [self.myObject2 objectAtIndex:indexPath.row];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Get Avatar URL
        NSURL *url2 = [NSURL URLWithString:[tmpDict objectForKey:repAvatar]];
    
        
        // Get and convert the last modified timestamp to NSDate
        NSString* readableTime = [tmpDict objectForKey:replyDate];
    
                
        // Get the replyer ID item.
        NSMutableString *textRepID;
        textRepID = [tmpDict objectForKey:replyID];
                
        // Get the replies content item.
        NSMutableAttributedString *textRepContent;
        textRepContent= [tmpDict objectForKey:replyContent];
    

        dispatch_async(dispatch_get_main_queue(), ^{
    
            // Settings of labels.
            cell.repliesID.text = textRepID;
    
            // UITextView Settings
            cell.repliesLabel.text = textRepContent;
            cell.repliesLabel.delegate = self;
    
            cell.repliesTime.text = readableTime;
            
            if (readableTime) {
                // Asynchronously Settings of the IDImageView
                [cell.repliesImageView setImageWithURL:url2 placeholderImage:[UIImage imageNamed:@"avatarPlaceholder"]];
                
                // Setup the cell separator line margins
                // cell2.preservesSuperviewLayoutMargins = NO;
                
                UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 1)];
                separatorView.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1];
                [cell.contentView addSubview:separatorView];
            }
        });
    });
    
    // Make cell.contentView interactive
    cell.contentView.userInteractionEnabled = YES;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [tableView fd_heightForCellWithIdentifier:@"repliesTableViewCell" cacheByIndexPath:indexPath configuration:^(RepliesTableViewCell *cell) {
        if (cell == nil) {
            cell = [[RepliesTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"repliesTableViewCell"];
        }
        
        // The second UITableViewCell, cell2
        NSDictionary *tmpDict = [self.myObject2 objectAtIndex:indexPath.row];
        
        // Get Avatar URL
        NSURL *url2 = [NSURL URLWithString:[tmpDict objectForKey:repAvatar]];
        
        // Get and convert the last modified timestamp to NSDate
        NSString* readableTime = [tmpDict objectForKey:replyDate];
        
        // Get the replyer ID item.
        NSMutableString *textRepID;
        textRepID = [tmpDict objectForKey:replyID];
        
        // Get the replies content item.
        NSMutableAttributedString *textRepContent;
        textRepContent= [tmpDict objectForKey:replyContent];
        
        
        
        // Asynchronously Settings of the IDImageView
        [cell.repliesImageView setImageWithURL:url2];
        
        // Settings of labels.
        cell.repliesID.text = textRepID;
        
        // UITextView Settings
        cell.repliesLabel.attributedText = textRepContent;
        
        cell.repliesTime.text = readableTime;
    }];
}

- (IBAction)shareButton:(id)sender
{
    NSMutableString *textTitle;
    textTitle = [self.contentAssets objectForKeyedSubscript:@"title"];
    NSString *textToShare = textTitle;
    
    NSString *repID = [self.contentAssets objectForKeyedSubscript:@"URLID"];
    NSString *websiteString = [NSString stringWithFormat:@"https://www.v2ex.com/t/%@", repID];
    NSURL *websiteToShare = [NSURL URLWithString:websiteString];
    
    if (websiteToShare != nil) {
        NSArray *activities = @[[SVWebViewControllerActivityCopyLink new], [SVWebViewControllerActivitySafari new], [SVWebViewControllerActivityChrome new]];
        
        if ([[websiteToShare absoluteString] hasPrefix:@"file:///"]) {
            UIDocumentInteractionController *dc = [UIDocumentInteractionController interactionControllerWithURL:websiteToShare];
            [dc presentOptionsMenuFromRect:self.view.bounds inView:self.view animated:YES];
        } else {
            NSArray *objectsToShare = @[textToShare, websiteToShare];
            
            UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:activities];
            
#ifdef __IPHONE_8_0
            if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1 &&
                UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                UIPopoverPresentationController *ctrl = activityController.popoverPresentationController;
                ctrl.sourceView = self.view;
                ctrl.barButtonItem = sender;
            }
#endif
            
            [self presentViewController:activityController animated:YES completion:nil];
        }
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
