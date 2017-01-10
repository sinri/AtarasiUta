//
//  SinriScoreDrawerParser.h
//  AtarasiUta
//
//  Created by 倪 李俊 on 2017/1/6.
//  Copyright © 2017年 com.sinri. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SinriScoreDrawerParser : NSObject

@property Boolean autoCellWidth;

-(instancetype)initWithScoreText:(NSString*)text;

-(NSArray*)parseScoreText;

+(NSNumber*)stringToNumber:(NSString*)s;
+(NSArray*)stringToNSCharArray:(NSString*)string;

@end
