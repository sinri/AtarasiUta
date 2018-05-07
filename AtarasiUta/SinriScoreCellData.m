//
//  SinriScoreCellData.m
//  AtarasiUta
//
//  Created by 倪 李俊 on 2017/1/10.
//  Copyright © 2017年 com.sinri. All rights reserved.
//

#import "SinriScoreCellData.h"

@implementation SinriScoreCellData

-(instancetype)init{
    self = [super init];
    if(self){
        _indentation=NO;
        _note=@"";
        _specialNote=nil;
        
        _hasLongLine=0;
        _timesDivided=0;
        _timesMultiply=0;
        
        _effectWord=nil;
        _title=NO;
        
        _keepStart=NO;
        _keepEnd=NO;
        
//        _sharp=NO;
//        _flat=NO;
//        _natural=NO;
        _SFN=SFN_NONE;
        
        _underpoints=0;
        _upperpoints=0;
        _underlines=0;
        _dot=NO;
        _fermata=NO;
        _triplets=NO;
        
        _x=0;
        _y=0;
    }
    return self;
}

-(NSString *)description{
    NSString * s= [NSString stringWithFormat:@"{SSCD:"];
    if(_indentation){
        s=[s stringByAppendingString:@" INDENTATION"];
    }
    if(_specialNote){
        s=[s stringByAppendingFormat:@" [%@]",_specialNote];
    }
    if(_effectWord){
        s=[s stringByAppendingFormat:@" : %@",_effectWord];
    }
    if(_title){
        s=[s stringByAppendingString:@" TITLE"];
    }
    
    s=[s stringByAppendingFormat:@"HLL=%ld,TD=%ld,TM=%ld",(long)_hasLongLine,(long)_timesDivided,(long)_timesMultiply];
    
    s=[s stringByAppendingString:@" | "];
    
    if(_keepStart){
        s=[s stringByAppendingString:@"("];
    }
    
    for(NSInteger i=0;i<_underpoints;i++){
        s=[s stringByAppendingString:@"<"];
    }
    if(_SFN==SFN_SHARP){
        s=[s stringByAppendingString:@"#"];
    }else if(_SFN==SFN_FLAT){
        s=[s stringByAppendingString:@"b"];
    }else if(_SFN==SFN_NATURAL){
        s=[s stringByAppendingString:@"N"];
    }
    s=[s stringByAppendingString:_note];
    for(NSInteger i=0;i<_upperpoints;i++){
        s=[s stringByAppendingString:@">"];
    }
    for(NSInteger i=0;i<_underlines;i++){
        s=[s stringByAppendingString:@"_"];
    }
    if(_dot){
        s=[s stringByAppendingString:@" ."];
    }
    if(_fermata){
        s=[s stringByAppendingString:@" ~"];
    }
    if(_triplets){
        s=[s stringByAppendingString:@" 1/3"];
    }
    
    if(_keepEnd){
        s=[s stringByAppendingString:@")"];
    }
    
    s=[s stringByAppendingString:@"}"];
    
    return s;
}

@end
