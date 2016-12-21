//
//  WebPageMaker.h
//  AtarasiUta
//
//  Created by 倪 李俊 on 2016/12/19.
//  Copyright © 2016年 com.sinri. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WebPageMaker : NSObject
+(NSString*)makeHTMLWithScoreText:(NSString*)score_text width:(float)width;
+(NSString*)makeHTMLFromBook:(NSString*)book_code score:(NSString*)score_code width:(float)width;
+(NSArray*)getBookList;
+(NSArray*)getScoreListInBook:(NSString*)book_code;
@end
