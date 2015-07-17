//
//  contentTableViewController.m
//  V2EX
//
//  Created by St.Jimmy on 5/24/15.
//  Copyright (c) 2015 Xing He. All rights reserved.
//

#import "contentTableViewController.h"
#import "contenHeaderView.h"
#import "repliesTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "TFHpple.h"

@interface contentTableViewController ()
{
    NSMutableArray *myReplyObject;
    NSDictionary *repDictionary;
    NSString *replyID;
    NSString *replyDate;
    NSString *replyContent;
    NSString *repAvatar;
}

@end

@implementation contentTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self pullToRefresh];
    
    // Start pull to refresh automatically.
    // [self.refreshControl beginRefreshing];
    // CGPoint newOffset = CGPointMake(0, - 60);
    // [self.tableView setContentOffset:newOffset animated:YES];
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self performSelector:@selector(getTheReplies) withObject:nil afterDelay:2.0];
    
    self.automaticallyAdjustsScrollViewInsets = YES;
    
    self.tableView.estimatedRowHeight = 66.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getContentHeaderView];
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
                            action:@selector(getTheReplies)
                  forControlEvents:UIControlEventValueChanged];
}

- (void)getTheReplies
{
    replyID = @"replyID";
    replyDate = @"replyDate";
    replyContent = @"replyContent";
    repAvatar = @"repAvatar";
    
    myReplyObject = [[NSMutableArray alloc] init];
    NSString *repID = [self.contentAssets objectForKeyedSubscript:self.URLID];
    NSString *jsonURL = [NSString stringWithFormat:@"https://www.v2ex.com/api/replies/show.json?topic_id=%@", repID];
    
    NSData *jsonSource = [NSData dataWithContentsOfURL:[NSURL URLWithString:jsonURL]];
    
    id jsonObjects = [NSJSONSerialization JSONObjectWithData:jsonSource
                                                     options:NSJSONReadingMutableContainers
                                                       error:nil];
    
    for (NSDictionary *dataDick in jsonObjects) {
        
        // Get the replyer ID
        NSDictionary *member = [dataDick objectForKey:@"member"];
        NSString *replyID_data = [member objectForKey:@"username"];
        
        // Get the rely date
        NSString *replydate_data = [dataDick objectForKey:@"created"];
        
        // Get the reply content
        NSString *replyContent_data = [dataDick objectForKey:@"content_rendered"];
        
        // Get the replyer avatar
        NSString *avatarURL = [member objectForKey:@"avatar_normal"];
        NSString *repAvatar_data = [NSString stringWithFormat:@"http:%@", avatarURL];
        
        NSLog(@"REPLYID: %@", replyID_data);
        NSLog(@"REPLYDATE: %@", replydate_data);
        NSLog(@"REPLYCONTENT: %@", replyContent_data);
        NSLog(@"REPAVATAR: %@", repAvatar_data);
        
        repDictionary = [NSDictionary dictionaryWithObjectsAndKeys:replyID_data, replyID,
                         replydate_data, replyDate,
                         replyContent_data, replyContent,
                         repAvatar_data, repAvatar, nil];
        [myReplyObject addObject:repDictionary];
    }
    
    // [self.refreshControl endRefreshing];
    [self.tableView beginUpdates];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationMiddle];
    [self.tableView endUpdates];
    [self.refreshControl endRefreshing];
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

