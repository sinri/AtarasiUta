//
//  ViewController.h
//  AtarasiUta
//
//  Created by 倪 李俊 on 2016/12/19.
//  Copyright © 2016年 com.sinri. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SinriAppHelper.h"

@interface ViewController : UIViewController <UIWebViewDelegate>

@property UIWebView *webView;


@property NSString *draft_id;
@property NSString *score_code;
@property NSString *book_code;
@property NSDictionary *draft_info;

-(instancetype)initWithScore:(NSString*)score inBook:(NSString*)book;

-(instancetype)initWithDraftID:(NSString*)draftId;

@end

