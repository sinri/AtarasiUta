//
//  IndexViewController.m
//  AtarasiUta
//
//  Created by 倪 李俊 on 2016/12/19.
//  Copyright © 2016年 com.sinri. All rights reserved.
//

#import "IndexViewController.h"
#import "OnlineIndexViewController.h"
#import "ViewController.h"
#import "WebPageMaker.h"

@interface IndexViewController ()

@property NSArray * books_array;
@property NSInteger current_book_index;
@property NSArray * scores_array;
@property NSInteger currnet_score_index;

@end

@implementation IndexViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem * rightBtn=[[UIBarButtonItem alloc]initWithTitle:@"Online" style:(UIBarButtonItemStylePlain) target:self action:@selector(openOnlineContentVC)];
    [self.navigationItem setRightBarButtonItem:rightBtn];
    
    self.navigationItem.title=@"Contents";
    
    _books_array=[WebPageMaker getBookList];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSArray*)getCurrentBookScores{
    _scores_array=[WebPageMaker getScoreListInBook:[_books_array objectAtIndex:  _current_book_index]];
    return _scores_array;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section==0){
        return [_books_array count];
    }else{
        return [[self getCurrentBookScores]count];
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if(section==0){
        return @"Book";
    }else{
        return @"Score";
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString * cell_id=@"IndexVC_CELL";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell_id];
    
    // Configure the cell...
    if(!cell){
        cell=[[UITableViewCell alloc]initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:cell_id];
        [cell setSelectionStyle:(UITableViewCellSelectionStyleBlue)];
        [cell setAccessoryType:(UITableViewCellAccessoryNone)];
    }
    if(indexPath.section==0){
        [[cell textLabel]setText:[_books_array objectAtIndex:indexPath.row]];
        if(indexPath.row==_current_book_index){
            [cell setAccessoryType:(UITableViewCellAccessoryCheckmark)];
        }else{
            [cell setAccessoryType:(UITableViewCellAccessoryNone)];
        }
    }else{
        [[cell textLabel]setText:[_scores_array objectAtIndex:indexPath.row]];
        if(indexPath.row==_currnet_score_index){
            [cell setAccessoryType:(UITableViewCellAccessoryCheckmark)];
        }else{
            [cell setAccessoryType:(UITableViewCellAccessoryNone)];
        }
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section==0){
        _current_book_index=indexPath.row;
        _scores_array=[WebPageMaker getScoreListInBook:[_books_array objectAtIndex:_current_book_index]];
        [[tableView cellForRowAtIndexPath:indexPath]setSelected:YES animated:YES];
    }else{
        _currnet_score_index=indexPath.row;
        [[tableView cellForRowAtIndexPath:indexPath]setSelected:YES animated:YES];
        [self openCurrentSika];
    }
    [self.tableView reloadData];
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

-(void)openCurrentSika{
    NSString * book_code=[_books_array objectAtIndex:_current_book_index];
    NSString * score_code=[_scores_array objectAtIndex:_currnet_score_index];
    
    ViewController * vc=[[ViewController alloc]initWithScore:score_code inBook:book_code];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)openOnlineContentVC{
    OnlineIndexViewController * vc=[[OnlineIndexViewController alloc]initWithStyle:(UITableViewStyleGrouped)];
    [self.navigationController pushViewController:vc animated:YES];
    
}

@end
