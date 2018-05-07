//
//  SinriScoreDrawerView.m
//  AtarasiUta
//
//  Created by 倪 李俊 on 2017/1/6.
//  Copyright © 2017年 com.sinri. All rights reserved.
//

#import "SinriScoreDrawerView.h"
#import "SinriScoreDrawerParser.h"
#import "SinriScoreCellData.h"
#import "WebPageMaker.h"

static NSDictionary * SPECIAL_NOTE_MAPPING;

@interface SinriScoreDrawerView ()

@property NSString *theScoreText;
@property NSArray *theParsedScore;
@property UIColor *theBoardColor;
@property UIColor *thePenColor;

@property NSMutableArray * keep_sign_set;

@property NSInteger cell_count_x;
@property NSInteger cell_count_y;
@property CGFloat cell_width;
@property CGFloat cell_height;

@end

@implementation SinriScoreDrawerView

+ (void) initialize {
    if (self == [UIView class]) {
        // Once-only initializion
    }
    // Initialization for this class and any subclasses
    
    SPECIAL_NOTE_MAPPING=@{
                           @"REPEAT_START_DOUBLE":@"‖:",
                           @"REPEAT_END_DOUBLE":@":‖",
                           @"REPEAT_START_SINGLE":@"|:",
                           @"REPEAT_END_SINGLE":@":|",
                           @"LONGER_LINE":@"ー",
                           @"FIN":@"‖",
                           @"PHARSE_FIN":@"|",
                           @"DOT":@"・"
                           };
}


