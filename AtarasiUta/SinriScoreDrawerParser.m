//
//  SinriScoreDrawerParser.m
//  AtarasiUta
//
//  Created by 倪 李俊 on 2017/1/6.
//  Copyright © 2017年 com.sinri. All rights reserved.
//

#import "SinriScoreDrawerParser.h"
#import "SinriScoreCellData.h"

@interface SinriScoreDrawerParser ()
@property NSString * theScoreText;
@end

@implementation SinriScoreDrawerParser

-(instancetype)initWithScoreText:(NSString *)text{
    self=[super init];
    if(self){
        _theScoreText=text;
        _autoCellWidth=YES;
    }
    return self;
}

-(NSArray*)parseScoreText{
    if(_theScoreText==nil || [_theScoreText isEqualToString:@""]){
        return @[];
    }
    NSMutableArray * score_data=[@[] mutableCopy];
    
    //break text down to array of lines
    NSArray * linesOfText=[self breakTextDownToArrayOfLines:_theScoreText];
    
    NSMutableArray * the_notes_list=[@[] mutableCopy];
    Boolean has_numbered_lyric=NO;

//    NSLog(@"debug: %s, %d within %s",__FILE__,__LINE__,__FUNCTION__);
    
    //each line
    for (NSUInteger line_index=0; line_index<linesOfText.count; line_index++) {
        NSString * lineText=[linesOfText objectAtIndex:line_index];
        NSArray * notes=[self breakStringDownToArrayByWhiteSpace:lineText];
        
        NSString * type=@"";
        NSString * first_note_char=[lineText substringWithRange:NSMakeRange(0, 1)];//notes[0];
//        NSLog(@"debug: %s | first_note_char=%@",__FUNCTION__,first_note_char);
        if([first_note_char isEqualToString:@"~"]){
            type=@"TITLE";
            NSString * title=[lineText substringFromIndex:2];//lines[line_index].substr(2);
            notes=@[title];
        }
        else if([first_note_char isEqualToString:@">"]){
            type=@"LYRIC";
            notes=[SinriScoreDrawerParser stringToNSCharArray: [lineText substringFromIndex:2]];
            notes=[self MERGE:notes SEIGE:@"`"];
        }
        else if([first_note_char isEqualToString:@"#"]){
            type=@"NUMBERED_LYRIC";
            notes=[SinriScoreDrawerParser stringToNSCharArray: [lineText substringFromIndex:2]];
            has_numbered_lyric=YES;
            notes=[self MERGE:notes SEIGE:@"`"];
        }
        else if([first_note_char isEqualToString:@"@"]){
            type=@"ALL_LYRIC";
            notes=[SinriScoreDrawerParser stringToNSCharArray: [lineText substringFromIndex:2]];
            has_numbered_lyric=YES;
            notes=[self MERGE:notes SEIGE:@"`"];
        }
        
        [the_notes_list addObject:@{
                                    @"notes":notes,
                                    @"type":type,
                                    }
         ];
    }
    
//    NSLog(@"debug: %s, %d within %s",__FILE__,__LINE__,__FUNCTION__);
    
    NSInteger number=0;
    NSInteger prev_score_line_cells=0;
    
    for(NSUInteger i=0;i<the_notes_list.count;i++){
        NSArray * notes=[the_notes_list[i] objectForKey:@"notes"];
        NSString * type=[the_notes_list[i] objectForKey:@"type"];
        if(has_numbered_lyric){
            if([type isEqualToString: @"LYRIC"]){
                notes=[[@[@" "] mutableCopy] arrayByAddingObjectsFromArray:notes];
            }else if([type isEqualToString: @"ALL_LYRIC"]){
                notes=[[@[@"和"] mutableCopy] arrayByAddingObjectsFromArray:notes];
            }else if([type isEqualToString: @"NUMBERED_LYRIC"]){
                number=number+1;
                notes=[[@[[NSString stringWithFormat:@"%ld",(long)number]] mutableCopy] arrayByAddingObjectsFromArray:notes];
            }
        }
        NSMutableArray *line_data=[self parseScoreLineString:notes forType:type];
        
        // new idea: set indentation and fill final empty
        if(has_numbered_lyric && ([type isEqualToString: @"ALL_LYRIC"] || [type isEqualToString: @"NUMBERED_LYRIC"])){
            if(line_data[0]){
//                NSMutableDictionary * dict=[line_data[0] mutableCopy];
//                [dict setObject:@YES forKey:@"indentation"];
//                [line_data replaceObjectAtIndex:0 withObject:dict];
                [[line_data objectAtIndex:0]setIndentation:YES];
            }
        }
        if(_autoCellWidth){
            if(!type){
                prev_score_line_cells=[line_data count];
            }else if([type isEqualToString: @"LYRIC"]){
                NSInteger tarinai=prev_score_line_cells-[line_data count];
                for(int fill_count=0;fill_count<tarinai;fill_count++){
//                    [line_data addObject:@{@"note":@" "}];
                    SinriScoreCellData *cell=[[SinriScoreCellData alloc]init];
                    [cell setNote:@" "];
                    [line_data addObject:cell];
                }
            }else if([type isEqualToString: @"ALL_LYRIC"] || [type isEqualToString: @"NUMBERED_LYRIC"]){
                NSInteger tarinai=prev_score_line_cells+0-[line_data count];
                for(int fill_count=0;fill_count<tarinai;fill_count++){
//                    [line_data addObject:@{@"note":@" ",@"indentation":@YES}];
                    SinriScoreCellData *cell=[[SinriScoreCellData alloc]init];
                    [cell setNote:@" "];
                    [cell setIndentation:YES];
                    [line_data addObject:cell];
                }
            }
        }
        
        [score_data addObject:line_data];
    }
    return score_data;
}

