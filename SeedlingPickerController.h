//
//  SeedlingPickerController.h
//  SortDataDemo
//
//  Created by 铁拳科技 on 16/7/21.
//  Copyright © 2016年 铁拳科技. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SeedingPickerDidSelectSeeding)(id result);

@interface SeedlingPickerController : UITableViewController

@property (nonatomic, copy) SeedingPickerDidSelectSeeding seedingPickerDidSelectSeeding;


@end
