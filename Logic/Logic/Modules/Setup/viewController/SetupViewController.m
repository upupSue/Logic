//
//  SetupViewController.m
//  Logic
//
//  Created by 方琼蔚 on 16/12/19.
//  Copyright © 2016年 方琼蔚. All rights reserved.
//

#import "SetupViewController.h"
#import "FontViewController.h"
#import "Configure.h"

@interface SetupViewController (){
    float fontsize;
}

@property (weak, nonatomic) IBOutlet UISwitch *switchbtn;
@property (weak, nonatomic) IBOutlet UILabel *content;
@property (weak, nonatomic) IBOutlet UISlider *fontSlider;

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
    
    _fontSlider.value = [Configure sharedConfigure].fontSize;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)chooseFont:(id)sender {
    FontViewController *vc=[[FontViewController alloc]init];
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)fontValueChange:(UISlider *)sender {
    fontsize = sender.value;
}

- (IBAction)goback:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)check:(id)sender {
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:nil message:@"确认要保存修改吗？" preferredStyle:UIAlertControllerStyleAlert];
    [alertVc addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil]];
    [alertVc addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [Configure sharedConfigure].fontSize=fontsize;
        [self dismissViewControllerAnimated:YES completion:nil];
    }]];
    [self presentViewController:alertVc animated:YES completion:nil];
}

@end