-(NSMutableArray*)parseScoreLineString:(NSArray*)notes forType:(NSString*)type{
//    NSLog(@"debug: %s, %d within %s",__FILE__,__LINE__,__FUNCTION__);
    NSMutableArray * line_data=[@[] mutableCopy];
    for(int note_index=0;note_index<[notes count];note_index++){
        NSArray* note_results= [self parseNoteString:notes[note_index] forType:type]; //(notes[note_index],type);
        for(int i=0;i<[note_results count];i++){
            [line_data addObject:note_results[i]];
        }
    }
    return line_data;
}

//TODO replace to celldata
-(NSArray*)parseNoteString:(NSString*)note_text forType:(NSString*)type{
//    NSLog(@"debug: %s, %d within %s",__FILE__,__LINE__,__FUNCTION__);
    if(![type isEqualToString:@""]){
        return [self parseNoteString:note_text forSpecialType:type];
    }
    
    NSArray* control_sign_note=[self parseNoteStringForControlSign:note_text];
    if(control_sign_note){
        return control_sign_note;
    }
    
    //ELSE
    //    let regex=/^[\(]?[#bn]?([0]|([1-7](\<|\>)*))[~]?(([\._]+)|(\-+)|(\*[1-9][0-9]*)|(\/[1-9][0-9]*))?[\)]?(:[A-Z]+)?$/;
    NSString * pattern=@"^[\\(]?[#bn]?([0]|([1-7](\\<|\\>)*))[~]?(([\\._]+)|(\\-+)|(\\*[1-9][0-9]*)|(\\/[1-9][0-9]*))?[\\)]?(:[A-Z]+)?$";
    NSError  *error = nil;
    NSRegularExpression * regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];
    if([regex numberOfMatchesInString:note_text options:0 range:NSMakeRange(0, [note_text length])]<=0){
        SinriScoreCellData *cell=[[SinriScoreCellData alloc]init];
        [cell setNote:note_text];
        [cell setSpecialNote:@"AS_IS"];
        return @[cell];
//        return @[@{@"special_note":@"AS_IS",@"note":note_text}];
    }
    
