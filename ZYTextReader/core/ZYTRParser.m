//
//  ZYTRParser.m
//  ZYTextReader
//
//  Created by LinZiYuan on 2018/7/16.
//  Copyright © 2018年 LinZiYuan. All rights reserved.
//

#import "ZYTRParser.h"
#import "ZYTRParserConfig.h"
#import "ZYRederModel.h"
#import "ZYChapterModel.h"
#import "ZYSectionModel.h"
#import "NSString+zyPinyin.h"

@implementation ZYTRParser

+ (ZYRederModel *)parserDataDic:(NSDictionary *)dataDic config:(ZYTRParserConfig *)config {
    
    ZYRederModel *readerM = [[ZYRederModel alloc] init];
    NSArray *dataArr = [dataDic valueForKey:@"chapters"];
    NSMutableArray *chapterArr = [NSMutableArray array];
    NSUInteger startPage = 0;
    for (NSDictionary *chapterItem in dataArr) {
        @autoreleasepool {
            ZYChapterModel *chapterM = [self chapterWithDataDic:chapterItem config:config];
            chapterM.dataDic = chapterItem;
            chapterM.startPage = startPage;
            [chapterArr addObject:chapterM];
            startPage += chapterM.pageArr.count;
        }
    }
    readerM.chapters = chapterArr;
    return readerM;
}

+ (void)chapterReGetContent:(ZYChapterModel *)chapterM withDataDic:(NSDictionary *)dataDict config:(ZYTRParserConfig *)config {
    NSDictionary *infoDic = [self mDicInfoWithDataDic:dataDict config:config newCount:NO];
    NSMutableAttributedString *result = [infoDic valueForKey:@"result"];
    chapterM.content = result;
    chapterM.sentenceArr = [infoDic valueForKey:@"sentenceArr"];
    chapterM.sectionsArr = [infoDic valueForKey:@"sectionMs"];
    //
}

+ (ZYChapterModel *)chapterWithDataDic:(NSDictionary *)dataDict config:(ZYTRParserConfig *)config {
    
    ZYChapterModel *chapterM = [[ZYChapterModel alloc] init];
    //
    chapterM.name = [dataDict valueForKey:@"name"];
    chapterM.type = [dataDict valueForKey:@"type"];
    chapterM.index = [[dataDict valueForKey:@"chapter"] integerValue];
    //
    NSDictionary *infoDic = [self mDicInfoWithDataDic:dataDict config:config newCount:YES];
    NSMutableAttributedString *result = [infoDic valueForKey:@"result"];
    chapterM.content = result;
    chapterM.sectionsArr = [infoDic valueForKey:@"sectionMs"];
    chapterM.sentenceArr = [infoDic valueForKey:@"sentenceArr"];
    NSArray *pageInfos = [infoDic valueForKey:@"pageInfos"];
    NSMutableArray *totalPages = [NSMutableArray array];
    for (NSDictionary *pInfo in pageInfos) {
        NSAttributedString *pContent = [pInfo valueForKey:@"pContent"];
        NSRange pRange = [[pInfo valueForKey:@"pRange"] rangeValue];
        NSArray *pArr = [self parserContent:pContent config:config startOffset:pRange.location];
        [totalPages addObjectsFromArray:pArr];
        //
    }
    chapterM.pageArr = totalPages;
    return chapterM;
}

