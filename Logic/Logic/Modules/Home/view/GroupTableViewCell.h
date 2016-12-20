//
//  GroupTableViewCell.h
//  Logic
//
//  Created by 方琼蔚 on 16/12/20.
//  Copyright © 2016年 方琼蔚. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Item.h"

@interface GroupTableViewCell : UITableViewCell

@property (nonatomic,strong) Item *item;

@property (weak, nonatomic) IBOutlet UIButton *tagBtn;

@end
