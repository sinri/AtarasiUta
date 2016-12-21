//
//  ClientAgent.m
//  AtarasiUta
//
//  Created by 倪 李俊 on 2016/12/20.
//  Copyright © 2016年 com.sinri. All rights reserved.
//

#import "ClientAgent.h"

@implementation ClientAgent

+(NSString*)getClientSNKey{
    return @"CLIENT_SN";
}

+(NSString*)makeClientSN{
    NSString * client_sn=[[NSUUID UUID]UUIDString];
    [[NSUserDefaults standardUserDefaults]setObject:client_sn forKey:[ClientAgent getClientSNKey]];
    return client_sn;
}

+(NSString*)getClientSN{
    NSString*client_sn=[[NSUserDefaults standardUserDefaults]stringForKey:[ClientAgent getClientSNKey]];
    if(!client_sn){
        client_sn=[ClientAgent makeClientSN];
    }
    if(!client_sn){
        client_sn=@"UNKNOWN IOS DEVICE";
    }
    return client_sn;
}

@end
