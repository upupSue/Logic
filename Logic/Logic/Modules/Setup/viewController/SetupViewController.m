//
//  SetupViewController.m
//  Logic
//
//  Created by 方琼蔚 on 16/12/19.
//  Copyright © 2016年 方琼蔚. All rights reserved.
//

#import "SetupViewController.h"

@interface SetupViewController ()
@property (weak, nonatomic) IBOutlet UISwitch *switchbtn;
@property (weak, nonatomic) IBOutlet UILabel *content;

@end

@implementation SetupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=@"编辑器";
    _switchbtn.onTintColor= [UIColor colorWithRed:53/255. green:207/255. blue:215/255. alpha:1.000];
    NSString *content=@"Logic支持许多文本样式，包括*粗体*、/斜体/、_下划线_ 、-删除线-、1至6号标题以及更多功能。你可以在/格式面板/中快速找到它们：";
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:content];
    [attrStr addAttribute:NSFontAttributeName value: [UIFont boldSystemFontOfSize:16] range:NSMakeRange(17, 2)];
    [attrStr addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlinePatternSolid | NSUnderlineStyleSingle) range:NSMakeRange(33, 5)];
    [attrStr addAttribute:NSStrikethroughColorAttributeName value:[UIColor grayColor] range:NSMakeRange(0, attrStr.length)];
    self.content.attributedText = attrStr;
}

//-(void)viewWillAppear:(BOOL)animated{
//    [self.navigationController setNavigationBarHidden:NO];
//}
//
//- (void)viewWillDisappear:(BOOL)animated{
//    [self.navigationController setNavigationBarHidden:YES];
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
