//
//  SeedlingPickerController.m
//  SortDataDemo
//
//  Created by 铁拳科技 on 16/7/21.
//  Copyright © 2016年 铁拳科技. All rights reserved.
//

#import "SeedlingPickerController.h"
#import "SeedingModel.h"

static NSString *const identifier = @"identifierKey";


@interface SeedlingPickerController ()<UISearchBarDelegate,UISearchResultsUpdating,UISearchDisplayDelegate>{
    NSMutableArray *_keys;       //组key
    NSMutableArray *_indexKeys;  //索引key
    NSDictionary *_sectionData;  //总数据
    NSMutableArray *_filterData; //过滤数据
    NSMutableArray *_seedingNames;  //过滤所需苗木
    UISearchController *_searchHighCrtl;
    UISearchDisplayController *_searchLowCrtl;
    UILabel *_scaleTip;
}

@end

@implementation SeedlingPickerController
- (void)leftAction{
    //必须马上消失
    _scaleTip.hidden = YES;
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //模拟版本判断,即此处设置版本
    [self configNav];
    [self initData];
    [self configViews];
}

- (void)configNav{
    //左侧按钮统一设置
    UIButton *leftItem = [UIButton buttonWithType:UIButtonTypeCustom];
    leftItem.frame = CGRectMake(0, 0, 30, 30);
    [leftItem setImage:[UIImage imageNamed:@"close_icon"] forState:UIControlStateNormal];
    [leftItem addTarget:self action:@selector(leftAction) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:leftItem];
}

- (void)initData{
    //城市plist
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"SectionSeeding" ofType:@"plist"];
    //总字典
    _sectionData = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    //将key排序
    _keys = [NSMutableArray arrayWithArray:[[_sectionData allKeys] sortedArrayUsingSelector:@selector(compare:)]];
    _indexKeys = [NSMutableArray arrayWithArray:_keys];
    //过滤城市名和拼音
    NSString *plistPath1 = [[NSBundle mainBundle] pathForResource:@"SeedingFilter" ofType:@"plist"];
    NSMutableArray *filterData = [[NSMutableArray alloc] initWithContentsOfFile:plistPath1];
    _seedingNames = [NSMutableArray array];
    for (NSDictionary *dic in filterData) {
        SeedingModel *seeding = [[SeedingModel alloc] init];
        seeding.NAME = [dic objectForKey:@"NAME"];
        seeding.LETTER = [dic objectForKey:@"LETTER"];
        seeding.SEDID = [dic objectForKey:@"SEDID"];
        [_seedingNames addObject:seeding];
    }
}

- (void)configViews{
    //注册单元格
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:identifier];
    //注册单元格
    self.tableView.sectionIndexColor = [UIColor grayColor];
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    //搜索框使用
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    searchBar.placeholder = @"输入苗木名或苗木拼音";
    self.tableView.tableHeaderView = searchBar;
    _searchLowCrtl = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    _searchLowCrtl.delegate = self;
    _searchLowCrtl.searchResultsDelegate = self;
    _searchLowCrtl.searchResultsDataSource = self;
    searchBar.delegate = self;
}

#pragma mark - UITableViewDatasource&Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.tableView) {
        NSString *key = [_keys objectAtIndex:indexPath.section];
        NSDictionary *dic = [[_sectionData objectForKey:key] objectAtIndex:indexPath.row];
        if (self.seedingPickerDidSelectSeeding) {
            self.seedingPickerDidSelectSeeding(dic[@"NAME"]);
        }
        NSLog(@"name:%@ code:%@",dic[@"NAME"],dic[@"SEDID"]);
    }else{
        NSString *seedingName = [[_filterData objectAtIndex:indexPath.row] NAME];
        [self ergodicCityWith:seedingName];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.tableView) {
        return _keys.count;
    }else{
        return 1;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.tableView) {
        NSString *key = [_keys objectAtIndex:section];
        NSArray *array = [_sectionData objectForKey:key];
        return array.count;
    }else {
        //7.0
        // c忽略大小写，d忽略重音 根据中文和拼音筛选
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"NAME contains [cd] %@ OR LETTER BEGINSWITH [cd] %@", _searchLowCrtl.searchBar.text,_searchLowCrtl.searchBar.text];
        _filterData = [[NSMutableArray alloc] initWithArray:[_seedingNames filteredArrayUsingPredicate:predicate]];
        return _filterData.count;
    }
    
    return 0;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    if (tableView == self.tableView) {
        return _indexKeys;
    }
    else
        return 0;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
    //点击索引，列表跳转到对应索引的行
    if (tableView == self.tableView) {
        
        [tableView
         scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:index]
         atScrollPosition:UITableViewScrollPositionTop animated:YES];
        [self showScaleTipWithTitle:_indexKeys[index]];
        return index;
        
    }else
        return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (tableView == self.tableView) {
        return _keys[section];
    }else
        return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.tableView) {
        return 44.f;
    }else{
        return 44.f;
    }
    return 0;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    if (tableView == self.tableView) {
        [self configCell:cell IndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        UIView *bgView = [[UIView alloc]init];
        bgView.backgroundColor = [UIColor colorWithRed:248 / 255.0 green:248 / 255.0 blue:248 / 255.0 alpha:1.0];
        cell.selectedBackgroundView = bgView;
    }else{
        cell.textLabel.text = [[_filterData objectAtIndex:indexPath.row]NAME];
    }
    return cell;
}

