//
//  SinriAppHelper.m
//  AtarasiUta
//
//  Created by 倪 李俊 on 2016/12/28.
//  Copyright © 2016年 com.sinri. All rights reserved.
//

#import "SinriAppHelper.h"

@implementation SinriAppHelper

@end

@implementation UIViewController (waiting_circle)

//@dynamic SinriAppHelperAI;

-(NSInteger)SinriAppHelperAI_TAG{
    return 2016122801;
}
-(UIActivityIndicatorView*)SinriAppHelperAI{
    UIActivityIndicatorView * ai=(UIActivityIndicatorView*)[self.view viewWithTag:[self SinriAppHelperAI_TAG]];
    return ai;
}

-(void)setSinriAppHelperAI:(UIActivityIndicatorView*)ai{
    UIActivityIndicatorView* currentAI=[self SinriAppHelperAI];
    if(currentAI){
        [currentAI setTag:0];
        [currentAI removeFromSuperview];
    }
//    [[self SinriAppHelperAI] setTag:0];
    [ai setTag:[self SinriAppHelperAI_TAG]];
}

-(void)beginWaitCircle{
    [self stopWaitCircle];
    
    UIActivityIndicatorView * currentAI = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [self setSinriAppHelperAI:currentAI];
    
    currentAI.center = self.view.center;//只能设置中心，不能设置大小
    [self.view addSubview:currentAI];
    currentAI.color = [UIColor redColor]; // 改变圈圈的颜色为红色； iOS5引入
    [currentAI startAnimating]; // 开始旋转
    
    [self.view setUserInteractionEnabled:NO];
    
}
-(void)stopWaitCircle{
    UIActivityIndicatorView * currentAI=[self SinriAppHelperAI];
    if(currentAI){
        [currentAI stopAnimating]; // 结束旋转
        [currentAI setHidesWhenStopped:YES]; //当旋转结束时隐藏
        [currentAI removeFromSuperview];
        currentAI = nil;
        [self setSinriAppHelperAI:nil];
        NSLog(@"stopWaitCircle");
    }
    [self.view setUserInteractionEnabled:YES];
}

@end

@implementation UIViewController (network)

-(NSURLSessionDataTask* _Nullable)executeAsyncRequest:(NSURLRequest * _Nonnull)request doneCallback:(void (^ _Nullable)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error,  id _Nullable weakSelf))doneCallback failCallback:(void (^ _Nullable)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error, id _Nullable weakSelf))failCallback
{
    __weak id instance= self;
    NSURLSessionConfiguration * conf = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession * session = [NSURLSession sessionWithConfiguration:conf];
    NSURLSessionDataTask * task=[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"RESP=%@ ERROR=%@",response,error);
        
        if(error){
            dispatch_async(dispatch_get_main_queue(), ^(void){
                if(failCallback!=nil){
                    failCallback(data,response,error,instance);
                }
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^(void){
                if(doneCallback!=nil){
                    doneCallback(data,response,error,instance);
                }
            });
        }
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [instance stopWaitCircle];
        });
        NSLog(@"stop wait cricle in execute request");
        
//        NSError * jsonError;
//        NSDictionary * dict=[NSJSONSerialization JSONObjectWithData:data options:(NSJSONReadingMutableLeaves) error:&jsonError];
//        if([[dict objectForKey:@"result"] isEqualToString:@"OK"]){
//            dispatch_async(dispatch_get_main_queue(), ^(void){
//                // メインスレッドで処理する内容
//                [instance setDraft_info:[[dict objectForKey:@"data"]objectForKey:@"draft"]];
//                
//                [instance updateWebViewContentWithDraftInfo];
//            });
//        }else{
//            dispatch_async(dispatch_get_main_queue(), ^(void){
//                [instance stopWaitCircle];
//            });
//        }
    }];
    
    [self beginWaitCircle];
    [task resume];
    return task;
}

-(void)alertNetworkError:(NSError * _Nullable)error
          ConfirmHandler:(void (^ __nullable)(UIAlertAction *action))confirmHandler
{
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"Warning"
                                message:[NSString stringWithFormat:@"Network Error: %@",[error localizedDescription]]
                                preferredStyle:UIAlertControllerStyleAlert
                                ];
    [alert addAction:[UIAlertAction
                      actionWithTitle:@"OK"
                      style:UIAlertActionStyleDestructive
                      handler:confirmHandler
                      ]
     ];
    [self presentViewController:alert animated:YES completion:^{
        //
    }];
}

@end