//    NSMutableDictionary * note=[@{
//                                  @"_has_long_line":@0,
//                                  @"_times_divided":@0,
//                                  @"_times_multiply":@0
//                                  } mutableCopy];
    
    SinriScoreCellData *note=[[SinriScoreCellData alloc]init];
    
    NSInteger flag=0;//beginning
    
    NSMutableArray *parts=[[note_text componentsSeparatedByString:@":"] mutableCopy];
    
    if([parts count]>1 && [self NoteEffectWordDictory:parts[1]]){
//        [note setObject:[self NoteEffectWordDictory:parts[1]] forKey:@"effect_word"];
        [note setEffectWord:[self NoteEffectWordDictory:parts[1]]];
    }
    note_text=parts[0];
    
    for(int i=0;i<note_text.length;i++){
        NSString * c = [note_text substringWithRange:NSMakeRange(i, 1)];
        flag=[self parseNoteStringForNotation:c withFlag:flag withNote:note];
    }
    
//    NSLog(@"debug: %s, fin note to addition: %@",__FUNCTION__,note);
    
    return [self parseNoteStringForNotationAddition:note];
}

-(NSArray*)parseNoteString:(NSString*)note_text forSpecialType:(NSString*)type{
//    NSLog(@"debug: %s, %d within %s",__FILE__,__LINE__,__FUNCTION__);
    if([type isEqualToString:@"TITLE"]){
        SinriScoreCellData * cell=[[SinriScoreCellData alloc]init];
        [cell setSpecialNote:@"AS_IS"];
        [cell setNote:note_text];
        [cell setTitle:YES];
        return @[cell];
//        return @[@{
//                     @"special_note":@"AS_IS",
//                     @"note":note_text,
//                     @"title":@YES
//                     }];
    }
    else if([type isEqualToString:@"LYRIC"]){
        SinriScoreCellData * cell=[[SinriScoreCellData alloc]init];
        [cell setSpecialNote:@"AS_IS"];
        [cell setNote:note_text];
        return @[cell];
//        return @[@{
//                     @"special_note":@"AS_IS",
//                     @"note":note_text
//                     }];
    }
    // IF NOT DETERMINED
    SinriScoreCellData * cell=[[SinriScoreCellData alloc]init];
    [cell setSpecialNote:@"AS_IS"];
    [cell setNote:note_text];
    return @[cell];
//    return @[@{
//                 @"special_note":@"AS_IS",
//                 @"note":note_text
//                 }];
}
-(NSArray*)parseNoteStringForControlSign:(NSString*)note_text{
    NSDictionary * mp=@{
        @"||:":@"REPEAT_START_DOUBLE",
        @":||":@"REPEAT_END_DOUBLE",
        @"|:":@"REPEAT_START_SINGLE",
        @":|":@"REPEAT_END_SINGLE",
        @"||":@"FIN",
        @"|":@"PHARSE_FIN",
        };
    if([mp objectForKey:note_text]){
        SinriScoreCellData * cell=[[SinriScoreCellData alloc]init];
        [cell setSpecialNote:[mp objectForKey:note_text]];
        return @[cell];
//        return @[@{@"special_note":[mp objectForKey:note_text]}];
    }
    
    return nil;
}