- (instancetype)initWithFrame:(CGRect)frame withScoreText:(NSString*)scoreText{
    self= [super initWithFrame:frame];
    if(self){
        _theBoardColor=[UIColor colorWithRed:0.98 green:0.9 blue:0.98 alpha:1];
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
    NSLog(@"%s, %d",__FUNCTION__,__LINE__);
    //    [self loadScoreData:_theParsedScore cellSize:@{@"w":@30,@"h":@"50"} notAutoCanvasSize:YES];
    [self drawDot:(CGPointMake(10, 10)) size:5 withColor:_thePenColor];
    [self drawDot:(CGPointMake(10, 50)) size:4 withColor:[UIColor redColor]];
    [self drawDot:(CGPointMake(50, 50)) size:3 withColor:[UIColor blueColor]];
    [self drawDot:(CGPointMake(50, 10)) size:2 withColor:[UIColor orangeColor]];
    
    [self drawDot:(CGPointMake(self.frame.size.width-10, self.frame.size.height-10)) size:5 withColor:[UIColor greenColor]];
    
    _cell_count_x=0;
    _cell_count_y=[_theParsedScore count];
    for(NSInteger line_index=0;line_index<[_theParsedScore count];line_index++){
        NSArray*line=[_theParsedScore objectAtIndex:line_index];
        if(line){
            SinriScoreCellData*cell=[line objectAtIndex:0];
            if([cell title]){
                continue;
            }
            _cell_count_x=MAX([line count],_cell_count_x);
        }
    }
    _cell_count_x+=2;
    _cell_count_y+=2;
    
    _cell_width=self.frame.size.width/_cell_count_x;
    _cell_height=_cell_width/3.0*5.0;
    
    [self setFrame:(CGRectMake(self.frame.origin.x, self.frame.origin.y, _cell_width*_cell_count_x, _cell_height*_cell_height))];
    
    for (NSInteger line_index=0; line_index<_cell_count_y; line_index++) {
        if(line_index==0 || line_index==_cell_count_y-1)continue;
        NSArray * line=[_theParsedScore objectAtIndex:line_index-1];
        for (NSInteger cell_index=0; cell_index<MIN(_cell_count_x,[line count]); cell_index++) {
            if(cell_index==0 || cell_index==_cell_count_x-1)continue;
            SinriScoreCellData * cell=[line objectAtIndex:cell_index];
            //debug cell wall
            [self drawStrokedRect:(CGRectMake((cell_index-1)*_cell_width, (line_index-1)*_cell_height, _cell_width, _cell_height)) withColor:[UIColor grayColor]];
            //detail
            [cell setX:cell_index];
            [cell setY:line_index];
            [self drawOneCell:cell];
        }
    }
    
}

-(void)drawOneCell:(SinriScoreCellData *)cell{
    [self drawTextForOneCell:cell];
}

-(void)drawTextForOneCell:(SinriScoreCellData*)cell{
    if(cell.title){
        [self drawText:cell.note atCenterOfRect:CGRectMake(_cell_width*cell.x, _cell_height*cell.y, _cell_width*(_cell_count_x-2), _cell_height) withFont:[UIFont systemFontOfSize:12] withColor:_thePenColor];
    }else{
        NSString * note_text=@"";
        if(cell.note && cell.note.length>0){
            note_text=[cell.note substringWithRange:(NSMakeRange(0,1))];
        }
        if(cell.specialNote){
            if([cell.specialNote isEqualToString: @"AS_IS"] && cell.note){
                note_text=cell.note;
            }else if([SPECIAL_NOTE_MAPPING objectForKey:cell.specialNote]){
                note_text=[SPECIAL_NOTE_MAPPING objectForKey:cell.specialNote];
            }
        }
        [self drawText:note_text atCenterOfRect:CGRectMake(_cell_width*cell.x, _cell_height*cell.y, _cell_width, _cell_height) withFont:[UIFont systemFontOfSize:12] withColor:_thePenColor];
    }
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
    
    [self drawFilledRect:rect withColor:_theBoardColor];
    
    // 直線の端のスタイル。ここは四角いが、円形になるも可能
    CGContextSetLineCap(context, kCGLineCapSquare);
    // 直線の幅を設定
    CGContextSetLineWidth(context, 1.0);
    
    // TODO: 具体的な描くコード
    
    [self drawScore];
}

-(void)drawText:(NSString*)s atCenterOfRect:(CGRect)contextRect withFont:(UIFont*)font withColor:(UIColor*)color{
    /// Make a copy of the default paragraph style
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    /// Set line break mode
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    /// Set text alignment
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    NSDictionary *attributes = @{
                                 NSFontAttributeName: font,
                                 NSForegroundColorAttributeName: color,
                                 NSParagraphStyleAttributeName: paragraphStyle
                                 };
    
    CGSize size = [s sizeWithAttributes:attributes];
    
    CGRect textRect = CGRectMake(contextRect.origin.x+floorf((contextRect.size.width - size.width)/2),
                                 contextRect.origin.y+floorf((contextRect.size.height - size.height)/2),
                                 size.width,
                                 size.height);
    
//    [s drawInRect:textRect withAttributes:attributes];
    
    CGContextShowText(UIGraphicsGetCurrentContext(), [s UTF8String], strlen([s UTF8String]));
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
    //    [self performSelector:@selector(setNeedsDisplay) withObject:nil afterDelay:0];
    [self setNeedsDisplay];
}

-(void)setBoardColor:(UIColor *)boardColor{
    _theBoardColor=boardColor;
}

-(void)setPenColor:(UIColor *)penColor{
    _thePenColor=penColor;
}

#pragma parse codes

-(void)drawDot:(CGPoint)point size:(CGFloat)pointSize withColor:(UIColor*)color{
    CGContextRef context = UIGraphicsGetCurrentContext();
    [color setFill];
    [color setStroke];
    CGContextFillEllipseInRect(context, CGRectMake(point.x, point.y, pointSize, pointSize));
}

-(void)drawFilledRect:(CGRect)rect withColor:(UIColor*)color{
    CGContextRef context = UIGraphicsGetCurrentContext();
    [color setFill];
    [color setStroke];
    CGContextFillRect(context, rect);
}

-(void)drawStrokedRect:(CGRect)rect withColor:(UIColor*)color{
    CGContextRef context = UIGraphicsGetCurrentContext();
    [color setFill];
    [color setStroke];
    CGContextStrokeRect(context, rect);
}

#pragma test

//+(void)test{
//    NSString*text=[WebPageMaker scoreTextOfScore:@"XB002" inBook:@"XB780"];
//    NSLog(@"test text: %@",text);
//    SinriScoreDrawerView * testView=[[SinriScoreDrawerView alloc]initWithFrame:(CGRectMake(0, 0, 10, 20)) withScoreText:text];
//}

@end