+ (NSMutableDictionary *)mDicInfoWithDataDic:(NSDictionary *)dataDict config:(ZYTRParserConfig *)config newCount:(BOOL)isNewCount {
    
    NSMutableDictionary *mDic = [NSMutableDictionary dictionary];
    
    //章节总内容
    NSMutableAttributedString *result = [[NSMutableAttributedString alloc] init];
    //句子range集合
    NSMutableArray *mSenceArr = [NSMutableArray array];
    //记录位置
    NSUInteger location = 0;
    //章节内分页内容记录
    NSUInteger crossStart = 0;
    NSMutableArray *pageContentArr = [NSMutableArray array];
    
    //章节 contents
    NSArray *contentArr = [dataDict valueForKey:@"contents"];
    if ([contentArr isKindOfClass:[NSArray class]]) {
        for (NSDictionary *item in contentArr) {
            @autoreleasepool {
                NSString *type = [item valueForKey:@"type"];
                if ([type isEqualToString:@"txt"]) {
                    NSString *content = [item valueForKey:@"content"];
                    NSAttributedString *as = [self parserAttributeContentFromNSDictionary:item config:config content:content];
                    [result appendAttributedString:as];
                    //[result appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
                    NSRange sRange = NSMakeRange(location, as.length);
                    [mSenceArr addObject:[NSValue valueWithRange:sRange]];
                    location += as.length;
                }
                else if ([type isEqualToString:@"img"]) {
                    //创建空白占位符，并且设置它的CTRunDelegate信息
                    NSAttributedString *as = [self parserImageDataFromNSDictionary:item config:config];
                    [result appendAttributedString:as];
                    [result appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
                    location += 2;
                }
                BOOL isCross = [[item valueForKey:@"crossPage"] boolValue];
                if (isNewCount && isCross) {
                    NSRange pageRange = NSMakeRange(crossStart, location-crossStart);
                    NSAttributedString *pageContent = [result attributedSubstringFromRange:pageRange];
                    NSDictionary *pageInfo = @{@"pRange":[NSValue valueWithRange:pageRange],
                                               @"pContent":pageContent};
                    [pageContentArr addObject:pageInfo];
                    crossStart = location;
                }
            }
        }
    }

    //sections
    NSArray *sections = [dataDict valueForKey:@"sections"];
    if ([sections isKindOfClass:[NSArray class]] && sections.count) {
        NSMutableArray *mSecModesl = [NSMutableArray array];
        for (NSDictionary *secItem in sections) {
            //NSInteger index = [sections indexOfObject:secItem];
            ZYSectionModel *sectionM = [[ZYSectionModel alloc] init];
            sectionM.name = [secItem valueForKey:@"name"];
            sectionM.sectionStartLocation = location;
            NSArray *secContents = [secItem valueForKey:@"contents"];
            if ([secContents isKindOfClass:[NSArray class]]) {
                for (NSDictionary *secC in secContents) {
                    @autoreleasepool {
                        NSString *type = [secC valueForKey:@"type"];
                        if ([type isEqualToString:@"txt"]) {
                            NSString *content = [secC valueForKey:@"content"];
                            NSAttributedString *as = [self parserAttributeContentFromNSDictionary:secC config:config content:content];
                            [result appendAttributedString:as];
                            //[result appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
                            NSRange sRange = NSMakeRange(location, as.length);
                            [mSenceArr addObject:[NSValue valueWithRange:sRange]];
                            location += as.length;
                        }
                        else if ([type isEqualToString:@"img"]) {
                            //创建空白占位符，并且设置它的CTRunDelegate信息
                            NSAttributedString *as = [self parserImageDataFromNSDictionary:secC config:config];
                            [result appendAttributedString:as];
                            [result appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
                            location += 2;
                        }
                        BOOL isCross = [[secC valueForKey:@"crossPage"] boolValue];
                        if (isNewCount && isCross) {
                            NSRange pageRange = NSMakeRange(crossStart, location-crossStart);
                            NSAttributedString *pageContent = [result attributedSubstringFromRange:pageRange];
                            NSDictionary *pageInfo = @{@"pRange":[NSValue valueWithRange:pageRange],
                                                       @"pContent":pageContent};
                            [pageContentArr addObject:pageInfo];
                            crossStart = location;
                        }
                    }
                }
            }
            [mSecModesl addObject:sectionM];
            if (isNewCount) {       //每个section完结翻页
                NSRange pageRange = NSMakeRange(crossStart, location-crossStart);
                NSAttributedString *pageContent = [result attributedSubstringFromRange:pageRange];
                NSDictionary *pageInfo = @{@"pRange":[NSValue valueWithRange:pageRange],
                                           @"pContent":pageContent};
                [pageContentArr addObject:pageInfo];
                crossStart = location;
            }
        }
        [mDic setValue:mSecModesl forKey:@"sectionMs"];
    }else {
        //没有section 自成一个pageinfo
        if (isNewCount) {
            NSRange pageRange = NSMakeRange(crossStart, location-crossStart);
            NSAttributedString *pageContent = [result attributedSubstringFromRange:pageRange];
            NSDictionary *pageInfo = @{@"pRange":[NSValue valueWithRange:pageRange],
                                       @"pContent":pageContent};
            [pageContentArr addObject:pageInfo];
            crossStart += location;
        }
    }
    
    [mDic setValue:mSenceArr forKey:@"sentenceArr"];
    [mDic setValue:result forKey:@"result"];
    if (isNewCount) {
        [mDic setValue:pageContentArr forKey:@"pageInfos"];
    }
    return mDic;
}

+ (NSAttributedString *)parserAttributeContentFromNSDictionary:(NSDictionary*)dict config:(ZYTRParserConfig *)config content:(NSString *)content {
    BOOL isCenter = [[dict valueForKey:@"alignCenter"] boolValue];
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributWithConfig:config isAlignCenter:isCenter]];
    //设置颜色
    UIColor *color = config.textColor;
    if ([self colorFromString:[dict valueForKey:@"color"]]) {
        color = [self colorFromString:[dict valueForKey:@"color"]];
    }
    attributes[(id)kCTForegroundColorAttributeName] = (id)color.CGColor;
    
    //设置字号
    CGFloat fontSize = config.fontSize;
    if ([[dict valueForKey:@"size"] floatValue]) {
        fontSize = [[dict valueForKey:@"size"] floatValue];
    }
    fontSize += config.fontChange;
    CTFontRef fontRef = CTFontCreateWithName((CFStringRef)@"ArialMT", fontSize, NULL);
    attributes[(id)kCTFontAttributeName] = (__bridge id)fontRef;
    ZYCFSAFERELEASE(fontRef);
    
    //[attributes setValue:@(NSUnderlineStyleSingle) forKey:NSUnderlineStyleAttributeName];
    
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:content attributes:attributes];
    //设置 annotation
    NSString * anno = [dict valueForKey:@"annotation"];
    if (anno.length) {
        NSArray *annoArr = [anno componentsSeparatedByString:@" "];
        for (int i = 0; i<annoArr.count; i++) {
            @autoreleasepool {
                NSString *str = [content substringWithRange:NSMakeRange(i, 1)];
                if ([str strIsChinese]) {
                    NSString *singleAnno = annoArr[i];//[str transformToPinyin];
                    if (singleAnno.length) {
                        singleAnno = [NSString stringWithFormat:@"%@ ",singleAnno];
                        [self setAnnotation:singleAnno attriStr:attrStr range:NSMakeRange(i, 1) fontSize:fontSize];
                    }
                    
                }
            }
        }
    }
    
    //特殊处理special
    NSArray *spcialArr = [dict valueForKey:@"special"];
    if ([spcialArr isKindOfClass:[NSArray class]]) {
        for (NSDictionary *sItem in spcialArr) {
            NSString *stype = [sItem valueForKey:@"sptype"];
            NSString *sValue = [sItem valueForKey:@"spvalue"];
            NSString *sRangeStr = [sItem valueForKey:@"sprange"];
            NSArray *ranges = [sRangeStr componentsSeparatedByString:@"-"];
            NSRange sRange= NSRangeZero;
            if (ranges.count) {
                NSUInteger loc = [[ranges firstObject] integerValue] - 1;
                NSUInteger lenth = 1;
                if (ranges.count >0) {
                    NSUInteger last = [[ranges lastObject] integerValue];
                    lenth = last - loc;
                }
                sRange = NSMakeRange(loc, lenth);
            }
            if (NSEqualRanges(sRange, NSRangeZero)) {
                continue;
            }
            //颜色处理
            if ([stype isEqualToString:@"color"]) {
                UIColor *color = [self colorFromString:sValue];
                if (color) {
                    attributes[(id)kCTForegroundColorAttributeName] = (id)color.CGColor;
                }
                [attrStr setAttributes:attributes range:sRange];
            }
            //拼音处理
            else if ([stype isEqualToString:@"anotation"]) {
                NSArray *sAnos = [sValue componentsSeparatedByString:@" "];
                if (sAnos.count <= sRange.length) {
                    for (NSInteger i = 0; i< sAnos.count; i++) {
                        NSString *str = [content substringWithRange:NSMakeRange(i+sRange.location, 1)];
                        if ([str strIsChinese]) {
                            NSString *singleAnno = sAnos[i];//[str transformToPinyin];
                            if (singleAnno.length) {
                                singleAnno = [NSString stringWithFormat:@" %@ ",singleAnno];
                                [self setAnnotation:singleAnno attriStr:attrStr range:NSMakeRange(i+sRange.location, 1) fontSize:fontSize];
                            }
                        }
                    }
                }
            }
        }
    }
    
    return attrStr;
}

