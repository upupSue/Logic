//
//  ImportViewController.m
//  Logic
//
//  Created by 方琼蔚 on 16/12/19.
//  Copyright © 2016年 方琼蔚. All rights reserved.
//

#import "ImportViewController.h"

@interface ImportViewController ()

@end

@implementation ImportViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=@"导入与导出";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)goback:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