#pragma mark-配置不同cell
- (void)configCell:(UITableViewCell *)cell IndexPath:(NSIndexPath *)indexPath{
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    NSString *key = [_keys objectAtIndex:indexPath.section];
    cell.textLabel.text = [[[_sectionData objectForKey:key] objectAtIndex:indexPath.row]objectForKey:@"NAME"];
}


#pragma mark-放大视图
- (void)showScaleTipWithTitle:(NSString *)title{
    if (_scaleTip == nil) {
        CGFloat width = self.view.frame.size.width;
        CGFloat height = self.view.frame.size.height;
        _scaleTip = [[UILabel alloc]initWithFrame:CGRectMake((width - 80) / 2, (height - 80) / 2, 80, 80)];
    }
    [[UIApplication sharedApplication].keyWindow addSubview:_scaleTip];
    _scaleTip.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"light_blur"]];
    _scaleTip.text = title;
    _scaleTip.textColor = [UIColor lightGrayColor];
    _scaleTip.font = [UIFont fontWithName:@"ChalkboardSE-Bold" size:40];
    _scaleTip.textAlignment = NSTextAlignmentCenter;
    _scaleTip.layer.masksToBounds = YES;
    _scaleTip.layer.cornerRadius = 10;
    _scaleTip.alpha = 1.0;
    [UIView animateWithDuration:1.0 animations:^{
        _scaleTip.alpha = 0.0;
    }];
}

#pragma mark-updateSearchResultsDeleagte即8.0sarchBar刷新数据
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *searchString = [searchController.searchBar text];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"NAME contains [cd] %@ OR LETTER BEGINSWITH [cd] %@", searchString,searchString];
    
    if (_filterData!= nil) {
        [_filterData removeAllObjects];
    }
    
    //过滤数据
    _filterData = [[NSMutableArray alloc] initWithArray:[_seedingNames filteredArrayUsingPredicate:predicate]];
    //添加noresult提示
    if (searchString.length > 0) {
        if (_filterData.count == 0) {
            for (UIView *view in _searchHighCrtl.view.subviews) {
                if ([view isKindOfClass:[UILabel class]]) {
                    view.hidden = NO;
                }
            }
        }else{
            for (UIView *view in _searchHighCrtl.view.subviews) {
                if ([view isKindOfClass:[UILabel class]]) {
                    view.hidden = YES;
                }
            }
        }
    }else{
        for (UIView *view in _searchHighCrtl.view.subviews) {
            if ([view isKindOfClass:[UILabel class]]) {
                view.hidden = YES;
            }
        }
    }
    //刷新表格
    [self.tableView reloadData];
}



#pragma mark-遍历城市找出Code
- (void)ergodicCityWith:(NSString *)seedingName{
    
    //过滤的城市还需要code
    for (NSArray *array in [_sectionData allValues]) {
        for (NSDictionary *dic in array) {
            if ([dic[@"NAME"] isEqualToString:seedingName]) {
                NSLog(@"name:%@ code:%@",seedingName,dic[@"SEDID"]);
                if (self.seedingPickerDidSelectSeeding) {
                    self.seedingPickerDidSelectSeeding(dic[@"NAME"]);
                }
                return;
            }
        }
    }
}


@end
