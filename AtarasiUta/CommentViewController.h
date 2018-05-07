//
//  CommentViewController.h
//  AtarasiUta
//
//  Created by 倪 李俊 on 2016/12/20.
//  Copyright © 2016年 com.sinri. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import <WebKit/WebKit.h>
#import "SinriAppHelper.h"

@interface CommentViewController : UIViewController <UIWebViewDelegate>

@property NSString *draftId;
@property NSDictionary *draftInfo;

//-(instancetype)initWithDraftId:(NSString*)draft_id;
-(instancetype)initWithDraftInfo:(NSDictionary*)draft_info;

@end
