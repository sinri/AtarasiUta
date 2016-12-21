//
//  CommentViewController.m
//  AtarasiUta
//
//  Created by 倪 李俊 on 2016/12/20.
//  Copyright © 2016年 com.sinri. All rights reserved.
//

#import "CommentViewController.h"
#import "ClientAgent.h"

@interface CommentViewController ()
//@property UIScrollView *container;
//@property UITextView *comment;
//@property UISegmentedControl *pointSegment;
@property UIWebView * webView;
@property UIActivityIndicatorView *testActivityIndicator;
@end

@implementation CommentViewController

-(instancetype)initWithDraftInfo:(NSDictionary *)draft_info{
    self=[super init];
    if(self){
        _draftInfo=draft_info;
        _draftId=[draft_info objectForKey:@"id"];
    }
    return self;
}

-(instancetype)initWithDraftId:(NSString*)draft_id{
    self=[super init];
    if(self){
        _draftId=draft_id;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor whiteColor]];
//    [self loadContentsOfView];
    
    [[self navigationItem]setTitle:@"Feedback"];
    
    _webView = [[UIWebView alloc]init];
    [[_webView scrollView]setBounces:NO];
    [_webView setScalesPageToFit:YES];
    [_webView setDelegate:self];
    [self.view addSubview:_webView];
    
    [_webView setFrame:(CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height))];
    
    NSMutableURLRequest * request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://sinri.cc/SikaScoreBook/comment/%@/%@",[_draftInfo objectForKey:@"id"],[ClientAgent getClientSN]]]];
    NSLog(@"request as %@",request);
    [_webView loadRequest:request];
}

-(BOOL)shouldAutorotate{
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadContentsOfView{
    //with _draftInfo
    /*
    if(_container){
        [_container removeFromSuperview];
    }
    CGFloat y=10;
    CGFloat max_width=self.view.frame.size.width;
    _container = [[UIScrollView alloc]initWithFrame:(CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height))];
    
    UILabel * infoLabel = [[UILabel alloc]initWithFrame:(CGRectMake(10, y, max_width-20, 200))];
    [infoLabel setNumberOfLines:0];
    [infoLabel setText:[NSString stringWithFormat:@"[#%@] %@-%@\n%@\nDESC: %@\nMARK: %@\nMEMO: %@",
                        [_draftInfo objectForKey:@"id"],
                        [_draftInfo objectForKey:@"book"],
                        [_draftInfo objectForKey:@"score_code"],
                        [_draftInfo objectForKey:@"score_title"],
                        [_draftInfo objectForKey:@"score_desc"],
                        [_draftInfo objectForKey:@"admin_mark"],
                        [_draftInfo objectForKey:@"memo"]
                        ]];
    [_container addSubview:infoLabel];
    y+=200+10;
    
    _pointSegment=[[UISegmentedControl alloc]initWithItems:@[@"1",@"2",@"3",@"4",@"5"]];
    [_pointSegment setFrame:(CGRectMake(10, y, max_width-20, 50))];
    [_container addSubview:_pointSegment];
    
    _comment=[[UITextView alloc]initWithFrame:(CGRectMake(10, y, max_width-20, 80))];
    _comment.layer.borderColor = [UIColor grayColor].CGColor;
    _comment.layer.borderWidth =1.0;
    _comment.layer.cornerRadius =5.0;
    
    UIToolbar * topView = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, max_width, 35)];
    [topView setBarStyle:UIBarStyleBlackOpaque];
    //    UIBarButtonItem * helloButton = [[UIBarButtonItem alloc]initWithTitle:@"Hello" style:UIBarButtonItemStylePlain target:self action:nil];
    UIBarButtonItem * btnSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem * doneButton = [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(dismissKeyBoard)];
    NSArray * buttonsArray = [NSArray arrayWithObjects:btnSpace,doneButton,nil];
    
    [topView setItems:buttonsArray];
    [_comment setInputAccessoryView:topView];
    
    [_container addSubview:_comment];
    
    [_container setContentSize:CGSizeMake(max_width, y+10)];
    [self.view addSubview:_container];
     */
}

-(void)dismissKeyBoard
{
//    [_comment resignFirstResponder];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


-(void)webViewDidStartLoad:(UIWebView *)webView{
    [self beginWaitCircle];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [self stopWaitCircle];
}
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    [self stopWaitCircle];
}
//

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


@end
