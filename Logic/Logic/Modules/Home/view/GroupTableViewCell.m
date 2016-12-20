//
//  GroupTableViewCell.m
//  Logic
//
//  Created by 方琼蔚 on 16/12/20.
//  Copyright © 2016年 方琼蔚. All rights reserved.
//

#import "GroupTableViewCell.h"

@implementation GroupTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _tagBtn.layer.cornerRadius=8;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

@end
