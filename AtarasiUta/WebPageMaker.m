//
//  WebPageMaker.m
//  AtarasiUta
//
//  Created by 倪 李俊 on 2016/12/19.
//  Copyright © 2016年 com.sinri. All rights reserved.
//

#import "WebPageMaker.h"

@implementation WebPageMaker

+(NSString*)makeHTMLWithScoreText:(NSString*)score_text width:(float)width{
    NSString * page_temp_file=[[NSBundle mainBundle]pathForResource:@"page_temp" ofType:@"htm" inDirectory:NULL forLocalization:NULL];
    NSString * page_temp=[[NSString alloc]initWithContentsOfFile:page_temp_file encoding:NSUTF8StringEncoding error:NULL];
    
    NSString * SSD_file=[[NSBundle mainBundle]pathForResource:@"SinriScoreDrawer" ofType:@"js" inDirectory:NULL forLocalization:NULL];
    NSString * SSD=[[NSString alloc]initWithContentsOfFile:SSD_file encoding:NSUTF8StringEncoding error:NULL];
    
    NSString * code=[NSString stringWithFormat:page_temp,width,score_text,SSD];
    return code;
}

+(NSString*)makeHTMLFromBook:(NSString *)book_code score:(NSString *)score_code width:(float)width{
    NSString * score_text=[WebPageMaker scoreTextOfScore:score_code inBook:book_code];
    
    return [WebPageMaker makeHTMLWithScoreText:score_text width:width];
}

+(NSArray*)getBookList{
    NSError * error;
    NSString * resourcePath = [[NSBundle mainBundle] resourcePath];
    NSString * documentsPath = [resourcePath stringByAppendingPathComponent:@"Books"];
    NSArray * directoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsPath error:&error];
    return directoryContents;
}

+(NSArray*)getScoreListInBook:(NSString*)book_code{
    NSString * resourcePath = [[NSBundle mainBundle] resourcePath];
    NSLog(@"resourcePath=%@",resourcePath);
    NSString * documentsPath = [[resourcePath stringByAppendingPathComponent:@"Books"] stringByAppendingPathComponent:book_code];
    NSLog(@"documentsPath=%@",documentsPath);
    NSError * error;
    NSArray * directoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsPath error:&error];
    NSLog(@"directoryContents=%@,error=%@",directoryContents,error);
    return directoryContents;
}

+(NSString*)scoreTextOfScore:(NSString*)score_code inBook:(NSString*)book_code{
    NSString * resourcePath = [[NSBundle mainBundle] resourcePath];
    NSLog(@"resourcePath=%@",resourcePath);
    NSString * documentsPath = [[resourcePath stringByAppendingPathComponent:@"Books"] stringByAppendingPathComponent:book_code];
    NSLog(@"documentsPath=%@",documentsPath);
    NSString * file_path=[documentsPath stringByAppendingPathComponent:score_code];
    NSError * error=NULL;
    NSString * score_text=[[NSString alloc]initWithContentsOfFile:file_path encoding:NSUTF8StringEncoding error:&error];
    return score_text;
}

#pragma mark - 



@end
