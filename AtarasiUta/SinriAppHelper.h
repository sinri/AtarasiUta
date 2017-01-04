//
//  SinriAppHelper.h
//  AtarasiUta
//
//  Created by 倪 李俊 on 2016/12/28.
//  Copyright © 2016年 com.sinri. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SinriAppHelper : NSObject

@end

@interface UIViewController (waiting_circle)

//@property UIActivityIndicatorView *SinriAppHelperAI;
-(void)beginWaitCircle;
-(void)stopWaitCircle;

@end

@interface UIViewController (network)
//-(void)executeAsyncRequest:(NSURLRequest*)request doneCallback:(dispatch_block_t)doneCallback failCallback:(dispatch_block_t)failCallback ;
-(NSURLSessionDataTask * _Nullable)executeAsyncRequest:(NSURLRequest * _Nonnull)request doneCallback:(void (^ _Nullable)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error,  id _Nullable weakSelf))doneCallback failCallback:(void (^ _Nullable)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error, id _Nullable weakSelf))failCallback;

-(void)alertNetworkError:(NSError * _Nullable)error
          ConfirmHandler:(void (^ __nullable)(UIAlertAction * _Nullable action))confirmHandler;

@end