- (void)getContentHeaderView
{
    contenHeaderView *headerView = (contenHeaderView *)self.tableView.tableHeaderView;
    
    NSString *repID = [self.contentAssets objectForKeyedSubscript:self.titleID];
    NSString *contents = [NSString stringWithFormat:@"https://www.v2ex.com%@", repID];
    NSURL *contentsURL = [NSURL URLWithString:contents];
    
    NSData *contentsHTMLData = [NSData dataWithContentsOfURL:contentsURL];
    
    TFHpple *contentsParser = [TFHpple hppleWithHTMLData:contentsHTMLData];
    
    // Get the node item
    NSMutableString *textNode;
    textNode = [self.contentAssets objectForKey:self.node];
    
    // Get the date nodes
    NSString *dateXPathQueryString = @"//small[@class='gray']";
    NSArray *dateNodes = [contentsParser searchWithXPathQuery:dateXPathQueryString];
    NSString *readableDate;
    for (TFHppleElement *element in dateNodes) {
        NSString *dateDataString = [element content];
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
    
    NSLog(@"REPLY CONTENT URL: %@", contents);
    
    // Get the replies item
    NSMutableString *textReplies;
    textReplies = [NSMutableString stringWithFormat:@"%@ 回复", [self.contentAssets objectForKey:self.replies]];
    
    // Get the username item
    NSMutableString *textUsername;
    textUsername = [self.contentAssets objectForKey:self.username];
    
    // Get the content item and convert to html format
    NSString *contentXPathQueryString = @"//div[@class='topic_content']";
    NSArray *contentNodes = [contentsParser searchWithXPathQuery:contentXPathQueryString];
    NSString *contentText;
    for (TFHppleElement *element2 in contentNodes) {
        contentText = [element2 raw];
    }
    
    /* NSString *htmlString = [NSString stringWithFormat:@"<html><body>%@</body></html>", contentText];
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
    
    // Get the title item
    NSMutableString *textTitle;
    textTitle = [self.contentAssets objectForKeyedSubscript:self.item];
    
    // Asynchronously Settings of the IDImageView
    NSURL *url = [NSURL URLWithString:[self.contentAssets objectForKey:self.memAvatar]];
    [headerView.avatarImageView setImageWithURL:url];
    headerView.avatarImageView.layer.cornerRadius = 5.0;
    headerView.avatarImageView.layer.masksToBounds = YES;
    
    // Settings of the labels;
    headerView.titleLabel.text = textTitle;
    headerView.titleLabel.preferredMaxLayoutWidth = headerView.titleLabel.bounds.size.width;
    
    headerView.nodeLabel.layer.cornerRadius = 2.0;
    headerView.nodeLabel.layer.masksToBounds = YES;
    headerView.nodeLabel.text = textNode;
    
    headerView.numOfRepLabel.text = textReplies;
    headerView.lzIDLabel.text = textUsername;
    headerView.timeLabel.text = readableDate;
    
    // UITextView Settings
    headerView.contentString = contentText;
    
    NSLog(@"CONTENTTITLE: %@", textTitle);
    NSLog(@"CONTENTNODE: %@", textNode);
    NSLog(@"CONTENTREPLYNUMS: %@", textReplies);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    repliesTableViewCell *cell2 = [tableView dequeueReusableCellWithIdentifier:@"repliesTableViewCell"];
    
    if (cell2 == nil) {
        cell2 = [[repliesTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"repliesTableViewCell"];
    }
    
    // The second UITableViewCell, cell2.
    NSDictionary *tmpDict = [myReplyObject objectAtIndex:indexPath.row];
    
    // Get the replyer ID item.
    NSMutableString *textRepID;
    textRepID = [tmpDict objectForKey:replyID];
    
    // Get the replies content item.
    NSMutableString *textRepContent;
    textRepContent= [NSMutableString stringWithFormat:@"%@", [tmpDict objectForKey:replyContent]];
    NSString *htmlStringContent = [NSString stringWithFormat:@"%@", textRepContent];
    NSMutableAttributedString *attrStrContent = [[NSMutableAttributedString alloc] initWithData:[htmlStringContent dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, } documentAttributes:nil error:nil];
    NSMutableParagraphStyle *paragraphStyleContent = [[NSMutableParagraphStyle alloc] init]; // adjust the line spacing
    [paragraphStyleContent setLineSpacing:3];
    [attrStrContent addAttribute:NSParagraphStyleAttributeName value:paragraphStyleContent range:NSMakeRange(0, [attrStrContent length])];
    
    // Asynchronously Settings of the IDImageView
    NSURL *url2 = [NSURL URLWithString:[tmpDict objectForKey:repAvatar]];
    [cell2.repliesImageView setImageWithURL:url2];
    cell2.repliesImageView.layer.cornerRadius = 5.0;
    cell2.repliesImageView.layer.masksToBounds = YES;
    
    // Get and convert the last modified timestamp to NSDate
    double timestampcvt2 = [[tmpDict objectForKey:replyDate] doubleValue];
    NSTimeInterval timestamp2 = (NSTimeInterval)timestampcvt2;
    NSDate *updateTimestamp2 = [NSDate dateWithTimeIntervalSince1970:timestamp2];
    
    NSDate *now2 = [NSDate date];
    NSTimeInterval sinceNow2 = [now2 timeIntervalSinceDate:updateTimestamp2];
    
    int intervalTime2;
    NSString *readableTime2;
    if (sinceNow2 < 3600) {
        intervalTime2 = sinceNow2 / 60;
        readableTime2 = [NSString stringWithFormat:@"%i 分钟前", intervalTime2];
    }
    else if (sinceNow2 > 3600 && sinceNow2 < 86400) {
        intervalTime2 = sinceNow2 / 3600;
        readableTime2 = [NSString stringWithFormat:@"%i 小时前", intervalTime2];
    }
    else if (sinceNow2 >= 86400) {
        intervalTime2 = sinceNow2 / 86400;
        readableTime2 = [NSString stringWithFormat:@"%i 天前", intervalTime2];
    }
     
    // Settings of labels.
    cell2.repliesID.text = textRepID;

    // UITextView Settings
    cell2.repliesTextView.attributedText = attrStrContent;
    cell2.repliesTextView.font = [UIFont systemFontOfSize:13.0f];
    cell2.repliesTextView.textColor = [UIColor darkGrayColor];
    // UITextView lose margin/padding
    cell2.repliesTextView.textContainerInset = UIEdgeInsetsMake(0, -5, -0, -5);
    [cell2.repliesTextView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    cell2.repliesTime.text = readableTime2;
    
    cell2.layer.shouldRasterize = YES;
    cell2.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    return cell2;
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
