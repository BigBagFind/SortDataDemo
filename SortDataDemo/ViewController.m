//
//  ViewController.m
//  SortDataDemo
//
//  Created by 铁拳科技 on 16/7/20.
//  Copyright © 2016年 铁拳科技. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
}

// 数下一共多少个为了核对下
- (void)countData{
    // 按字母分组
    NSString *path = [[NSBundle mainBundle]pathForResource:@"SectionSeeding" ofType:@"plist"];
    NSDictionary *data = [NSDictionary dictionaryWithContentsOfFile:path];
    NSInteger count = 0;
    for (NSString *key in data.allKeys) {
        NSArray *arr = [data objectForKey:key];
        count += arr.count;
    }
    NSLog(@"一共多少中:%ld",count);
}

// 按字母分组
- (void)sortSectionArray{
    // 按字母分组
    NSString *path = [[NSBundle mainBundle]pathForResource:@"SeedingFilter" ofType:@"plist"];
    NSArray *data = [NSArray arrayWithContentsOfFile:path];
    NSMutableArray *initialData = [NSMutableArray array];
    for (NSDictionary *dic in data) {
        NSString *pinyn = [dic objectForKey:@"LETTER"];
        NSString *first = [[pinyn capitalizedString]substringToIndex:1];
        [initialData addObject:first];
    }
    initialData = [initialData valueForKeyPath:@"@distinctUnionOfObjects.self"];
    NSArray *lastData = [initialData sortedArrayUsingSelector:@selector(compare:)];
    NSLog(@"%@",lastData);
    NSMutableDictionary *finalDic = [NSMutableDictionary dictionary];
    for (NSString *firstLetter in lastData) {
        NSMutableArray *sectionArray = [NSMutableArray array];
        for (NSDictionary *dic in data) {
            NSString *pinyn = [dic objectForKey:@"LETTER"];
            NSString *first = [[pinyn capitalizedString]substringToIndex:1];
            if ([first isEqualToString:firstLetter]) {
                [sectionArray addObject:dic];
            }
        }
        [finalDic setObject:sectionArray forKey:firstLetter];
    }
    NSLog(@"%@",finalDic);
    NSArray *paths1 = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *path1 = [paths1 objectAtIndex:0];
    NSString *filename = [path1 stringByAppendingPathComponent:@"SectionBreed.plist"];   //获取路径
    //创建一个dic，写到plist文件里
    [finalDic writeToFile:filename atomically:YES];
    NSLog(@"%@",path1);
    
}

// 插入拼音的keyValue，同时去空格，方便连搜
- (void)addPinyinToArray{
    NSString *path = [[NSBundle mainBundle]pathForResource:@"Breeds1" ofType:@"plist"];
    NSDictionary *pathDic = [NSDictionary dictionaryWithContentsOfFile:path];
    NSArray *data = [pathDic objectForKey:@"Breeds"];
    NSMutableArray *newData = [NSMutableArray array];
    for (NSDictionary *dic in data) {
        if ([[dic objectForKey:@"NAME"] length]) {
            NSMutableString *ms = [[NSMutableString alloc] initWithString:[dic objectForKey:@"NAME"]];
            if (CFStringTransform((__bridge CFMutableStringRef)ms, 0, kCFStringTransformMandarinLatin, NO)) {
                NSLog(@"pinyin: %@", ms);
            }
            if (CFStringTransform((__bridge CFMutableStringRef)ms, 0, kCFStringTransformStripDiacritics, NO)) {
                NSLog(@"pinyin: %@", ms);
                for (NSInteger i = 0; i < ms.length; i ++) {
                    NSString *subStr = [ms substringWithRange:NSMakeRange(i, 1)];
                    if ([subStr isEqualToString:@" "]) {
                        [ms deleteCharactersInRange:NSMakeRange(i, 1)];
                    }
                }
                NSMutableDictionary *lastDic = [NSMutableDictionary dictionaryWithDictionary:dic];
                [lastDic setObject:ms forKey:@"LETTER"];
                [newData addObject:lastDic];
            }
        }
    }
    NSArray *paths1 = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *path1 = [paths1 objectAtIndex:0];
    NSString *filename = [path1 stringByAppendingPathComponent:@"BreedFilter.plist"];   //获取路径
    
    //    //创建一个dic，写到plist文件里
    [newData writeToFile:filename atomically:YES];
    NSLog(@"%@",path1);

}