+ (void)setAnnotation:(NSString *)anno attriStr:(NSMutableAttributedString *)attriStr range:(NSRange)range fontSize:(CGFloat)fontSize {
    //create ruby
    if (((long)CTRubyAnnotationCreate+1) == 1) return;  //system not support;
    // Fallback on earlier versions
    CFStringRef text[kCTRubyPositionCount];
    text[kCTRubyPositionBefore] = (__bridge CFStringRef)anno;
    text[kCTRubyPositionAfter] = (__bridge CFStringRef)(@"");
    text[kCTRubyPositionInterCharacter] = (__bridge CFStringRef)(@"");
    text[kCTRubyPositionInline] = (__bridge CFStringRef)(@"");
    CTRubyAnnotationRef ruby = CTRubyAnnotationCreate(kCTRubyAlignmentCenter, kCTRubyOverhangStart, 1.0, text);
    [attriStr addAttribute:(id)kCTRubyAnnotationAttributeName value:(__bridge id)ruby range:range];
    ZYCFSAFERELEASE(ruby);
}

static CGFloat ascentCallback(void *ref){
    
    return [(NSNumber *)[(__bridge NSDictionary *)ref objectForKey:@"height"] floatValue];
}
static CGFloat descentCallback(void *ref){
    
    return 0;
}
static CGFloat widthCallback(void *ref){
    return [(NSNumber *)[(__bridge NSDictionary *)ref objectForKey:@"width"] floatValue];
    //return [(NSNumber *)[(__bridge NSDictionary *)ref objectForKey:@"displayW"] floatValue];
}

