//
//  SinriScoreDrawerView.m
//  AtarasiUta
//
//  Created by 倪 李俊 on 2017/1/6.
//  Copyright © 2017年 com.sinri. All rights reserved.
//

#import "SinriScoreDrawerView.h"
#import "SinriScoreDrawerParser.h"
#import "WebPageMaker.h"

@interface SinriScoreDrawerView ()

@property NSString *theScoreText;
@property NSArray *theParsedScore;
@property UIColor *theBoardColor;
@property UIColor *thePenColor;

@property NSMutableArray * keep_sign_set;

@end

@implementation SinriScoreDrawerView

- (instancetype)initWithFrame:(CGRect)frame withScoreText:(NSString*)scoreText{
    self= [super initWithFrame:frame];
    if(self){
        _theBoardColor=[UIColor whiteColor];
        _thePenColor=[UIColor blackColor];
        _autoCellWidth=YES;
        [self setScoreText:scoreText];
        [self drawScore];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame withScoreText:(NSString*)scoreText autoCellWidth:(Boolean)autoCellWidth{
    self= [super initWithFrame:frame];
    if(self){
        _theBoardColor=[UIColor whiteColor];
        _thePenColor=[UIColor blackColor];
        _autoCellWidth=autoCellWidth;
        [self setScoreText:scoreText];
        [self drawScore];
    }
    return self;
}

-(void)generalInit{
    [self addObserver:self forKeyPath:@"bounds" options:0 context:nil];
}

-(void)parseScoreText{
    SinriScoreDrawerParser *parser=[[SinriScoreDrawerParser alloc]initWithScoreText:_theScoreText];
    [parser setAutoCellWidth:_autoCellWidth];
    _theParsedScore=[parser parseScoreText];
    NSLog(@"===parseScoreText=== \nPARSED:\n%@\n===OVER===",_theParsedScore);
}

-(void)drawScore{
    [self loadScoreData:_theParsedScore cellSize:@{@"w":@30,@"h":@"50"} notAutoCanvasSize:YES];
}

#pragma -

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self && [keyPath isEqualToString:@"bounds"]) {
        // do your stuff, or better schedule to run later using performSelector:withObject:afterDuration:
        [self performSelector:@selector(drawScore) withObject:nil afterDelay:0];
    }
}

