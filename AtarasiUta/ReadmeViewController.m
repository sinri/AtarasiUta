//
//  ReadmeViewController.m
//  AtarasiUta
//
//  Created by 倪 李俊 on 2016/12/28.
//  Copyright © 2016年 com.sinri. All rights reserved.
//

#import "ReadmeViewController.h"

@interface ReadmeViewController ()
@property UIWebView * webView;
@end

@implementation ReadmeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[self navigationItem]setTitle:@"Readme"];
    
    _webView = [[UIWebView alloc]init];
    [[_webView scrollView]setBounces:NO];
    [_webView setScalesPageToFit:YES];
    [_webView setDelegate:self];
    [self.view addSubview:_webView];
    
    [_webView setFrame:(CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height))];
    
    NSMutableURLRequest * request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://sinri.cc/SikaScoreBook/atarasiuta_readme"]];
    NSLog(@"request as %@",request);
    [_webView loadRequest:request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

///
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    NSLog(@"Readme VC starting: %@",request);
    
    return YES;
}

-(void)webViewDidStartLoad:(UIWebView *)webView{
    [self beginWaitCircle];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [self stopWaitCircle];
}
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    [self stopWaitCircle];
}

@end