static void deallocCallback(void *ref) {
    NSDictionary *dic = (__bridge_transfer NSDictionary *)(ref);
    dic = nil;
}


+ (CGSize)fillImageSizeWithOriginSize:(CGSize)originSize displaySize:(CGSize)displaySize isFullScreen:(BOOL)fullScreen {
    
    CGFloat origin_whRate = originSize.width/originSize.height;
    CGFloat display_whRate = displaySize.width/displaySize.height;
    CGFloat newW = originSize.width;
    CGFloat newH = originSize.height;
    
    if (fullScreen) {
        if (origin_whRate > display_whRate) {
            newW = displaySize.width;
            newH = originSize.height * displaySize.width/originSize.width;
        }else {
            newH = displaySize.height;
            newW = originSize.width * displaySize.height/originSize.height;
        }
    }else {
        CGFloat disW = displaySize.width * 0.7;
        CGFloat disH = displaySize.height * 0.7;
        if (originSize.width > disW || originSize.height > disH) {
            CGFloat wRate = originSize.width / disW;
            CGFloat hRate = originSize.height / disH;
            if (wRate > hRate) {
                if (hRate <= 0.15) {
                    disW = displaySize.width;
                    wRate = originSize.width / disW;
                }
                newW = disW;
                newH = originSize.height / wRate;
            }else {
                newH = disH;
                newW = originSize.width / hRate;
            }
        }
    }
    return CGSizeMake(newW, newH);
}