- (void)drawRect:(CGRect)rect {
    // contextを取得
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //　残っていた痕跡をクリア
    CGContextClearRect(context, rect);
    
    // 背景色が必要ならここで設定
    
    [_theBoardColor setFill];
    [_theBoardColor setStroke];
    
    [self drawFilledRect:rect inContent:context];
    
    // 直線の端のスタイル。ここは四角いが、円形になるも可能
    CGContextSetLineCap(context, kCGLineCapSquare);
    // 直線の幅を設定
    CGContextSetLineWidth(context, 1.0);
    
    // TODO: 具体的な描くコード
    
    [self drawScore];
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

#pragma property gstter

-(void)setScoreText:(NSString*)scoreText{
    _theScoreText=scoreText;
    [self parseScoreText];
}

-(void)setBoardColor:(UIColor *)boardColor{
    _theBoardColor=boardColor;
}

-(void)setPenColor:(UIColor *)penColor{
    _thePenColor=penColor;
}

#pragma parse codes

-(void)loadScoreData:(NSArray*)score_data cellSize:(NSDictionary*)cell_size notAutoCanvasSize:(Boolean)no_auto_canvas_size{
    Boolean has_numbered_lyric=NO;
    for(int checker=0;checker<[score_data count];checker++){
        if([[score_data[checker] objectAtIndex:0] objectForKey:@"title"]){
            continue;
        }
        if([[score_data[checker] objectAtIndex:0] objectForKey:@"indentation"]){
            has_numbered_lyric=YES;
            break;
        }
    }
    
    NSDictionary * score_size=[self getScoreSize:score_data];
    
    CGFloat s=40;
    CGFloat ss=40;
    CGFloat k=24;
    CGFloat kk=24;
    
    {
        CGFloat s_from_h=(self.frame.size.height/[[score_size objectForKey:@"h"]intValue]);
        CGFloat s_from_w=(self.frame.size.width/[[score_size objectForKey:@"w"]intValue]);
        s=MIN(s_from_w, s_from_h);
        k=floor(s*0.6);
        ss=s;
        kk=k;
    }
    
    if(cell_size && [cell_size objectForKey:@"width"] && [cell_size objectForKey:@"height"]){
        ss=[[cell_size objectForKey:@"width"] floatValue];
        s=[[cell_size objectForKey:@"height"] floatValue];
        k=floor(s*0.6);
        kk=floor(ss*0.6);
        
        //modify canvas
        if(!no_auto_canvas_size){
            [self setFrame:(CGRectMake(self.frame.origin.x, self.frame.origin.y, [[cell_size objectForKey:@"width"] floatValue]*ss, [[cell_size objectForKey:@"height"] floatValue]*s) )];
        }
    }
    
    NSDictionary * entire_offset=@{
                                   @"x":[NSNumber numberWithDouble:floor((self.frame.size.width-ss*[[score_size objectForKey:@"w"]intValue])/2)],
                                   @"y":@0,
                                   };
    
    for(NSInteger y=0;y<[[score_size objectForKey:@"h"]intValue]-2;y++){
        NSArray * score_line=[score_data objectAtIndex:y];
        _keep_sign_set=[@[] mutableCopy];
        
        /* new idea */
        NSUInteger real_cell_in_this_row=[score_line count];
        CGFloat real_ss=ss;
        CGFloat real_kk=kk;
        
        for(int x=0;x<[[score_size objectForKey:@"w"]intValue]-2;x++){
            if([score_line objectAtIndex:x]){
                real_ss=ss;
                real_kk=kk;
                if(_autoCellWidth && real_cell_in_this_row>0 && x>0 && has_numbered_lyric){
                    real_ss=(self.frame.size.width-[[entire_offset objectForKey:@"x"]floatValue]*2-3*ss)/(real_cell_in_this_row-1);
                    real_kk=floor(real_ss*0.6);
                }
                NSDictionary * cell_attr=@{
                                           @"s":[NSNumber numberWithFloat:s*1.0],//cell's total height
                                           @"k":[NSNumber numberWithFloat:k*1.0],//char area height
                                           @"ss":[NSNumber numberWithFloat:real_ss*1.0],//cell's total width
                                           @"kk":[NSNumber numberWithFloat:real_kk*1.0],//char area width
                                           @"min_ss":[NSNumber numberWithFloat:ss*1.0],
                                           @"min_kk":[NSNumber numberWithFloat:kk*1.0],
                                           @"cell_offset_x":[NSNumber numberWithFloat:([[entire_offset objectForKey:@"x"]floatValue]+real_ss*x+ss)],
                                           @"cell_offset_y":[NSNumber numberWithFloat:(s*y+s)],
                                           @"score_size":score_size,
                                           @"t":[NSNumber numberWithFloat:floor((s-k)/2.0)],
                                           @"tt":[NSNumber numberWithFloat:floor((real_ss-real_kk)/2.0)],
                                           };
                [self printOneScoreCell:cell_attr score:[score_line objectAtIndex:x] showCellBorder:NO];
            }
        }
        for(int keep_index=0;keep_index<[_keep_sign_set count];keep_index++){
            NSDictionary * keep_info=[_keep_sign_set objectAtIndex: keep_index];
            if(keep_info && [keep_info objectForKey:@"start"] && [keep_info objectForKey:@"end"]){
                
                [self drawArcForKeepFromPointStartX:[[[keep_info objectForKey:@"start"]objectForKey:@"x"]floatValue]
                                        toPointEndX:[[[keep_info objectForKey:@"end"]objectForKey:@"x"]floatValue]
                                           onPointY:MIN([[[keep_info objectForKey:@"start"]objectForKey:@"y"]floatValue], [[[keep_info objectForKey:@"end"]objectForKey:@"y"]floatValue])
                                          withOmega:MIN((([[[keep_info objectForKey:@"end"]objectForKey:@"x"]floatValue]-[[[keep_info objectForKey:@"start"]objectForKey:@"x"]floatValue])*0.2), (k-kk)/2.0)
                                         isTriplets:[[[keep_info objectForKey:@"start"]objectForKey:@"triplets"]boolValue]
                 ];
            }
        }
    }
}

-(NSDictionary*)getScoreSize:(NSArray*)score_data{
    NSUInteger h=[score_data count]+2;
    NSUInteger w=0;
    for(int i=0;i<[score_data count];i++){
        if([score_data[i] count]>w){
            w=[score_data[i] count];
        }
    }
    w+=2;
    return @{@"h":[NSNumber numberWithUnsignedInteger:h],@"w":[NSNumber numberWithUnsignedInteger:w]};
}

-(void)printOneScoreCell:(NSDictionary*)cell_attr score:(NSDictionary*)score showCellBorder:(Boolean)show_cell_border{
    if(show_cell_border){
        [self debugDrawCellBorder:cell_attr];
    }
    [[UIColor blackColor]setStroke];
    [[UIColor blackColor]setFill];
    
//    if(typeof score === 'string'){
//        this.printOneScoreCellWithPureString(cell_attr,score[0]);
//    }
    
//    if([score isKindOfClass:[NSString class]]){
        // not support yet
//    }
    
    [self printOneScoreCellWithObject:cell_attr withScore:score];
}

-(void)debugDrawCellBorder:(NSDictionary*)cell_attr{
    [[UIColor blueColor] setStroke];
    [self drawStrokedRect:CGRectMake(
                                     [[cell_attr objectForKey:@"cell_offset_x"]floatValue],
                                     [[cell_attr objectForKey:@"cell_offset_y"]floatValue],
                                     [[cell_attr objectForKey:@"ss"]floatValue],
                                     [[cell_attr objectForKey:@"s"]floatValue]
                                     )
                inContent:UIGraphicsGetCurrentContext()
     ];
    [[UIColor lightGrayColor]setStroke];
    [self drawStrokedRect:CGRectMake(
                                     [[cell_attr objectForKey:@"cell_offset_x"]floatValue]+[[cell_attr objectForKey:@"tt"]floatValue],
                                     [[cell_attr objectForKey:@"cell_offset_y"]floatValue]+[[cell_attr objectForKey:@"t"]floatValue],
                                     [[cell_attr objectForKey:@"kk"]floatValue],
                                     [[cell_attr objectForKey:@"k"]floatValue]
                                     )
                inContent:UIGraphicsGetCurrentContext()
     ];
}

-(void)printOneScoreCellWithObject:(NSDictionary*)cell_attr withScore:(NSDictionary*)score{
    //note
    [self printOneScoreCellWithObjectForText:cell_attr withScore:score];
    
    // SFND
    [self printOneScoreCellWithObjectForSFN:cell_attr withScore:score];
    
    //upper part
    CGFloat upper_y=[self printOneScoreCellWithObjectForUpper:cell_attr withScore:score];
    
    //under part
    [self printOneScoreCellWithObjectForUnder:cell_attr withScore:score];
    
    //keep
    [self printOneScoreCellWithObjectForKeep:cell_attr withScore:score whenUpperY:upper_y];
}

-(void)printOneScoreCellWithObjectForText:(NSDictionary*)cell_attr withScore:(NSDictionary*)score{
    NSString * note_text=@"";
    if([score objectForKey:@"note"]){
        note_text=[[score objectForKey:@"note"] substringWithRange:NSMakeRange(0, 1)];
    }
    if([score objectForKey:@"special_note"]){
        NSDictionary * mp=@{
            @"REPEAT_START_DOUBLE":@"‖:",
            @"REPEAT_END_DOUBLE":@":‖",
            @"REPEAT_START_SINGLE":@"|:",
            @"REPEAT_END_SINGLE":@":|",
            @"LONGER_LINE":@"ー",
            @"FIN":@"‖",
            @"PHARSE_FIN":@"|",
            @"DOT":@"・"
            };
        if([[score objectForKey:@"special_note"] isEqualToString: @"AS_IS"] && [score objectForKey:@"note"]){
            note_text=[score objectForKey:@"note"];
        }else if([mp objectForKey:[score objectForKey:@"special_note"]]){
            note_text=[mp objectForKey:[score objectForKey:@"special_note"]];
        }
    }
    
    CGPoint text_point=[self getCertainPointOfCell:cell_attr withType:@"center_of_cell"];
    NSString * font_setting=@"sans-serif";
    if([score objectForKey:@"title"]){
        //text_point as cancvs center
        /*
        text_point=@[
                     [NSNumber numberWithDouble: self.frame.size.width/2],
                     [NSNumber numberWithDouble: [[cell_attr objectForKey:@"cell_offset_y"]floatValue]+[[cell_attr objectForKey:@"t"]floatValue]+[[cell_attr objectForKey:@"k"]floatValue]*0.5]
                     ];
         */
        text_point=CGPointMake(self.frame.size.width/2.0, [[cell_attr objectForKey:@"cell_offset_y"]floatValue]+[[cell_attr objectForKey:@"t"]floatValue]+[[cell_attr objectForKey:@"k"]floatValue]*0.5);
        //ctx.measureText("foo").width 要不要考虑后面自动调整字体大小，现在还是算了
        font_setting=@"serif";//for ios, Palatino
    }
    if([score objectForKey:@"indentation"]){
        //line head 1,2,3... or All Sing
        font_setting=@"serif";//for ios, Palatino
    }
    /*
    this.writeText(
                   note_text,
                   text_point,
                   {
                   font:""+(Math.min(cell_attr.k,cell_attr.min_kk))+"px "+font_setting,
                   textAlign:"center",//(score.title?"left":"center"),
                   textBaseline:"middle"
                   }
                   );
     */
    //TODO
    [self writeText:note_text pointBase:(CGPointMake(0, 0)) requirements:nil];
}
-(void)printOneScoreCellWithObjectForSFN:(NSDictionary*)cell_attr withScore:(NSDictionary*)score{
    NSString* sfn_char=@"";
    if([[score objectForKey:@"sharp"]boolValue]){
        sfn_char=@"♯";
    }else if([[score objectForKey:@"flat"]boolValue]){
        sfn_char=@"♭";
    }else if([[score objectForKey:@"natual"]boolValue]){
        sfn_char=@"♮";
    }
    if(![sfn_char isEqualToString:@""]){
        /*
        this.writeText(
                       sfn_char,
                       this.getCertainPointOfCell(cell_attr,'SFN'),
                       {
                       font:''+(0.8*Math.min(cell_attr.k,cell_attr.min_kk))+'px sans-serif',
                       textAlign:'center',
                       textBaseline:'middle'
                       }
                       );
         */
        //TODO
        [self writeText:sfn_char pointBase:(CGPointMake(0, 0)) requirements:nil];
    }
    
    if([[score objectForKey:@"dot"]boolValue]){
        /*
        this.drawDot(
                     this.getCertainPointOfCell(cell_attr,'score_dot'),
                     this.helper.NUM_SCALE(2,30,cell_attr.ss) // 2
                     );
        */
        [self drawPoint:[self getCertainPointOfCell:cell_attr withType:@"score_dot"]
         withPointSize:MIN(5,[self NUM_SCALE:2 from:30 to:[[cell_attr objectForKey:@"ss"]floatValue]])
              inContext:UIGraphicsGetCurrentContext()
         ];
    }
}
-(CGFloat)printOneScoreCellWithObjectForUpper:(NSDictionary*)cell_attr withScore:(NSDictionary*)score{
    CGFloat upper_y=[[cell_attr objectForKey: @"cell_offset_y"]floatValue]+[[cell_attr objectForKey: @"t"]floatValue];
    
    //upper points
    CGFloat upperpoints=[[cell_attr objectForKey: @"upperpoints"]floatValue];
    if(upperpoints && upperpoints>0){
        upper_y=upper_y-[self NUM_SCALE:1 from:50 to:[[cell_attr objectForKey:@"s"]floatValue]];
        for(NSInteger i=0;i<upperpoints;i++){
            /*
            this.drawDot(
                         [cell_attr.cell_offset_x+cell_attr.ss/2,upper_y],
                         this.helper.NUM_SCALE(2,30,cell_attr.ss) //2
                         );
            */
            [self drawPoint:(CGPointMake(([[cell_attr objectForKey: @"cell_offset_x"]floatValue]+[[cell_attr objectForKey: @"ss"]floatValue])/2, upper_y)) withPointSize:[self NUM_SCALE:2 from:30 to:[[cell_attr objectForKey:@"ss"]floatValue]] inContext:UIGraphicsGetCurrentContext()];
            
            upper_y=upper_y-[self NUM_SCALE:6 from:50 to:[[cell_attr objectForKey: @"s"]floatValue]];
        }
    }
    
    if([[score objectForKey: @"fermata"]boolValue]){
        /*
        this.drawArcForKeep(
        cell_attr.cell_offset_x+cell_attr.ss*0.1,
        cell_attr.cell_offset_x+cell_attr.ss*0.9,
        upper_y-this.helper.NUM_SCALE(3,50,cell_attr.s),
        cell_attr.ss*0.9*0.2
        );
        this.drawDot(
                     [cell_attr.cell_offset_x+cell_attr.ss/2,upper_y],
                     this.helper.NUM_SCALE(2,30,cell_attr.ss)
                     );
        upper_y=upper_y-this.helper.NUM_SCALE(6,50,cell_attr.s);
         */
        self drawArcForKeepFromPointStartX:<#(CGFloat)#> toPointEndX:<#(CGFloat)#> onPointY:<#(CGFloat)#> withOmega:<#(CGFloat)#> isTriplets:<#(Boolean)#>
    }
    
    if(score.effect_word){
        this.writeText(
                       score.effect_word,
                       [cell_attr.cell_offset_x+cell_attr.ss*0.1,upper_y-this.helper.NUM_SCALE(9,50,cell_attr.s)],
                       {
                       font:'italic '+(Math.min(cell_attr.k,cell_attr.min_kk)*0.6)+'px sans-serif',
                       textAlign:'left',
                       textBaseline:'middle'
                       }
                       );
        upper_y=upper_y-this.helper.NUM_SCALE(6,50,cell_attr.s);
    }
    
    return upper_y;

}
-(CGFloat)printOneScoreCellWithObjectForUnder:(NSDictionary*)cell_attr withScore:(NSDictionary*)score{
    //TODO
}
-(void)printOneScoreCellWithObjectForKeep:(NSDictionary*)cell_attr withScore:(NSDictionary*)score whenUpperY:(CGFloat)upper_y{
    //TODO
}

-(CGPoint)getCertainPointOfCell:(NSDictionary*)cell_attr withType:(NSString*)type{
    CGFloat p_x=0.5;
    CGFloat p_y=0.5;
    if([type isEqualToString:@"center_of_cell"]){
        p_x=0.5;
        p_y=0.5;
    }
    if([type isEqualToString:@"score_dot"]){
        p_x=0.8;
        p_y=0.5;
    }
    if([type isEqualToString:@"SFN"]){
        p_x=0.05;
        p_y=0.25;
    }
    return CGPointMake(
                       [[cell_attr objectForKey:@"cell_offset_x"]floatValue]+[[cell_attr objectForKey:@"ss"]floatValue]*p_x,
                       [[cell_attr objectForKey:@"cell_offset_y"]floatValue]+[[cell_attr objectForKey:@"t"]floatValue]*p_y
                       );
    /*
    return @[
             [NSNumber numberWithDouble:[[cell_attr objectForKey:@"cell_offset_x"]floatValue]+[[cell_attr objectForKey:@"ss"]floatValue]*p_x],
             [NSNumber numberWithDouble:[[cell_attr objectForKey:@"cell_offset_y"]floatValue]+[[cell_attr objectForKey:@"t"]floatValue]*p_y],
            ];
     */
}

-(CGFloat)NUM_SCALE:(CGFloat)number_in_old_scale from:(CGFloat)old_scalue to:(CGFloat)new_scale{
    return number_in_old_scale/old_scalue*new_scale;
}

#pragma draw codes

-(void)drawPoint:(CGPoint)point withPointSize:(CGFloat)pointSize inContext:(CGContextRef)context{
    CGContextFillEllipseInRect(context, CGRectMake(point.x, point.y, pointSize, pointSize));
}

-(void)drawKeyPoint:(CGPoint)point inContext:(CGContextRef)context{
    // キーポイントだから、十字の照準記号を描く
    CGFloat targetCrossSize=5;
    
    CGContextMoveToPoint(context, point.x-targetCrossSize, point.y);
    CGContextAddLineToPoint(context, point.x+targetCrossSize, point.y);
    CGContextStrokePath(context);
    
    CGContextMoveToPoint(context, point.x, point.y-targetCrossSize);
    CGContextAddLineToPoint(context, point.x, point.y+targetCrossSize);
    CGContextStrokePath(context);
}
-(void)drawLineFrom:(CGPoint)startPoint to:(CGPoint)endPoint inContext:(CGContextRef) context {
    // 指定する二つの点の間に連接する線
    CGContextMoveToPoint(context, startPoint.x, startPoint.y);
    CGContextAddLineToPoint(context, endPoint.x, endPoint.y);
    CGContextStrokePath(context);
}
-(void)drawFilledRect:(CGRect)rect inContent:(CGContextRef)context{
    CGContextFillRect(context, rect);
}
-(void)drawStrokedRect:(CGRect)rect inContent:(CGContextRef)context{
    CGContextStrokeRect(context, rect);
}
-(void)drawFilledCircleWithin:(CGRect)rect inContext:(CGContextRef)context{
    CGContextFillEllipseInRect(context, rect);
}
-(void)drawStrokedCircleWithin:(CGRect)rect inContext:(CGContextRef)context{
    CGContextStrokeEllipseInRect(context, rect);
}

-(void)drawArcForKeepFromPointStartX:(CGFloat)point_start_x toPointEndX:(CGFloat)point_end_x onPointY:(CGFloat)point_y withOmega:(CGFloat)omega isTriplets:(Boolean)triplets{
    //TODO
}

-(void)writeText:(NSString*)text pointBase:(CGPoint)point_base requirements:(NSDictionary*)requirements{
    //TODO
}

#pragma test

+(void)test{
    NSString*text=[WebPageMaker scoreTextOfScore:@"XB001" inBook:@"XB780"];
    NSLog(@"test text: %@",text);
    SinriScoreDrawerView * testView=[[SinriScoreDrawerView alloc]initWithFrame:(CGRectMake(0, 0, 10, 20)) withScoreText:text];
}

@end
