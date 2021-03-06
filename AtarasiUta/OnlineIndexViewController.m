//
//  OnlineIndexViewController.m
//  AtarasiUta
//
//  Created by 倪 李俊 on 2016/12/20.
//  Copyright © 2016年 com.sinri. All rights reserved.
//

#import "OnlineIndexViewController.h"
#import "ViewController.h"
#import "ReadmeViewController.h"


@interface OnlineIndexViewController ()

//@property NSArray * books_array;
//@property NSArray * scores_array;
@property NSDictionary * scoreDict;
@property NSInteger current_book_index;
@property NSInteger current_score_index;

//@property UIActivityIndicatorView *testActivityIndicator;
@property NSURLSessionDataTask * vcNetTask;

@end

@implementation OnlineIndexViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem * refreshBtn=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:(UIBarButtonSystemItemRefresh) target:self action:@selector(runApiGetDraftList)];
    [[self navigationItem]setRightBarButtonItem:refreshBtn];
    
    UIBarButtonItem * readmeBtn=[[UIBarButtonItem alloc]initWithTitle:@"About" style:(UIBarButtonItemStylePlain) target:self action:@selector(openReadme)];
    [[self navigationItem]setLeftBarButtonItem:readmeBtn];
    
    _scoreDict=@{};
    _current_score_index=-1;
    _current_book_index=-1;
    
    [self runApiGetDraftList];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // iOS9
    if([self.tableView respondsToSelector:@selector(setCellLayoutMarginsFollowReadableWidth:)]) {
        self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
    }
    
//    [SinriScoreDrawerView test];
}

-(void)viewWillAppear:(BOOL)animated{
    self.navigationItem.title=@"AtarasiUta";
}
-(void)viewWillDisappear:(BOOL)animated{
    self.navigationItem.title=@"Menu";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSArray*)getBookList{
    NSArray * books=[_scoreDict allKeys];
    if(!books){
        books=@[];
    }
    return books;
}

-(NSString*)getCurrentBookCode{
    if(_current_book_index<0){
        return NULL;
    }
    return [[self getBookList] objectAtIndex:_current_book_index];
}

-(NSArray*)getScoresInCurrentBook{
    NSArray*scores=[_scoreDict objectForKey:[self getCurrentBookCode]];
    if(!scores){
        return @[];
    }
    return scores;
}