+ (NSAttributedString *)parserImageDataFromNSDictionary:(NSDictionary*)dict config:(ZYTRParserConfig *)config {
    
    NSMutableDictionary *mdic = [NSMutableDictionary dictionaryWithDictionary:dict];
    CTRunDelegateCallbacks callbacks;
    BOOL fullScreen = [[dict valueForKey:@"fullScreen"] boolValue];
    CGFloat originW = [[dict valueForKey:@"width"] floatValue];
    CGFloat originH = [[dict valueForKey:@"height"] floatValue];
    if (!originW || !originH) {
        return [[NSAttributedString alloc] initWithString:@""];
    }
    
    CGSize newSize = [self fillImageSizeWithOriginSize:CGSizeMake(originW, originH) displaySize:CGSizeMake(config.width, config.height) isFullScreen:fullScreen];
    [mdic setValue:@(newSize.width) forKey:@"width"];
    [mdic setValue:@(newSize.height) forKey:@"height"];
    
    memset(&callbacks, 0, sizeof(CTRunDelegateCallbacks));
    callbacks.dealloc = deallocCallback;
    callbacks.version = kCTRunDelegateVersion1;
    callbacks.getAscent = ascentCallback;
    callbacks.getDescent = descentCallback;
    callbacks.getWidth = widthCallback;
    CTRunDelegateRef delegate = CTRunDelegateCreate(&callbacks, (__bridge_retained void *)mdic);
    
    //使用0xFFFC作为空白占位符
    unichar objectReplacementChar = 0xFFFC;
    NSString *content = [NSString stringWithCharacters:&objectReplacementChar length:1];
    NSDictionary *attributes = [self attributWithConfig:config isAlignCenter:NO];
    NSMutableAttributedString *space = [[NSMutableAttributedString alloc] initWithString:content attributes:attributes];
    CFAttributedStringSetAttribute((CFMutableAttributedStringRef)space, CFRangeMake(0, 1), kCTRunDelegateAttributeName, delegate);
    ZYCFSAFERELEASE(delegate);
    return space;
}


+ (NSArray *)parserContent:(NSAttributedString *)content config:(ZYTRParserConfig *)config startOffset:(NSUInteger)startoffset{
    
    NSMutableArray *pageArr = [NSMutableArray array];
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)content);
    //    CGSize restrictSize = CGSizeMake(config.width, CGFLOAT_MAX);
    //    CGSize coreTextSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, 0), nil, restrictSize, nil);
    //    CGFloat textHeight = coreTextSize.height;
    //CTFrameRef frame = [self frameWithSetter:framesetter config:config height:config.height];
    
    NSUInteger currentOffset = 0;
    NSUInteger currentInnerOffset = 0;
    
    BOOL hasMorePage = YES;
    // 防止死循环，如果在同一个位置获取CTFrame超过2次，则跳出循环
    NSUInteger preventDeadLoopSign = currentOffset;
    int samePlaceRepeatCount = 0;
    
    while (hasMorePage) {
        @autoreleasepool {
            if (preventDeadLoopSign == currentOffset) {
                ++samePlaceRepeatCount;
            } else {
                samePlaceRepeatCount = 0;
            }
            
            if (samePlaceRepeatCount > 1) {
                // 退出循环前检查一下最后一页是否已经加上
                if (pageArr.count == 0) {
                    [pageArr addObject:@(currentOffset + startoffset)];
                }
                else {
                    NSUInteger lastOffset = [[pageArr lastObject] integerValue];
                    if (lastOffset != currentOffset) {
                        [pageArr addObject:@(currentOffset + startoffset)];
                    }
                }
                break;
            }
            
            [pageArr addObject:@(currentOffset + startoffset)];
            
            CTFrameRef frame = [self frameWithSetter:framesetter config:config offset:currentInnerOffset];
            CFRange range = CTFrameGetVisibleStringRange(frame);
            if ((range.location + range.length) != content.length) {
                
                currentOffset += range.length;
                currentInnerOffset += range.length;
            } else {
                // 已经分完，提示跳出循环
                hasMorePage = NO;
            }
            ZYCFSAFERELEASE(frame);
        }
    }
    ZYCFSAFERELEASE(framesetter);
   
    return pageArr;
}