-(NSInteger)parseNoteStringForNotation:(NSString*)c withFlag:(NSInteger)flag withNote:(SinriScoreCellData*)note{
//    NSLog(@"parseNoteStringForNotation:%@, flag=%ld, note:%@",c,(long)flag,note);
    if([c isEqualToString:@"("] && flag==0){
//        [note setObject:@YES forKey:@"keep_start"];
        [note setKeepStart:YES];
        flag=1;//has keep_start
    }else if([c isEqualToString:@"#"] && flag<=1){
//        [note setObject:@YES forKey:@"sharp"];
//        [note setSharp:YES];
        [note setSFN:SFN_SHARP];
        flag=2;//has sharp/flat
    }else if([c isEqualToString:@"b"] && flag<=1){
//        [note setObject:@YES forKey:@"flat"];
//        [note setFlat:YES];
        [note setSFN:SFN_FLAT];
        flag=2;//has sharp/flat
    }else if([c isEqualToString:@"n"] && flag<=1){
//        [note setObject:@YES forKey:@"natual"];
//        [note setNatural:YES];
        [note setSFN:SFN_NATURAL];
        flag=2;//has sharp/flat
    }else if([SinriScoreDrawerParser stringToNumber:c] && [[SinriScoreDrawerParser stringToNumber:c] intValue]>=0 && [[SinriScoreDrawerParser stringToNumber:c] intValue]<=9){
        if(flag<=2){
//            [note setObject:c forKey:@"note"];
            [note setNote:c];
            flag=3;//has note
        }else if(flag==7){
//            int x=[[note objectForKey:@"_times_multiply"] intValue]*10+1*[[SinriScoreDrawerParser stringToNumber:c] intValue];
//            [note setObject:[NSNumber numberWithInt:x] forKey:@"_times_multiply"];
            NSInteger x=note.timesMultiply*10+1*[[SinriScoreDrawerParser stringToNumber:c] intValue];
            [note setTimesMultiply:x];
        }else if(flag==8){
//            int x=[[note objectForKey:@"_times_divided"]intValue]*10+1*[[SinriScoreDrawerParser stringToNumber:c] intValue];
//            [note setObject:[NSNumber numberWithInt:x] forKey:@"_times_divided"];
            NSInteger x=note.timesDivided*10+1*[[SinriScoreDrawerParser stringToNumber:c] intValue];
            [note setTimesDivided:x];
        }
    }else if([c isEqualToString:@"<"] && flag==3){
//        NSNumber*x = [note objectForKey:@"underpoints"];
//        NSInteger y=x?[x integerValue]+1:1;
//        [note setObject:[NSNumber numberWithInteger:y] forKey:@"underpoints"];
        note.underpoints+=1;
    }else if([c isEqualToString:@">"] && flag==3){
//        NSNumber*x = [note objectForKey:@"upperpoints"];
//        NSInteger y=x?[x integerValue]+1:1;
//        [note setObject:[NSNumber numberWithInteger:y] forKey:@"upperpoints"];
        note.upperpoints+=1;
    }else if([c isEqualToString:@"."] && (flag==3 || flag==4 || flag==5)){
//        [note setObject:@YES forKey:@"dot"];
        [note setDot:YES];
        flag=4;//has dot
    }else if([c isEqualToString:@"_"] && (flag==3 || flag==4 || flag==5)){
//        NSLog(@"debug: %s, %d within %s",__FILE__,__LINE__,__FUNCTION__);
//        NSNumber*x = [note objectForKey:@"underlines"];
//        NSInteger y=x?[x integerValue]+1:1;
//        [note setObject:[NSNumber numberWithInteger:y] forKey:@"underlines"];
        note.underlines+=1;
        flag=5;//has underlines
    }else if([c isEqualToString:@"-"] && (flag==3 || flag==6)){
//        NSLog(@"debug: %s, %d within %s",__FILE__,__LINE__,__FUNCTION__);
//        NSNumber*x = [note objectForKey:@"_has_long_line"];
//        NSInteger y=x?[x integerValue]+1:1;
//        [note setObject:[NSNumber numberWithInteger:y] forKey:@"_has_long_line"];
        note.hasLongLine+=1;
        flag=6;//has long line
    }else if([c isEqualToString:@"*"] && (flag==3 || flag==7)){
        flag=7;
    }else if([c isEqualToString:@"/"] && (flag==3 || flag==8)){
        flag=8;
    }else if([c isEqualToString:@")"] && flag>=3){
//        [note setObject:@YES forKey:@"keep_end"];
        [note setKeepEnd:YES];
        flag=9;
    }else if([c isEqualToString:@"~"] && flag==3){
//        [note setObject:@"YES" forKey:@"fermata"];
        [note setFermata:YES];
    }
//    NSLog(@"parseNoteStringForNotation!%@, flag=%ld, note:%@",c,(long)flag,note);
    return flag;
}

