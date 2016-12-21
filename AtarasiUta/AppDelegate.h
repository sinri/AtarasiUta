//
//  AppDelegate.h
//  AtarasiUta
//
//  Created by 倪 李俊 on 2016/12/19.
//  Copyright © 2016年 com.sinri. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "ViewController.h"
//#import "IndexViewController.h"
#import "OnlineIndexViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property UINavigationController *navController;
//@property ViewController *mainVC;
//@property IndexViewController* indexVC;
@property OnlineIndexViewController * onlineIndexVC;

@end