-(NSString*)getCurrentScoreInfo{
    if(_current_score_index<0){
        return NULL;
    }
    return [[self getScoresInCurrentBook] objectAtIndex:_current_score_index];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section==0){
        return [[self getBookList]count];
    }else{
        return [[self getScoresInCurrentBook]count];
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
    NSString * cell_id_for_book=@"IndexVC_cell_for_book";
    NSString * cell_id_for_score=@"IndexVC_cell_for_score";
    UITableViewCell *cell;
    
    // Configure the cell...
    if(indexPath.section==0){
        cell = [tableView dequeueReusableCellWithIdentifier:cell_id_for_book];
        if(!cell){
            cell=[[UITableViewCell alloc]initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:cell_id_for_book];
            [cell setSelectionStyle:(UITableViewCellSelectionStyleBlue)];
            [cell setAccessoryType:(UITableViewCellAccessoryNone)];
            
//            [cell setBackgroundColor:[UIColor greenColor]];
        }
        [[cell textLabel]setText:[[self getBookList] objectAtIndex:indexPath.row]];
//        [[cell textLabel] setBackgroundColor:[UIColor redColor]];
        if(indexPath.row==_current_book_index){
            [cell setAccessoryType:(UITableViewCellAccessoryCheckmark)];
        }else{
            [cell setAccessoryType:(UITableViewCellAccessoryNone)];
        }
    }else{
        cell = [tableView dequeueReusableCellWithIdentifier:cell_id_for_score];
        if(!cell){
            cell=[[UITableViewCell alloc]initWithStyle:(UITableViewCellStyleValue1) reuseIdentifier:cell_id_for_score];
            [cell setSelectionStyle:(UITableViewCellSelectionStyleBlue)];
            [cell setAccessoryType:(UITableViewCellAccessoryNone)];
        }
        id info = [[self getScoresInCurrentBook] objectAtIndex:indexPath.row];
        [[cell detailTextLabel] setText:[NSString stringWithFormat:@"Draft ID: %@",[info objectForKey:@"id"]]];
        [[cell textLabel]setText:[NSString stringWithFormat:@"%@ | %@",[info objectForKey:@"score_code"],[info objectForKey:@"score_title"]]];
//        if(indexPath.row==_current_score_index){
//            [cell setAccessoryType:(UITableViewCellAccessoryCheckmark)];
//        }else{
//            [cell setAccessoryType:(UITableViewCellAccessoryNone)];
//        }
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section==0){
        _current_book_index=indexPath.row;
        [[tableView cellForRowAtIndexPath:indexPath]setSelected:YES animated:YES];
    }else{
        _current_score_index=indexPath.row;
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
    id info=[self getCurrentScoreInfo];
    if(info){
        ViewController * vc=[[ViewController alloc]initWithDraftID:[info objectForKey:@"id"]];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

-(void)openReadme{
    ReadmeViewController * vc=[[ReadmeViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - beneath NETWORK related

-(NSString*)getDraftListUrl{
    return @"https://sinri.cc/api/SikaScoreBook/ajaxGetDraftList";
}

-(void)runApiGetDraftList{
    if(_vcNetTask && [_vcNetTask state]!=NSURLSessionTaskStateCompleted){
        [_vcNetTask cancel];
    }
    NSMutableURLRequest * request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:[self getDraftListUrl]]];
    _vcNetTask=[self executeAsyncRequest:request doneCallback:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error, id  _Nullable weakSelf) {
        NSError * jsonError;
        NSDictionary * dict=[NSJSONSerialization JSONObjectWithData:data options:(NSJSONReadingMutableLeaves) error:&jsonError];
        if([[dict objectForKey:@"code"] isEqualToString:@"OK"]){
//            dispatch_async(dispatch_get_main_queue(), ^(void){
                // メインスレッドで処理する内容
                NSLog(@"books: %@",[[dict objectForKey:@"data"] allKeys]);
                [weakSelf setScoreDict:[dict objectForKey:@"data"]];
                
                [weakSelf setCurrent_book_index:0];
                [weakSelf setCurrent_score_index:0];
                
                [[weakSelf tableView]reloadData];
//            });
        }
    } failCallback:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error, id  _Nullable weakSelf) {
        [self alertNetworkError:error ConfirmHandler:^(UIAlertAction *action) {
            //
        }];
    }];
}
/*
-(void)runApiGetDraftListOld{
    __weak id instance= self;
    NSURLSessionConfiguration * conf = [NSURLSessionConfiguration defaultSessionConfiguration];
    [conf setTimeoutIntervalForRequest:60];
    NSURLSession * session = [NSURLSession sessionWithConfiguration:conf];
    NSMutableURLRequest * request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:[self getDraftListUrl]]];
    NSURLSessionDataTask * task=[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"RESP=%@ ERROR=%@",response,error);
        NSError * jsonError;
        NSDictionary * dict=[NSJSONSerialization JSONObjectWithData:data options:(NSJSONReadingMutableLeaves) error:&jsonError];
        if([[dict objectForKey:@"code"] isEqualToString:@"OK"]){
            dispatch_async(dispatch_get_main_queue(), ^(void){
                // メインスレッドで処理する内容
                NSLog(@"books: %@",[[dict objectForKey:@"data"] allKeys]);
                [instance setScoreDict:[dict objectForKey:@"data"]];
                
                [instance setCurrent_book_index:0];
                [instance setCurrent_score_index:0];
                
                [[instance tableView]reloadData];
            });
        }
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [instance stopWaitCircle];
        });
    }];
    
    [self beginWaitCircle];
    [task resume];
}

-(void)beginWaitCircle{
    [self stopWaitCircle];
    
    _testActivityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    _testActivityIndicator.center = self.view.center;//只能设置中心，不能设置大小
    [self.view addSubview:_testActivityIndicator];
    _testActivityIndicator.color = [UIColor redColor]; // 改变圈圈的颜色为红色； iOS5引入
    [_testActivityIndicator startAnimating]; // 开始旋转
    
    [self.view setUserInteractionEnabled:NO];
    
}
-(void)stopWaitCircle{
    if(_testActivityIndicator){
        [_testActivityIndicator stopAnimating]; // 结束旋转
        [_testActivityIndicator setHidesWhenStopped:YES]; //当旋转结束时隐藏
        [_testActivityIndicator removeFromSuperview];
        _testActivityIndicator = NULL;
    }
    [self.view setUserInteractionEnabled:YES];
}
*/

@end