// 正常拼音排
- (void)sortData{    
    NSString *path = [[NSBundle mainBundle]pathForResource:@"Breeds" ofType:@"plist"];
    NSDictionary *pathDic = [NSDictionary dictionaryWithContentsOfFile:path];
    NSArray *data = [pathDic objectForKey:@"Breeds"];
    //NSLog(@"%@",pathDic);
    NSMutableArray *pinyinPre = [NSMutableArray array];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    //NSMutableArray *newData = [NSMutableArray array];
    for (NSDictionary *tempDic in data) {
        //        for (NSString *key in dic.allKeys) {
        //            if ([[tempDic objectForKey:@"NAME"] isEqualToString:key]) {
        //                NSLog(@"哈哈：%@ %@",[tempDic objectForKey:@"NAME"],key);
        //            }
        //        }
        [dic setObject:tempDic forKey:[tempDic objectForKey:@"NAME"]];
        if ([[tempDic objectForKey:@"NAME"] length]) {
            NSMutableString *ms = [[NSMutableString alloc] initWithString:[tempDic objectForKey:@"NAME"]];
            if (CFStringTransform((__bridge CFMutableStringRef)ms, 0, kCFStringTransformMandarinLatin, NO)) {
                NSLog(@"pinyin: %@", ms);
            }
            if (CFStringTransform((__bridge CFMutableStringRef)ms, 0, kCFStringTransformStripDiacritics, NO)) {
                NSLog(@"pinyin: %@", ms);
                [pinyinPre addObject:ms];
            }
        }
        
    }
    NSLog(@"%ld",dic.count);
    NSMutableArray *sortPinyinData = [NSMutableArray arrayWithArray:[pinyinPre sortedArrayUsingSelector:@selector(compare:)]];
    // NSLog(@"%@",pinyin);
    NSLog(@"%ld",sortPinyinData.count);
    
    
    NSMutableArray *newArr = [NSMutableArray array];
    [sortPinyinData enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        // 当前的拼音，按顺序来
        NSString *CurrentPinyin = obj;
        // 找出keys拼音一样的
        for (NSString *hanzi in dic.allKeys) {
            NSString *pinyin;
            // 转拼音
            if ([hanzi length]) {
                NSMutableString *ms = [[NSMutableString alloc] initWithString:hanzi];
                if (CFStringTransform((__bridge CFMutableStringRef)ms, 0, kCFStringTransformMandarinLatin, NO)) {
                    NSLog(@"pinyin: %@", ms);
                }
                if (CFStringTransform((__bridge CFMutableStringRef)ms, 0, kCFStringTransformStripDiacritics, NO)) {
                    NSLog(@"pinyin: %@", ms);
                    pinyin = ms;
                }
            }
            // 再从当前拼音相匹配
            if ([CurrentPinyin isEqualToString:pinyin]) {
                [newArr addObject:[dic objectForKey:hanzi]];
                [dic removeObjectForKey:hanzi];
                break;
            }
        }
        
    }];
    NSLog(@"%@",newArr);
    
    NSArray *paths1 = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *path1 = [paths1 objectAtIndex:0];
    NSString *filename = [path1 stringByAppendingPathComponent:@"Breeds.plist"];   //获取路径
    
    //    //创建一个dic，写到plist文件里
    NSDictionary* dicccccc = @{@"Breeds":newArr};
    [dicccccc writeToFile:filename atomically:YES];
    NSLog(@"%@",path1);
    
    // /Users/tiequan/Library/Developer/CoreSimulator/Devices/13720294-F640-4CCC-85B8-7E9CB2307345/data/Containers/Data/Application/49F28336-6C26-4349-A269-6E4238CC6F32/Documents
}



@end
