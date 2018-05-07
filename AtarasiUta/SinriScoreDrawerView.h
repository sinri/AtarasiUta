//
//  SinriScoreDrawerView.h
//  AtarasiUta
//
//  Created by 倪 李俊 on 2017/1/6.
//  Copyright © 2017年 com.sinri. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SinriScoreDrawerView : UIView

@property Boolean autoCellWidth;

- (instancetype)initWithFrame:(CGRect)frame withScoreText:(NSString*)scoreText;
- (instancetype)initWithFrame:(CGRect)frame withScoreText:(NSString*)scoreText autoCellWidth:(Boolean)autoCellWidth;

-(void)setScoreText:(NSString*)scoreText;
-(void)setBoardColor:(UIColor *)boardColor;
-(void)setPenColor:(UIColor *)penColor;

//+(void)test;

@end