-(NSArray*)parseNoteStringForNotationAddition:(SinriScoreCellData*)note{
//    NSLog(@"debug: %s, %d within %s",__FILE__,__LINE__,__FUNCTION__);
    if(note.timesMultiply>0){
       note.hasLongLine-=1;
    }
    if(note.timesDivided>0){
        if(note.timesDivided==3){
            [note setTriplets:YES];
        }
        else if (note.timesDivided%2==0){
            [note setUnderlines:note.timesDivided/2];
        }
        else{
            [note setUnderlines:note.timesDivided/2];
            [note setDot:YES];
        }
    }
    
    NSInteger has_long_line=note.hasLongLine?note.hasLongLine:0;
    Boolean has_dot=note.dot?note.dot:NO;
    
    NSMutableArray* notes=[@[note] mutableCopy];
    if(has_dot){
        SinriScoreCellData * cell = [[SinriScoreCellData alloc]init];
        [cell setSpecialNote:@"DOT"];
        [notes addObject:cell];
    }
    for(int j=0;j<has_long_line;j++){
        SinriScoreCellData * cell = [[SinriScoreCellData alloc]init];
        [cell setSpecialNote:@"LONGER_LINE"];
        [notes addObject:cell];
    }
    
    return notes;
}

-(NSString*)NoteEffectWordDictory:(NSString*)code{
    if([code isEqualToString:@"F"]){
        return @"f";
    }else if ([code isEqualToString:@"FF"]){
        return @"ff";
    }else if ([code isEqualToString:@"P"]){
        return @"p";
    }else if ([code isEqualToString:@"PP"]){
        return @"pp";
    }else if ([code isEqualToString:@"MP"]){
        return @"mp";
    }else if ([code isEqualToString:@"MF"]){
        return @"mf";
    }else if ([code isEqualToString:@"POCO"]){
        return @"poco";
    }else if ([code isEqualToString:@"DIM"]){
        return @"dim...";
    }else if ([code isEqualToString:@"CRES"]){
        return @"cres...";
    }else if ([code isEqualToString:@"RIT"]){
        return @"rit...";
    }else if ([code isEqualToString:@"RALL"]){
        return @"rall...";
    }else if ([code isEqualToString:@"ATEMPO"]){
        return @"a tempo";
    }else if ([code isEqualToString:@"VF"]){
        return @">";
    }else{
        return false;
    }
}

#pragma part

-(NSArray*)breakTextDownToArrayOfLines:(NSString*)text{
    NSArray* tmp_lines=[text componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    NSMutableArray * lines=[@[] mutableCopy];
    for (NSUInteger i=0; i<tmp_lines.count; i++) {
        if([tmp_lines objectAtIndex:i] && ![[tmp_lines objectAtIndex:i] isEqualToString:@""]){
            [lines addObject:[tmp_lines objectAtIndex:i]];
        }
    }
    return lines;
}
-(NSArray*)breakStringDownToArrayByWhiteSpace:(NSString*)text{
    NSArray* tmp_lines=[text componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSMutableArray * lines=[@[] mutableCopy];
    for (NSUInteger i=0; i<tmp_lines.count; i++) {
        if([tmp_lines objectAtIndex:i] && ![[tmp_lines objectAtIndex:i] isEqualToString:@""]){
            [lines addObject:[tmp_lines objectAtIndex:i]];
        }
    }
    return lines;
}

-(NSArray*)MERGE:(NSArray*)array SEIGE:(NSString*)seige_item{
    NSMutableArray * after=[@[] mutableCopy];
    NSString * inside=nil;//  null ('' 'X' )null
    for(NSUInteger i=0;i<array.count;i++){
        if([array[i] isEqualToString: seige_item]){
            if(inside==nil){
                inside=@"";
            }else{
                [after addObject:inside];
                inside=nil;
            }
        }else{
            if(inside!=nil){
                inside=[inside stringByAppendingString:array[i]];
            }else{
                [after addObject:array[i]];
            }
        }
    }
    if(inside!=nil){
        [after addObject:inside];
    }
    return after;
}

+(NSNumber*)stringToNumber:(NSString*)s{
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    NSNumber *myNumber = [f numberFromString:s];
    return myNumber;
}
+(NSArray*)stringToNSCharArray:(NSString*)string{
    NSMutableArray *characters=[@[] mutableCopy];
    for (int i=0; i<[string length]; i++) {
        [characters addObject:[string substringWithRange:NSMakeRange(i, 1)]];
    }
    return characters;
}

@end
