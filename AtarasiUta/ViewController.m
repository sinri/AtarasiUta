//
//  ViewController.m
//  AtarasiUta
//
//  Created by 倪 李俊 on 2016/12/19.
//  Copyright © 2016年 com.sinri. All rights reserved.
//

#import "ViewController.h"
#import "WebPageMaker.h"
#import "CommentViewController.h"

@interface ViewController ()

@property UIActivityIndicatorView *testActivityIndicator;
@property UIDeviceOrientation currentOrientation;

@end

@implementation ViewController

-(instancetype)initWithScore:(NSString *)score inBook:(NSString *)book{
    self=[super init];
    if(self){
        _score_code=score;
        _book_code=book;
    }
    return self;
}

-(instancetype)initWithDraftID:(NSString *)draftId{
    self=[super init];
    if(self){
        _draft_id=draftId;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [[self navigationItem] setTitle:@"Loading"];
    _currentOrientation=UIDeviceOrientationUnknown;
    
    _webView = [[UIWebView alloc]init];
    [[_webView scrollView]setBounces:NO];
    [_webView setScalesPageToFit:YES];
    [_webView setDelegate:self];
    [self.view addSubview:_webView];
    
    [self updateWebViewFrame];
    [self updateWebViewContent];
}

-(void)viewDidAppear:(BOOL)animated
{
    //开始生成 设备旋转 通知
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    
    //添加 设备旋转 通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleDeviceOrientationDidChange:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil
     ];
}



-(void)viewDidDisappear:(BOOL)animated
{
    //销毁 设备旋转 通知
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIDeviceOrientationDidChangeNotification
                                                  object:nil
     ];
    
    //结束 设备旋转通知
    [[UIDevice currentDevice]endGeneratingDeviceOrientationNotifications];
    
}

-(void)updateWebViewContent{
    if(_draft_id){
        if(!_draft_info){
            [self runApiGetDraftDetail];
        }else{
            [self updateWebViewContentWithDraftInfo];
        }
    }else{
        NSString * code=[WebPageMaker makeHTMLFromBook:_book_code score:_score_code width:self.view.frame.size.width-10];
        [_webView loadHTMLString:code baseURL:NULL];
        
        [[self navigationItem]setTitle:[NSString stringWithFormat:@"%@ - %@",_book_code,_score_code]];
    }
}

-(void)updateWebViewContentWithDraftInfo{
    NSString * score_text=[_draft_info objectForKey:@"score"];
    NSString * code=[WebPageMaker makeHTMLWithScoreText:score_text width:[[self view] frame].size.width-10];
    [[self webView] loadHTMLString:code baseURL:NULL];
    
    [[self navigationItem]setTitle:[NSString stringWithFormat:@"%@ - %@",[_draft_info objectForKey:@"score_code"],[_draft_info objectForKey:@"score_title"]]];
    
    [self displayCommentEntrance];
}

- (void)updateWebViewFrame{
    [_webView setFrame:(CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height))];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handleDeviceOrientationDidChange:(UIInterfaceOrientation)interfaceOrientation
{
    //1.获取 当前设备 实例
    UIDevice *device = [UIDevice currentDevice] ;
    
    /**
     *  2.取得当前Device的方向，Device的方向类型为Integer
     *
     *  必须调用beginGeneratingDeviceOrientationNotifications方法后，此orientation属性才有效，否则一直是0。orientation用于判断设备的朝向，与应用UI方向无关
     *
     *  @param device.orientation
     *
     */
    /*
    switch (device.orientation) {
        case UIDeviceOrientationFaceUp:
            NSLog(@"屏幕朝上平躺");
            break;
            
        case UIDeviceOrientationFaceDown:
            NSLog(@"屏幕朝下平躺");
            break;
        case UIDeviceOrientationUnknown:
            //系統無法判斷目前Device的方向，有可能是斜置
            NSLog(@"未知方向");
            break;
            
        case UIDeviceOrientationLandscapeLeft:
            NSLog(@"屏幕向左横置");
            break;
            
        case UIDeviceOrientationLandscapeRight:
            NSLog(@"屏幕向右橫置");
            break;
            
        case UIDeviceOrientationPortrait:
            NSLog(@"屏幕直立");
            break;
            
        case UIDeviceOrientationPortraitUpsideDown:
            NSLog(@"屏幕直立，上下顛倒");
            break;
            
        default:
            NSLog(@"无法辨识");
            break;
    }
    */
    BOOL needRefresh=NO;
    if(_currentOrientation==UIDeviceOrientationUnknown){
        if(device.orientation==UIDeviceOrientationLandscapeLeft
           || device.orientation==UIDeviceOrientationLandscapeRight
           || device.orientation==UIDeviceOrientationPortrait
           || device.orientation==UIDeviceOrientationPortraitUpsideDown
        ){
            _currentOrientation=device.orientation;
        }
        needRefresh=YES;
    }else{
        if(
           device.orientation!=_currentOrientation
           && (
               device.orientation==UIDeviceOrientationLandscapeLeft
               || device.orientation==UIDeviceOrientationLandscapeRight
               || device.orientation==UIDeviceOrientationPortrait
               || device.orientation==UIDeviceOrientationPortraitUpsideDown
               )
        ){
            needRefresh=YES;
        }
    }
    
    if(needRefresh){
        [self updateWebViewFrame];
        [self updateWebViewContent];
    }
}

/////

-(void)displayCommentEntrance{
    UIBarButtonItem *rightBtn=[[UIBarButtonItem alloc]initWithTitle:@"Feedback" style:(UIBarButtonItemStylePlain) target:self action:@selector(openCommentVC)];
    [[self navigationItem]setRightBarButtonItem:rightBtn];
}

-(void)openCommentVC{
    CommentViewController * vc =[[CommentViewController alloc]initWithDraftInfo:_draft_info];
    [[self navigationController]pushViewController:vc animated:YES];
}

////

-(void)webViewDidStartLoad:(UIWebView *)webView{
    [self beginWaitCircle];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [self stopWaitCircle];
}
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    [self stopWaitCircle];
}

////

#pragma mark - beneath NETWORK related

-(NSString*)getDraftUrlForId:(NSString*)draft_id{
    return [NSString stringWithFormat:@"https://sinri.cc/SikaScoreBook/ajaxGetScoreDraft/%@",draft_id];
}

-(void)runApiGetDraftDetail{
    __weak id instance= self;
    NSURLSessionConfiguration * conf = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession * session = [NSURLSession sessionWithConfiguration:conf];
    NSMutableURLRequest * request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:[self getDraftUrlForId:_draft_id]]];
    NSURLSessionDataTask * task=[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"RESP=%@ ERROR=%@",response,error);
        NSError * jsonError;
        NSDictionary * dict=[NSJSONSerialization JSONObjectWithData:data options:(NSJSONReadingMutableLeaves) error:&jsonError];
        if([[dict objectForKey:@"result"] isEqualToString:@"OK"]){
            dispatch_async(dispatch_get_main_queue(), ^(void){
                // メインスレッドで処理する内容
                [instance setDraft_info:[[dict objectForKey:@"data"]objectForKey:@"draft"]];
                
                [instance updateWebViewContentWithDraftInfo];
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^(void){
                [instance stopWaitCircle];
            });
        }
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

@end