+ (ZYTRData *)dataWithContent:(NSAttributedString *)content config:(ZYTRParserConfig *)config isParaHead:(BOOL)isParaHead {
    NSRange range = NSMakeRange(0, 1);
    NSDictionary *hasDic = [content attributesAtIndex:0 effectiveRange:&range];
    CTParagraphStyleRef hasPara = (__bridge CFTypeRef)(hasDic[NSParagraphStyleAttributeName]);
    BOOL firtIsCenter = NO;
    if (hasPara) {
        CTTextAlignment textAlignment = kCTTextAlignmentCenter;
        CTParagraphStyleGetValueForSpecifier(hasPara, kCTParagraphStyleSpecifierAlignment, sizeof(textAlignment), &textAlignment);
        if (textAlignment == kCTTextAlignmentCenter) {
            firtIsCenter = YES;
        }
    }
    
    if (isParaHead && !firtIsCenter) {   //是否是段落开头
        NSMutableAttributedString *mAttri = [[NSMutableAttributedString alloc] initWithAttributedString:content];
        CGFloat firstLineIndentSize = 0.0f;
        CGFloat lineSpace = config.lineSpace;
        CGFloat paragraphSpace = config.paragraphSpace;
        const CFIndex kNumberOfSetting = 5;
        CTParagraphStyleSetting theSettings[kNumberOfSetting] = {
            {kCTParagraphStyleSpecifierLineSpacingAdjustment,sizeof(CGFloat),&lineSpace},
            {kCTParagraphStyleSpecifierMaximumLineSpacing,sizeof(CGFloat),&lineSpace},
            {kCTParagraphStyleSpecifierMinimumLineSpacing,sizeof(CGFloat),&lineSpace,},
            {kCTParagraphStyleSpecifierFirstLineHeadIndent,sizeof(CGFloat),&firstLineIndentSize},
            {kCTParagraphStyleSpecifierParagraphSpacing,sizeof(CGFloat),&paragraphSpace},
        };
        CTParagraphStyleRef theParagraphRef = CTParagraphStyleCreate(theSettings, kNumberOfSetting);
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[(id)kCTParagraphStyleAttributeName] = (__bridge id)theParagraphRef;
        [mAttri addAttributes:dict range:NSMakeRange(0, 1)];
        content = mAttri;
        ZYCFSAFERELEASE(theParagraphRef);
    }
    
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)content);
    CGSize restrictSize = CGSizeMake(config.width, CGFLOAT_MAX);
    CGSize coreTextSize = CTFramesetterSuggestFrameSizeWithConstraints(frameSetter, CFRangeMake(0, 0), nil, restrictSize, nil);
    CGFloat textHeight = coreTextSize.height;
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0, 0, config.width, textHeight));
    CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, NULL);
    
    ZYCFSAFERELEASE(path);
    
    ZYTRData *data = [[ZYTRData alloc] init];
    data.ctFrame = frame;
    data.height = textHeight;
    data.content = content;
    
    ZYCFSAFERELEASE(frameSetter);
    ZYCFSAFERELEASE(frame);
    return data;
}

