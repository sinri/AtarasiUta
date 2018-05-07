//
//  SinriScoreCellData.h
//  AtarasiUta
//
//  Created by 倪 李俊 on 2017/1/10.
//  Copyright © 2017年 com.sinri. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    SFN_NONE=0,
    SFN_SHARP=1,
    SFN_FLAT=2,
    SFN_NATURAL=3
} SFN_DEF;

@interface SinriScoreCellData : NSObject

@property Boolean indentation;
@property NSString *note;
@property NSString *specialNote;

@property NSInteger hasLongLine;
@property NSInteger timesDivided;
@property NSInteger timesMultiply;

@property NSString *effectWord;
@property Boolean title;

@property Boolean keepStart;
@property Boolean keepEnd;

//@property Boolean sharp;
//@property Boolean flat;
//@property Boolean natural;
@property SFN_DEF SFN;

@property NSInteger underpoints;
@property NSInteger upperpoints;
@property NSInteger underlines;

@property Boolean dot;
@property Boolean fermata;
@property Boolean triplets;

@property NSInteger x;
@property NSInteger y;

@end
