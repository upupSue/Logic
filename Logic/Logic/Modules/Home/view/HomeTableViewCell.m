//
//  HomeTableViewCell.m
//  Logic
//
//  Created by 方琼蔚 on 16/12/10.
//  Copyright © 2016年 方琼蔚. All rights reserved.
//

#import "HomeTableViewCell.h"
#import "PathUtils.h"


@implementation HomeTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.clipsToBounds=YES;
    self.selectionStyle=UITableViewCellSelectionStyleNone;
}

-(void)didTransitionToState:(UITableViewCellStateMask)state{
    if(state==UITableViewCellStateDefaultMask){
        _flag=0;
    }
}

-(void)layoutSubviews{
    if(_flag==1) return;
    for (UIView *subView in self.subviews) {
        if([subView isKindOfClass:NSClassFromString(@"UITableViewCellDeleteConfirmationView")]) {
            _flag=1;
            if(_isTrash){
                UIView *collectConfirmationView = subView.subviews[1];
                for (UIView *collectView in collectConfirmationView.subviews) {
                    UIImageView *collectImage = [[UIImageView alloc] initWithFrame:CGRectMake((collectView.frame.size.width-25)/2, -14, 25, 25)];
                    collectImage.contentMode = UIViewContentModeCenter;
                    collectImage.image = [UIImage imageNamed:@"restore"];
                    [collectView addSubview:collectImage];
                    UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake((collectView.frame.size.width-25)/2, collectView.frame.size.height, 25, 17)];
                    label.font=[UIFont systemFontOfSize:11];
                    label.text=@"还原";
                    label.textColor=[UIColor whiteColor];
                    label.textAlignment = NSTextAlignmentCenter;
                    [collectView addSubview:label];
                }
                UIView *deleteConfirmationView = subView.subviews[0];
                for (UIView *deleteView in deleteConfirmationView.subviews) {
                    UIImageView *deleteImage = [[UIImageView alloc] initWithFrame:CGRectMake((deleteView.frame.size.width-25)/2, -14, 25, 25)];
                    deleteImage.contentMode = UIViewContentModeCenter;
                    deleteImage.image = [UIImage imageNamed:@"wipeout"];
                    [deleteView addSubview:deleteImage];
                    UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake((deleteView.frame.size.width-25)/2, deleteView.frame.size.height, 25, 17)];
                    label.font=[UIFont systemFontOfSize:11];
                    label.text=@"清除";
                    label.textColor=[UIColor whiteColor];
                    label.textAlignment = NSTextAlignmentCenter;
                    [deleteView addSubview:label];
                }
                return;
            }
            // 拿到subView之后再获取子控件
            UIView *shareConfirmationView = subView.subviews[2];
            for (UIView *shareView in shareConfirmationView.subviews) {
                UIImageView *shareImage = [[UIImageView alloc] initWithFrame:CGRectMake((shareView.frame.size.width-25)/2, -14, 25, 25)];
                shareImage.contentMode = UIViewContentModeCenter;
                shareImage.image = [UIImage imageNamed:@"share"];
                [shareView addSubview:shareImage];
                UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake((shareView.frame.size.width-25)/2, shareView.frame.size.height, 25, 17)];
                label.font=[UIFont systemFontOfSize:11];
                label.text=@"分享";
                label.textColor=[UIColor whiteColor];
                label.textAlignment = NSTextAlignmentCenter;
                [shareView addSubview:label];
                UIView *line=[[UIView alloc]initWithFrame:CGRectMake(shareView.frame.size.width+15, -100 , 1, 250)];
                line.backgroundColor=SECOND_BGCOLOR;
                [shareView addSubview:line];
            }
            UIView *collectConfirmationView = subView.subviews[1];
            for (UIView *collectView in collectConfirmationView.subviews) {
                UIImageView *collectImage = [[UIImageView alloc] initWithFrame:CGRectMake((collectView.frame.size.width-25)/2, -14, 25, 25)];
                collectImage.contentMode = UIViewContentModeCenter;
                collectImage.image = [UIImage imageNamed:@"collect"];
                [collectView addSubview:collectImage];
                UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake((collectView.frame.size.width-25)/2, collectView.frame.size.height, 25, 17)];
                label.font=[UIFont systemFontOfSize:11];
                label.text=@"收藏";
                label.textColor=[UIColor whiteColor];
                label.textAlignment = NSTextAlignmentCenter;
                [collectView addSubview:label];
            }
            UIView *deleteConfirmationView = subView.subviews[0];
            for (UIView *deleteView in deleteConfirmationView.subviews) {
                UIImageView *deleteImage = [[UIImageView alloc] initWithFrame:CGRectMake((deleteView.frame.size.width-25)/2, -14, 25, 25)];
                deleteImage.contentMode = UIViewContentModeCenter;
                deleteImage.image = [UIImage imageNamed:@"delete"];
                [deleteView addSubview:deleteImage];
                UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake((deleteView.frame.size.width-25)/2, deleteView.frame.size.height, 25, 17)];
                label.font=[UIFont systemFontOfSize:11];
                label.text=@"删除";
                label.textColor=[UIColor whiteColor];
                label.textAlignment = NSTextAlignmentCenter;
                [deleteView addSubview:label];
            }
        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

- (void)setItem:(Item *)item
{
    NSString *text;

    if(_isTrash){
        NSString* fullPath=[trashWorkspace() stringByAppendingPathComponent:item.path];
        text= [NSString stringWithContentsOfFile:fullPath encoding:NSUTF8StringEncoding error:nil];
    }
    else {
        text = [NSString stringWithContentsOfFile:item.fullPath encoding:NSUTF8StringEncoding error:nil];}
    
    text = [text stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    text = [text stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    _item = item;
    _titleLabel.text = item.name;
    _contentLabel.text=text;
}
@end