+ (NSDictionary *)attributWithConfig:(ZYTRParserConfig *)config isAlignCenter:(BOOL)isAlignCenter {
    
    
    CTParagraphStyleSetting theSettings[kCTParagraphStyleSpecifierCount] = {0};
    int kNumberOfSetting = 0;
        
    CGFloat lineSpace = config.lineSpace;
    theSettings[kNumberOfSetting].spec = kCTParagraphStyleSpecifierLineSpacingAdjustment;
    theSettings[kNumberOfSetting].valueSize = sizeof(CGFloat);
    theSettings[kNumberOfSetting].value = &lineSpace;
    kNumberOfSetting++;
    
    theSettings[kNumberOfSetting].spec = kCTParagraphStyleSpecifierMaximumLineSpacing;
    theSettings[kNumberOfSetting].valueSize = sizeof(CGFloat);
    theSettings[kNumberOfSetting].value = &lineSpace;
    kNumberOfSetting++;
    
    theSettings[kNumberOfSetting].spec = kCTParagraphStyleSpecifierMinimumLineSpacing;
    theSettings[kNumberOfSetting].valueSize = sizeof(CGFloat);
    theSettings[kNumberOfSetting].value = &lineSpace;
    kNumberOfSetting++;
    
    CGFloat paragraphSpace = config.paragraphSpace;
    theSettings[kNumberOfSetting].spec = kCTParagraphStyleSpecifierParagraphSpacing;
    theSettings[kNumberOfSetting].valueSize = sizeof(CGFloat);
    theSettings[kNumberOfSetting].value = &paragraphSpace;
    kNumberOfSetting++;
    
    CGFloat firstLineIndentSize = config.firstLineIndentSize;
    if (isAlignCenter) {
        firstLineIndentSize = 0.0f;
    }
    theSettings[kNumberOfSetting].spec = kCTParagraphStyleSpecifierFirstLineHeadIndent;
    theSettings[kNumberOfSetting].valueSize = sizeof(CGFloat);
    theSettings[kNumberOfSetting].value = &firstLineIndentSize;
    kNumberOfSetting++;
    
    if (isAlignCenter) {
        CTTextAlignment textAlignment = kCTTextAlignmentCenter;
        theSettings[kNumberOfSetting].spec = kCTParagraphStyleSpecifierAlignment;
        theSettings[kNumberOfSetting].valueSize = sizeof(textAlignment);
        theSettings[kNumberOfSetting].value = &textAlignment;
        kNumberOfSetting++;
    }
    
    CTParagraphStyleRef theParagraphRef = CTParagraphStyleCreate(theSettings, kNumberOfSetting);
    
//    UIColor *textColor = config.textColor;
//    CGFloat fontSize = config.fontSize + config.fontChange;
//    CTFontRef fontRef = CTFontCreateWithName((CFStringRef)@"ArialMT", fontSize, NULL);
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    //dict[(id)kCTForegroundColorAttributeName] = (id)textColor.CGColor;
    //dict[(id)kCTFontAttributeName] = (__bridge id)fontRef;
    dict[(id)kCTParagraphStyleAttributeName] = (__bridge id)theParagraphRef;
    
    //ZYCFSAFERELEASE(fontRef);
    ZYCFSAFERELEASE(theParagraphRef);
    
    return dict;
}

+ (CTFrameRef)frameWithSetter:(CTFramesetterRef)setter config:(ZYTRParserConfig *)config offset:(NSUInteger)offset {
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0, 0, config.width, config.height));
    
    CTFrameRef frame = CTFramesetterCreateFrame(setter, CFRangeMake(offset, 0), path, NULL);
    ZYCFSAFERELEASE(path);
    return frame;
}

+ (CTFrameRef)frameWithSetter:(CTFramesetterRef)setter config:(ZYTRParserConfig *)config height:(CGFloat)height {
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0, 0, config.width, height));
    
    CTFrameRef frame = CTFramesetterCreateFrame(setter, CFRangeMake(0, 0), path, NULL);
    ZYCFSAFERELEASE(path);
    return frame;
}

+ (UIColor *)colorFromString:(NSString *)string {
    if (!string.length) {
        return nil;
    }
    if ([string isEqualToString:@"default"]) {
        return nil;
    }
    NSString *cString = [[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    if ([cString length] < 6)
        return nil;
    //return [UIColor clearColor];
    if ([cString hasPrefix:@"0X"])
        cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if ([cString length] != 6)
        return nil;
    //return [UIColor clearColor];
    
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}

@end
